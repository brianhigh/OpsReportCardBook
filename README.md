# OpsReportCardBook

Compile the [OpsReportCard](http://www.opsreportcard.com) into various book 
formats. This has been tested on Ubuntu Linux 14.04 and 17.04, macOS High Sierra, 
and Windows Server 2008 R2 and Windows 10 Enterprise. If this were refactored 
into something more portable like a Python script, it would be easier to run, 
but for now it is a Bash script that calls several utilities, Perl and R. The 
reason we are using R is to make it easier to produce nice PDF and HTML outputs.
By using RMarkdown, we get a nice table of contents and pretty PDF formatting 
without much effort. To support this, we need a LaTeX environment. See below.

## Quick Start

1. Make sure you have wget, perl, xmllint, pandoc, and R installed and working.
2. Also, make sure you have a working LaTeX environment in order to output PDF.
3. Get the contents of this repository using `git clone`, etc.
4. From Bash, enter your local folder containing this repository, and then run:

```
bash ./makebook.sh
```

## Dependency Hints for Ubuntu Linux

If you are using Ubuntu Linux, you may want to install some packages 
before you run `makebook.sh`. 

```
sudo apt update
sudo apt install texlive texlive-latex-extra xmlstarlet libxml2-utils
```

Get [RStudio Desktop](https://www.rstudio.com/products/rstudio/download/) 
from RStudio. When you install the `knitr` and `rmarkdown` packages in 
RStudio, they will include `pandoc`. You may need to add the folder 
containing `pandoc` to your PATH before running `makebook.sh`.

```
export PATH=/usr/lib/rstudio/bin/pandoc:$PATH
```

## Dependency Hints for macOS

If you are using macOS, you may want to install the `wget`, 
`xmlstarlet` and `basictex` packages with [brew](https://brew.sh/) before 
running `makebook.sh`.

```
brew install wget --with-libressl
brew install xmlstarlet
brew cask install basictex
sudo tlmgr update --self
sudo tlmgr install collection-fontsrecommended
sudo tlmgr install titling
sudo tlmgr install lastpage
```

## Dependency Hints for Windows

While it is possible to get this to work in Windows, it is time consuming to get 
all of the dependencies installed. It may not be worth your time. If you 
really want to try it, you will need [Git](https://git-scm.com/download/win), 
[Perl](https://www.activestate.com/activeperl/downloads), 
[Wget](http://gnuwin32.sourceforge.net/packages/wget.htm), 
[R](https://cran.r-project.org/bin/windows/base/), 
[RTools](https://cran.r-project.org/bin/windows/Rtools/index.html), 
[RStudio Desktop](https://www.rstudio.com/products/rstudio/download/), several 
[XML utilities](http://xmlsoft.org/sources/win32/) (iconv, zlib, libxml2, and 
libxmlsec), and [MiKTeX](https://miktex.org/download). From MiKTeX's package 
manager, you will need to install "titling", "lastpage", and "url". And you will 
need to modify your PATH environment variable with the equivalent of these changes:

```
set PATH=%PATH%;C:\Program Files\Git\bin;C:\XML\bin
set PATH=%PATH%;C:\Program Files\R\R-3.4.2\bin;C:\Rtools\bin
set PATH=%PATH%;C:\Program Files\RStudio\bin\pandoc
set PATH=%PATH%;C:\Program Files (x86)\GnuWin32\bin
set PATH=%PATH%;C:\Program Files\MiKTeX 2.9\miktex\bin\x64
```

Do this in "Edit the system environment variables" (Control Panel, System 
Properties, Environment Variables, System Variables) to make sure that RStudio 
will see these PATH changes. 

Make sure RStudio has the `knitr` and `rmarkdown` packages and all dependencies
installed. Then try running `makebook.sh` from within RStudio's Terminal tab in 
the Console Panel. 

```
bash ./makebook.sh
```

If you have trouble generating the html output, see "NOTE" in `makebook.sh`.

## Note about Epub Conversion

If you have `ebook-convert` (from the `calibre` package) in your PATH,
then `makebook.sh` will use this. Otherwise, `pandoc` will be used. The 
reason `ebook-convert` is preferred is that it does a better job with the 
table of contents and makes a nicer cover.

