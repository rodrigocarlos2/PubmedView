# Pubmed-Parser
Script to download pubmed abstracts given the PMIDs.

# Usage:
python pubmed_parser.py pmids_file <br />
pmids_file should have PMIDs, one in each line.

# Input:
A list of PMIDs in a file, one in each line <br />

# Output:
The output will be abstract text in plain text in the following format: <br />
<br />
PMID-[pmid] <br />
TI - [title] <br />
AB - [abstract_text] <br />
PT - [publication_type, separated by delimeter ~@~] <br />
MH - [mesh terms, separated by delimeter ~@~] <br />
