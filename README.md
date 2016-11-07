# Pubmed-Parser
Script to download pubmed abstracts given the PMIDs.

# Usage:
python pubmed_parser.py pmids_file
pmids_file should have PMIDs, one in each line.

# Input:
A list of PMIDs in a file, one in each line

# Output:
The output will be abstract text in plain text in the following format:

PMID-[pmid]
TI - [title]
AB - [abstract_text]
PT - [publication_type, separated by delimeter ~@~]
MH - [mesh terms, separated by delimeter ~@~]

