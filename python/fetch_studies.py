#!/usr/bin/env python3
"""fetch_studies.py — automated study RETRIEVAL for Halcyon.

Queries PubMed (NCBI E-utilities) and ClinicalTrials.gov (API v2) for the
review's terms and writes a candidate list to data/raw/candidates.csv with
columns: source, id, title, year, journal, doi, url, abstract, is_new.

This script only *fetches and flags*. It never edits the curated data
(studies.csv / pooled_results.csv). Inclusion and appraisal stay a human
decision (done in Cowork). `is_new` marks candidates whose DOI/title are not
already present in studies.csv, so new papers surface without auto-including
anything.

Usage (standalone):
    pip install -r python/requirements.txt
    python python/fetch_studies.py                 # default query, ~50 hits/source
    python python/fetch_studies.py --max 100       # more results
    python python/fetch_studies.py --email you@example.com   # be a good NCBI citizen

From R (optional, via reticulate):
    reticulate::py_run_file("python/fetch_studies.py")
"""
from __future__ import annotations

import argparse
import csv
import os
import re
import sys
import time

try:
    import requests
except ImportError:  # fail loudly, per the compendium's conventions
    sys.exit("Missing dependency 'requests'. Run: pip install -r python/requirements.txt")

# --- Review search terms (edit these to change the search) ------------------
PUBMED_QUERY = (
    '(prolotherapy OR "dextrose injection" OR "platelet-rich plasma" OR PRP) '
    'AND (hypermobility OR "Ehlers-Danlos" OR "joint instability" '
    'OR "temporomandibular" OR subluxation)'
)
CTGOV_QUERY = (
    'prolotherapy OR "platelet-rich plasma" OR PRP '
    'AND (hypermobility OR "Ehlers-Danlos" OR "joint instability")'
)

EUTILS = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
CTGOV = "https://clinicaltrials.gov/api/v2/studies"

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
STUDIES_CSV = os.path.join(REPO, "data", "raw", "studies.csv")
OUT_CSV = os.path.join(REPO, "data", "raw", "candidates.csv")

DOI_RE = re.compile(r"10\.\d{4,9}/\S+", re.IGNORECASE)


def _norm_title(t: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", (t or "").lower()).strip()


def _norm_doi(d: str) -> str:
    return (d or "").lower().strip().rstrip(".").rstrip("/")


# --- PubMed -----------------------------------------------------------------
def fetch_pubmed(query: str, retmax: int, email: str | None) -> list[dict]:
    common = {"db": "pubmed", "tool": "halcyon", "retmode": "json"}
    if email:
        common["email"] = email

    r = requests.get(f"{EUTILS}/esearch.fcgi",
                     params={**common, "term": query, "retmax": retmax}, timeout=30)
    r.raise_for_status()
    ids = r.json().get("esearchresult", {}).get("idlist", [])
    if not ids:
        return []

    time.sleep(0.34)  # stay under NCBI's 3 req/s limit
    r = requests.get(f"{EUTILS}/esummary.fcgi",
                     params={**common, "id": ",".join(ids)}, timeout=30)
    r.raise_for_status()
    result = r.json().get("result", {})

    abstracts = _fetch_pubmed_abstracts(ids, email)
    rows = []
    for uid in ids:
        rec = result.get(uid, {})
        if not rec:
            continue
        doi = ""
        for aid in rec.get("articleids", []):
            if aid.get("idtype") == "doi":
                doi = aid.get("value", "")
                break
        year = (rec.get("pubdate", "") or "").split(" ")[0][:4]
        rows.append({
            "source": "PubMed",
            "id": uid,
            "title": rec.get("title", "").rstrip("."),
            "year": year,
            "journal": rec.get("fulljournalname", ""),
            "doi": doi,
            "url": f"https://pubmed.ncbi.nlm.nih.gov/{uid}/",
            "abstract": abstracts.get(uid, ""),
        })
    return rows


def _fetch_pubmed_abstracts(ids: list[str], email: str | None) -> dict[str, str]:
    time.sleep(0.34)
    params = {"db": "pubmed", "tool": "halcyon", "retmode": "xml",
              "rettype": "abstract", "id": ",".join(ids)}
    if email:
        params["email"] = email
    r = requests.get(f"{EUTILS}/efetch.fcgi", params=params, timeout=30)
    r.raise_for_status()

    import xml.etree.ElementTree as ET
    out: dict[str, str] = {}
    try:
        root = ET.fromstring(r.text)
    except ET.ParseError:
        return out
    for art in root.iter("PubmedArticle"):
        pmid_el = art.find(".//PMID")
        if pmid_el is None:
            continue
        parts = [(el.text or "") for el in art.iter("AbstractText")]
        out[pmid_el.text] = " ".join(p for p in parts if p).strip()
    return out


# --- ClinicalTrials.gov -----------------------------------------------------
def fetch_ctgov(query: str, page_size: int) -> list[dict]:
    r = requests.get(CTGOV, params={
        "query.term": query, "pageSize": min(page_size, 100), "format": "json",
    }, timeout=30)
    r.raise_for_status()
    rows = []
    for st in r.json().get("studies", []):
        ps = st.get("protocolSection", {})
        ident = ps.get("identificationModule", {})
        nct = ident.get("nctId", "")
        start = ps.get("statusModule", {}).get("startDateStruct", {}).get("date", "")
        rows.append({
            "source": "ClinicalTrials.gov",
            "id": nct,
            "title": ident.get("briefTitle", ""),
            "year": (start or "")[:4],
            "journal": "",
            "doi": "",
            "url": f"https://clinicaltrials.gov/study/{nct}" if nct else "",
            "abstract": ps.get("descriptionModule", {}).get("briefSummary", ""),
        })
    return rows


# --- Dedup vs curated data --------------------------------------------------
def load_existing(studies_csv: str) -> tuple[set[str], list[tuple[str, str]]]:
    """Return (DOIs, [(first-author surname, year)]) from the curated set."""
    dois: set[str] = set()
    author_year: list[tuple[str, str]] = []
    if not os.path.exists(studies_csv):
        sys.exit(f"Missing curated data: {studies_csv}")
    with open(studies_csv, newline="", encoding="utf-8") as fh:
        for row in csv.DictReader(fh):
            for m in DOI_RE.findall(row.get("source_url", "") or ""):
                dois.add(_norm_doi(m))
            surname = re.split(r"[\s,]+", (row.get("authors", "") or "").strip())[0]
            year = (row.get("year", "") or "").strip()
            if surname:
                author_year.append((surname.lower(), year))
    return dois, author_year


def _is_known(row: dict, dois: set[str], author_year: list[tuple[str, str]]) -> bool:
    if row["doi"] and _norm_doi(row["doi"]) in dois:
        return True
    title = _norm_title(row["title"])
    return any(surname and surname in title and (not year or year == row["year"])
               for surname, year in author_year)


def main() -> None:
    ap = argparse.ArgumentParser(description="Fetch candidate studies for Halcyon.")
    ap.add_argument("--max", type=int, default=50, help="max results per source")
    ap.add_argument("--email", default=None, help="contact email for NCBI E-utilities")
    ap.add_argument("--pubmed-query", default=PUBMED_QUERY)
    ap.add_argument("--ctgov-query", default=CTGOV_QUERY)
    ap.add_argument("--output", default=OUT_CSV)
    args = ap.parse_args()

    print("Querying PubMed…", file=sys.stderr)
    rows = fetch_pubmed(args.pubmed_query, args.max, args.email)
    print(f"  {len(rows)} PubMed records", file=sys.stderr)

    print("Querying ClinicalTrials.gov…", file=sys.stderr)
    ct = fetch_ctgov(args.ctgov_query, args.max)
    print(f"  {len(ct)} trial registrations", file=sys.stderr)
    rows += ct

    rows = [r for r in rows if r["title"].strip()]  # drop sparse non-article records

    existing_dois, existing_author_year = load_existing(STUDIES_CSV)
    n_new = 0
    for row in rows:
        row["is_new"] = "" if _is_known(row, existing_dois, existing_author_year) else "NEW"
        if row["is_new"]:
            n_new += 1

    fields = ["source", "id", "title", "year", "journal", "doi", "url",
              "abstract", "is_new"]
    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    with open(args.output, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        w.writerows(rows)

    print(f"\nWrote {len(rows)} candidates to {args.output} "
          f"({n_new} flagged NEW vs studies.csv).", file=sys.stderr)
    print("Retrieval only — inclusion/appraisal remains a human decision.",
          file=sys.stderr)


if __name__ == "__main__":
    main()
