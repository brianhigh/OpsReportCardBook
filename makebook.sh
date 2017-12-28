#!/bin/bash

# Download OpsReportCard website content and convert to markdown, html, etc.

# Configuration
BASE_URL='http://opsreportcard.com'

# Make sure this is running under Bash
if [ ! "$BASH_VERSION" ]; then
    exec /bin/bash "$0" "$@"
fi

# Check for requirements
which wget perl xmllint pandoc Rscript > /dev/null
if test $? -ne 0; then \
  echo "$0 requires wget, perl, xmllint, pandoc, and Rscript"
  exit 1
fi

# Remove old files, if any
rm -f ?.md ??.md {about,contact,home,tipjar}.md OpsReportCard.{md,pdf,html,epub}

# Get list of questions
wget -q -O - "${BASE_URL}/section/1" | \
  xmllint --html --xpath \
    '(//div[@id = "accordion"]/div/a/span/text() | //div[@id = "accordion"]/h3/a/text())' - 2>/dev/null | \
  perl -wpl -e 's/([A-G0-9]+\.)/\n$1/g;' \
    -e 's/([A-G]+\.)/\n## $1/g; s/([0-9]+)\.(.*)(\n|$)/\n### $1\. $2\n\n```\{r child = "$1\.md"\}\n```\n/g;' > q.md

# Get articles for each question
for i in {1..32}; do \
  wget -q -O - "${BASE_URL}/section/${i}" | \
  xmllint --html --xpath '(//div[@class = "document"])' - 2>/dev/null | \
  pandoc -s -r html -o "${i}.md"
done

# Redo headings for 2.md
perl -pi -e 's/^=*//g;' -e 's/^(What is|How do)/#### $1/g;' 2.md

# Fix blockquote attribution formatting
for i in 6.md 12.md; do \
  perl -pi -e 's/(-Limoncelli.*)$/  \n> _$1_/g' "$i"
done

# Cleanup last section of each article
for i in [0-9]*.md; do \
  perl -pi -e 's/^(For More Information)/#### $1/g' "$i"
  perl -pi -e 's/^> (For more info)/$1/g' "$i"
done

# Get content for home, about, contact, and tipjar pages
wget -q -O - "${BASE_URL}" | \
  xmllint --html --xpath '(//div[@id = "DivContent"])' - 2>/dev/null | \
  pandoc -s -r html -o home.md
for i in about contact tipjar; do \
  wget -q -O - "${BASE_URL}/$i" | \
    xmllint --html --xpath '(//div[@id = "DivContent"])' - 2>/dev/null | \
    pandoc -s -r html -o "${i}.md"
done

# Clean up home page and tip jar page content
perl -pi -e 's/^=*//g;' -e 's/^-*//g;' -e 's/^"Ok/## "Ok/g;' \
  -e 's/^(What|Do assessments|How do)/### $1/g;' home.md
perl -pi \
  -e 's/^\!.*$/\[(Donate)\]\(http:\/\/www\.opsreportcard\.com\/tipjar\)/g;' \
  -e 's/^(<\/?div|^height=|^class=|^id=).*$//g;' tipjar.md

# Convert Markdown to html and pdf
[ -f OpsReportCard.Rmd ] && Rscript render.R

# Clean up markdown file for macOS
perl -pi -e 's/^(<\/?div|^height=|^class=|^id=).*$//g' OpsReportCard.md

# Convert Markdown to epub
[ -f OpsReportCard.md ] && \
  pandoc -f markdown -t epub title.txt OpsReportCard.md -o OpsReportCard.epub
