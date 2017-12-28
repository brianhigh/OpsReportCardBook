# OpsReportCardBook

Compile the [OpsReportCard](http://www.opsreportcard.com) into various book 
formats. This has only been tested on Ubuntu Linux 14.04 and macOS High Sierra. 

## Quick Start

1. Make sure you have wget, perl, xmllint, pandoc, and R installed and working.
2. Also, make sure you have a working LaTeX environment in order to output PDF.
2. Get the contents of this repository using `git clone`, etc.
3. From Bash, enter your local folder containing this repository, and then run:

```
bash ./makebook.sh
```

## Hints for macOS

If you are using macOS, you may want to install the `wget` and `basictex` 
packages with [brew](https://brew.sh/) before running `makebook.sh`.

```
brew install wget --with-libressl
brew cask install basictex
sudo tlmgr update --self
sudo tlmgr install collection-fontsrecommended
sudo tlmgr install titling
sudo tlmgr install lastpage
```
