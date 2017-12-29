#!/bin/bash

# Download OpsReportCard website content and convert to markdown, html, etc.

# Configuration
BASE_URL='http://opsreportcard.com'

# Make sure this is running under Bash
if [ ! "$BASH_VERSION" ]; then \
    exec /bin/bash "$0" "$@"
fi

# Check for requirements
which wget perl xmllint pandoc Rscript > /dev/null
if [ $? -ne 0 ]; then \
  echo "$0 requires wget, perl, xmllint, pandoc, and Rscript"
  exit 1
fi

# Remove old files, if any
rm -f *.bak ?.md ??.md {about,contact,home,tipjar}.md OpsReportCard.{md,pdf,html,epub}

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
  perl -pi.bak -e 's/\\//g;' "${i}.md"
done

# Redo headings for 2.md
perl -pi.bak -e 's/^=*//g; s/^(What is|How do)/#### $1/g;' 2.md

# Escape filenames in 16.md
perl -pi.bak -e 's/(\/etc\/[^ ]*\.bak|\/etc\/hosts\.\[|\])/`$1`/g;' 16.md && \
  perl -pi.bak -e "s/(today's date)/_\$1_/g;" 16.md

# Fix blockquote attribution formatting
for i in 6.md 12.md; do \
  perl -pi.bak -e 's/(-Limoncelli.*)$/  \n> _$1_/g' "$i"
done

# Cleanup last section of each article
for i in [0-9]*.md; do \
  perl -pi.bak -e 's/^(For More Information)/#### $1/g' "$i" && \
    perl -pi.bak -e 's/^> (For more info)/$1/g' "$i"
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
perl -pi.bak -e 's/^=*//g; s/^-*//g; s/\\//g; s/^"Ok/## "Ok/g;' home.md && \
  perl -pi.bak -e 's/^(What|Do assessments|How do)/### $1/g;' home.md
perl -pi.bak \
  -e 's/^\!.*$/\[(Donate)\]\(http:\/\/www\.opsreportcard\.com\/tipjar\)/g;' \
  tipjar.md

# Clean up all md content pages of remaining artifacts (needed on macOS and Windows)
for i in [0-9]*.md {about,contact,home,tipjar}.md; do \
  perl -pi.bak -e 's/\\//g; s/^(<\/?div|^height=|^class=|^id=|^:::).*$//g;' "$i"
done

# Combine into a single Markdown file and remove carriage returns and extra lines
Rscript -e \
  'require("knitr"); knit("OpsReportCard.Rmd")' && \
  perl -00 -pi.bak -e 's/\r\n/\n/g; s/\n{4,}//g;' OpsReportCard.md

# Convert Markdown to html with a table of contents
Rscript -e \
  'require("rmarkdown"); render("OpsReportCard.Rmd", html_document(toc=TRUE, toc_depth=3, mathjax=NULL, template=NULL))'

# Use ebook-convert, if you have it, to make the epub, otherwise use pandoc
which ebook-convert > /dev/null
if [ $? -eq 0 -a -f OpsReportCard.html ]; then \
  ebook-convert OpsReportCard.html OpsReportCard.epub
else [ -f OpsReportCard.md ] && \
  pandoc -f markdown -t epub title.txt OpsReportCard.md -o OpsReportCard.epub
fi

# Convert Markdown to pdf with a table of contents
Rscript -e \
  'require("rmarkdown"); render("OpsReportCard.Rmd", pdf_document(toc=TRUE, toc_depth=3))'

