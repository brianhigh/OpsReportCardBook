#!/usr/bin/Rscript

# Render RMarkdown file into md, html, and pdf.

# Clear the workspace.
rm(list=ls())

# Load pacman into memory, installing as needed.
my_repo <- "http://cran.r-project.org"
if (!require("pacman")) {install.packages("pacman", repos = my_repo)}

# Load the other packages, installing as needed.
pacman::p_load(knitr, rmarkdown)

# Create .md, .html, and .pdf files
rmarkdown::render("OpsReportCard.Rmd", "pdf_document")
rmarkdown::render("OpsReportCard.Rmd", "html_document")
