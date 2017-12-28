# OpsReportCardBook

Compile the [OpsReportCard](http://www.opsreportcard.com) into various book 
formats. This has only been tested on Ubuntu Linux 14.04 and 17.04, macOS 
High Sierra, and Windows 10 Enterprise. 

## Quick Start

1. Make sure you have wget, perl, xmllint, pandoc, and R installed and working.
2. Also, make sure you have a working LaTeX environment in order to output PDF.
2. Get the contents of this repository using `git clone`, etc.
3. From Bash, enter your local folder containing this repository, and then run:

```
bash ./makebook.sh
```

## Dependency Hints for Ubuntu Linux

If you are using Ubuntu Linux, you may want to install some packages 
and set an environment variable for R before you run `makebook.sh`. The 
environment variable setting assumes that you have installed a recent 
version of RStudio using the installer available from the RStudio 
website and that you installed it using the default destinations.
This environment variable will be ignored if you don't have RStudio.

```
sudo apt update
sudo apt install pandoc texlive texlive-latex-extra xmlstarlet libxml2-utils
export RSTUDIO_PANDOC=/usr/lib/rstudio/bin/pandoc
```

## Dependency Hints for macOS

If you are using macOS, you may want to install the `wget`, `pandoc`, 
`xmlstarlet` and `basictex` packages with [brew](https://brew.sh/) before 
running `makebook.sh`.

```
brew install wget --with-libressl
brew install pandoc
brew install xmlstarlet
brew cask install basictex
sudo tlmgr update --self
sudo tlmgr install collection-fontsrecommended
sudo tlmgr install titling
sudo tlmgr install lastpage
```

## Dependency Hints for Windows

While it is possible to get this work in Windows, it is time consuming to get 
all of the dependencies installed. It may not be worth your time. If you 
really want to try it, you will need [Git](https://git-scm.com/download/win), 
[Wget](http://gnuwin32.sourceforge.net/packages/wget.htm), [Pandoc](https://pandoc.org/installing.html#windows), 
[R](https://cran.r-project.org/bin/windows/base/), [RTools](https://cran.r-project.org/bin/windows/Rtools/index.html), 
[RStudio Desktop](https://www.rstudio.com/products/rstudio/download/), several 
[XML utilities](http://xmlsoft.org/sources/win32/) (iconv, zlib, libxml2, and 
libxmlsec), and [MiKTeX](https://miktex.org/download). From MiKTeK's package 
manager, you will need to install "titling" and "lastpage". And you will need
to modify your PATH with something like this:

```
set PATH=%PATH%;C:\Program Files\Git\bin;C:\Program Files (x86)\Pandoc;C:\XML\bin
set PATH=%PATH%;C:\Program Files\R\R-3.4.2\bin;C:\Rtools\bin
set PATH=%PATH%;C:\Program Files (x86)\GnuWin32\bin
set PATH=%PATH%;C:\Program Files\MiKTeX 2.9\miktex\bin\x64
```

First try running `makebook.sh` from within RStudio. If that fails, run `render.R` 
from within RStudio. That should bring a few more packaes into your R environment.
Then you can open a Gitbash shell and run `makebook.sh` from there. At least, that's
what worked for us. As you can see, this is much more complicated than with Linux or 
macOS, so we do not recommend this approach. Consider yourself warned!

## Note about Epub Conversion

If you have `ebook-convert` (from the `calibre` package) in your PATH,
then `makebook.sh` will use this. Otherwise, `pandoc` will be used. The 
reason `ebook-convert` is preferred is that it does a better job with the 
table of contents and makes a nicer cover.

