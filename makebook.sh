#!/bin/bash

# Download OpsReportCard website content and convert to markdown, html, pdf, etc.

# ------
# Setup
# ------

# Configuration
BASE_URL='http://opsreportcard.com'

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
rm -f *.bak ?.md ??.md {about,contact,home,tipjar}.md OpsReportCard.{md,pdf,html,epub}

# ----------------
# Data Collection
# ----------------

# Get articles for each question as markdown
for i in {1..32}; do \
  wget -q -O - "${BASE_URL}/section/${i}" | \
  xmllint --html --xpath '(//div[@class = "document"])' - 2>/dev/null | \
  pandoc -s -r html -o "${i}.md"
  perl -pi.bak -e 's/\\//g;' "${i}.md"
done

# Get questions as markdown headings and interweave articles 
wget -q -O - "${BASE_URL}/section/1" | \
  xmllint --html --xpath \
    '(//div[@id = "accordion"]/div/a/span/text() | //div[@id = "accordion"]/h3/a/text())' - 2>/dev/null | \
  perl -wpl -e 's/([A-G0-9]+\.)/\n$1/g; s/([A-G]+\.)/\n## $1/g;' \
    -e 's/([0-9]+)\.(.*)(\n|$)/"\n### $1\. $2\n\n".`cat $1.md`."\n"/ge;' > q.md

# Get content for home, about, contact, and tipjar pages
wget -q -O - "${BASE_URL}" | \
  xmllint --html --xpath '(//div[@id = "DivContent"])' - 2>/dev/null | \
  pandoc -s -r html -o home.md
for i in about contact tipjar; do \
  wget -q -O - "${BASE_URL}/$i" | \
    xmllint --html --xpath '(//div[@id = "DivContent"])' - 2>/dev/null | \
    pandoc -s -r html -o "${i}.md"
done

# -------------
# Data Cleanup
# -------------

# Redo headings for question 2
perl -pi.bak -e 's/^=*//g; s/^(What is|How do)/#### $1/g;' q.md

# Escape filenames in question 16
perl -pi.bak -e 's/(\/etc\/[^ ]*\.bak|\/etc\/hosts\.\[.*\])/`$1`/g;' q.md

# Fix blockquote attribution formatting for questions 6 and 12
perl -pi.bak -e 's/(-Limoncelli.*)$/  \n> _$1_/g' q.md

# Cleanup last section of each article
perl -pi.bak -e 's/^(For More Information)/#### $1/g; s/^> (For more info)/$1/g' q.md

# Clean up home page and tip jar page content
perl -pi.bak -e 's/^=*//g; s/^-*//g; s/\\//g; s/^"Ok/## "Ok/g;' home.md && \
  perl -pi.bak -e 's/^(What|Do assessments|How do)/### $1/g;' home.md
perl -pi.bak \
  -e 's/^\!.*$/\[(Donate)\]\(http:\/\/www\.opsreportcard\.com\/tipjar\)/g;' \
  tipjar.md

# Clean up all md content pages of remaining artifacts (needed on macOS and Windows)
for i in {q,about,contact,home,tipjar}.md; do \
  perl -pi.bak -e 's/\\//g; s/^(<\/?div|^height=|^class=|^id=|^:::).*$//g;' "$i"
done

# ----------------
# Header Creation
# ----------------

# Create header yaml for markdown
(
cat <<'EOF'
---
title: "The Operations Report Card"
author: "Tom Limoncelli and Peter Grace"
date: "[http://www.opsreportcard.com](http://www.opsreportcard.com)"
---
EOF
) > start.md

# Create title text for epub
(
cat <<'EOF'
% The Operations Report Card
% Tom Limoncelli and Peter Grace
EOF
) > title.txt

# ------------------
# Output Generation
# ------------------ 

# Combine Markdown files and remove extra whitespace characters
cat start.md home.md q.md > OpsReportCard.md
echo -e "## About Us$(cat about.md)\n\n" >> OpsReportCard.md
echo -e "## Contact Us$(cat contact.md)\n\n" >> OpsReportCard.md
echo -e "## Tip Jar$(cat tipjar.md)\n" >> OpsReportCard.md
perl -00 -pi.bak -e 's/\r\n/\n/g; s/\n{4,}//g;' OpsReportCard.md

# Convert Markdown to html with a table of contents
pandoc +RTS -K512m -RTS OpsReportCard.md --to html \
  --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash \
  --output OpsReportCard.html --smart --email-obfuscation none --self-contained \
  --standalone --section-divs --table-of-contents --toc-depth 3 --no-highlight \
  --variable 'theme:bootstrap'

# Convert Markdown to epub with a table of contents
pandoc -f markdown --table-of-contents --toc-depth 3 \
  -t epub title.txt OpsReportCard.md -o OpsReportCard.epub

# Convert Markdown to pdf with a table of contents
pandoc +RTS -K512m -RTS OpsReportCard.md --to latex \
  --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash \
  --output OpsReportCard.pdf --table-of-contents --toc-depth 3 \
  --highlight-style tango --variable graphics=yes --variable 'geometry:margin=1in'

