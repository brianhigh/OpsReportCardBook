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
perl -00 -pi.bak -e 's/\{.reference\n?\s+\.external\}//g;' "${OUT}.md"

# Transform links from my.safaribooksonline.com to learning.oreilly.com
perl -pi.bak -e 's/https?:\/\/my\.safaribooksonline\.com\/.*\/(9780321545275)/https:\/\/learning.oreilly.com\/library\/view\/the-practice-of\/$1/g;' "${OUT}.md"
perl -pi.bak -e 's/https?:\/\/my\.safaribooksonline\.com\/(9780321545275)/https:\/\/learning.oreilly.com\/library\/view\/the-practice-of\/$1/g;' "${OUT}.md"
perl -pi.bak -e 's/https?:\/\/my\.safaribooksonline\.com\/.*\/(0596007833)/https:\/\/learning.oreilly.com\/library\/view\/time-management-for\/$1/g;' "${OUT}.md"
perl -pi.bak -e 's/https?:\/\/my\.safaribooksonline\.com\/(0596007833)/https:\/\/learning.oreilly.com\/library\/view\/time-management-for\/$1/g;' "${OUT}.md"
perl -pi.bak -e 's/[a-z-]*\/(ch[0-9]+)\)/$1.html\)/g;' "${OUT}.md"
perl -pi.bak -e 's/security-policy\/([0-9]+)\)/ch11.html#page_$1\)/g;' "${OUT}.md"
perl -pi.bak -e 's/helpdesks\//ch13.html#/g;' "${OUT}.md"
perl -pi.bak -e 's/ch13lev1sec1\)/ch13lev2sec10\)/g;' "${OUT}.md"
perl -pi.bak -e 's/getting-started\/27/ch02.html#ch02sb01/g;' "${OUT}.md"
perl -pi.bak -e 's/ch33lev2sec6\)/ch33lev3sec1\)/g;' "${OUT}.md"
perl -pi.bak -e 's/a-guide-for-technical-managers\/820/ch33.html#ch33lev3sec1/g;' "${OUT}.md"
perl -pi.bak -e 's/a-guide-for-technical-managers\/843/ch33.html#ch33lev2sec6/g;' "${OUT}.md"
perl -pi.bak -e 's/maintenance-windows\/492/ch20.html#ch20lev2sec13/g;' "${OUT}.md"
perl -pi.bak -e 's/workstations\/54/ch03.html#ch03lev2sec2/g;' "${OUT}.md"
perl -pi.bak -e 's/workstations\/56/ch03.html#ch03lev3sec7/g;' "${OUT}.md"
perl -pi.bak -e 's/\/28/\/ch02.html#ch02lev2sec1/g;' "${OUT}.md"
perl -pi.bak -e 's/\/ch31\.html\)/\/ch31.html#ch31lev2sec5\)/g;' "${OUT}.md"
perl -pi.bak -e 's/\/ch05\.html\)/\/ch05.html#ch05lev2sec13\)/g;' "${OUT}.md"
perl -pi.bak -e 's/page_276\)/ch11lev2sec2\)/g;' "${OUT}.md"
perl -pi.bak -e 's/page_284\)/ch11sb11\)/g;' "${OUT}.md"
perl -pi.bak -e 's/page_288\)/ch11sb14\)/g;' "${OUT}.md"
perl -pi.bak -e 's/page_293\)/ch11lev3sec11\)/g;' "${OUT}.md"
perl -pi.bak -e 's/page_298\)/ch11lev3sec13\)/g;' "${OUT}.md"
perl -pi.bak -e 's/page_308\)/ch11lev3sec16\)/g;' "${OUT}.md"
perl -pi.bak -e 's/climb-out-of-the-hole\/32/ch02.html#ch02lev2sec4/g;' "${OUT}.md"
perl -pi.bak -e 's/servers\/83/ch04.html#ch04lev2sec9/g;' "${OUT}.md"
perl -pi.bak -e 's/foundation-elements\/187/ch07.html/g;' "${OUT}.md"
perl -pi.bak -e 's/foundation-elements\/271/ch11.html/g;' "${OUT}.md"
perl -pi.bak -e 's/focus-versus-interruptions\/timemgmt-chp-2-sect-5/ch02.html#timemgmt-CHP-2-SECT-5.1/g;' "${OUT}.md"
perl -pi.bak -e 's/focus-versus-interruptions\/21/ch02.html#timemgmt-CHP-2-SECT-4/g;' "${OUT}.md"
perl -pi.bak -e 's/documentation\/timemgmt-chp-12/ch12.html/g;' "${OUT}.md"
perl -pi.bak -e 's/prioritization\/timemgmt-chp-8/ch08.html/g;' "${OUT}.md"
perl -pi.bak -e 's/automation\/174/ch13.html/g;' "${OUT}.md"
perl -pi.bak -e 's/^.*\.title\}$//g;' "${OUT}.md"
perl -pi.bak -e 's/^# ("Ok, but... where do I start\?")$/## \1/g;' "${OUT}.md"
perl -pi.bak -e 's/^# (How do users get help|What is an emergency|What is supported)\?$/#### \1\?/g;' "${OUT}.md"
perl -pi.bak -e 's/^width="1" height="1"\}$//g;' "${OUT}.md"
perl -00 -pi.bak -e 's/\n{4,}/\n\n/g;' "${OUT}.md"

# ------------------
# Output Generation
# ------------------

# Convert Markdown to html, epub, and pdf with a table of contents
for suffix in html epub pdf; do \
  pandoc -s --toc --variable 'geometry:margin=1in' -o "${OUT}.${suffix}" \
    "${OUT}.md"
done

# Remove old files, if any
rm -f *.bak ?.md ??.md {head,about,contact,home,tipjar}.md
