#!/bin/bash

# Download OpsReportCard website content and convert to markdown, html, pdf, etc.
# Requires wget, perl, xmllint, pandoc, and pdflatex.

# ------
# Setup
# ------

# Configuration
BASE_URL='http://opsreportcard.com'
TITLE='The Operations Report Card'
AUTHOR='Tom Limoncelli and Peter Grace'
LINK="[${BASE_URL}](${BASE_URL})"
OUT='OpsReportCard'

# Make sure this is running under Bash
if [ ! "$BASH_VERSION" ]; then \
  exec /bin/bash "$0" "$@"
fi

# Check for requirements
which wget perl xmllint pandoc pdflatex > /dev/null
if [ $? -ne 0 ]; then \
  echo "$0 requires wget, perl, xmllint, pandoc, and pdflatex"
  exit 1
fi

# Remove old files, if any
rm -f *.bak ?.md ??.md {head,about,contact,home,tipjar}.md \
  "${OUT}".{md,pdf,html,epub}

# ----------------
# Header Creation
# ----------------

# Create yaml header for markdown
(
cat <<EOF
---
title: "$TITLE"
author: "$AUTHOR"
date: "$LINK"
---

EOF
) > head.md

# ----------------
# Data Collection
# ----------------

# Get articles for each question as markdown
for i in {1..32}; do \
  wget -q -O - "${BASE_URL}/section/${i}" | \
  xmllint --html --xpath '(//div[@class = "document"])' - 2>/dev/null | \
  pandoc -f html -t markdown > "${i}.md"
done

# Get questions as markdown headings and interweave articles 
wget -q -O - "${BASE_URL}/section/1" | \
  xmllint --html --xpath \
    '(//div[@id = "accordion"]/div/a/span/text() | //div[@id = "accordion"]/h3/a/text())' - 2>/dev/null | \
  perl -wpl \
    -e 's/([A-G0-9]+\.)/\n$1/g; s/([A-G]+\.)/\n## $1/g;' \
    -e 's/([0-9]+)\.(.*)(\n|$)/"\n### $1\. $2\n\n".`cat "$1.md"`."\n"/ge;' > q.md

# Get content for home, about, contact, and tipjar pages
wget -q -O - "${BASE_URL}" | \
  xmllint --html --xpath '(//div[@id = "DivContent"])' - 2>/dev/null | \
  pandoc -f html -t markdown -o home.md
for i in about contact tipjar; do \
  wget -q -O - "${BASE_URL}/$i" | \
    xmllint --html --xpath '(//div[@id = "DivContent"])' - 2>/dev/null | \
    pandoc -f html -t markdown -o "${i}.md"
done

# -------------
# Data Cleanup
# -------------

perl -pi.bak \
  -e 's/\\//g; s/^=*//g; s/^(What is|How do)/#### $1/g;' \
  -e 's/(\/etc\/[^ ]*\.bak|\/etc\/hosts\.\[.*\])/`$1`/g;' \
  -e 's/(-Limoncelli.*)$/  \n> _$1_/g;' \
  -e 's/^(For More Information)/#### $1/g;' \
  -e 's/^> (For more info)/$1/g;' \
  q.md

perl -pi.bak \
  -e 's/^=*//g; s/^-*//g; s/\\//g; s/^"Ok/## "Ok/g;' \
  -e 's/^(What|Do assessments|How do)/### $1/g;' \
  home.md

perl -pi.bak \
  -e 's/^\!.*$/\[(Donate)\]\(http:\/\/www\.opsreportcard\.com\/tipjar\)/g;' \
  tipjar.md

# Combine Markdown files
cat head.md home.md q.md > "${OUT}.md"
echo -e "## About Us\n\n$(cat about.md)\n\n" >> "${OUT}.md"
echo -e "## Contact Us\n\n$(cat contact.md)\n\n" >> "${OUT}.md"
echo -e "## Tip Jar\n\n$(cat tipjar.md)\n" >> "${OUT}.md"

# Remove remaining artifacts and extra whitespace characters
perl -pi.bak -e 's/\\//g; s/(<\/?div|^height=|^class=|^id=|^:::).*$//g;' "${OUT}.md"
perl -00 -pi.bak -e 's/\r\n/\n/g; s/\n{4,}//g;' "${OUT}.md"

# ------------------
# Output Generation
# ------------------ 

# Convert Markdown to html, epub, and pdf with a table of contents
for suffix in html epub pdf; do \
  pandoc -s --toc -o "${OUT}.${suffix}" "${OUT}.md"
done

# Remove old files, if any
rm -f *.bak ?.md ??.md {head,about,contact,home,tipjar}.md

