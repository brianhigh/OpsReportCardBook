# OpsReportCardBook

Compile the [OpsReportCard](http://www.opsreportcard.com) into various book
formats. This has been tested on Ubuntu Linux 14.04, 17.04, 20.04, and 22.04,
macOS Sonoma, and Windows 10 Enterprise. If this were refactored
into something more portable like a Python script, it would be easier to run,
but for now it is a Bash script that calls several utilities and Perl.
To support PDF output, we use pdflatex, which requires a LaTeX environment. See below.

## Quick Start

1. Make sure you have wget, perl, xmllint, pdflatex and pandoc installed and working.
2. Also, make sure you have a working LaTeX environment in order to output PDF.
3. Get the contents of this repository using `git clone`, etc.
4. In a Bash shell, from the local folder containing this repository, run:

```
bash ./makebook.sh
```

## Dependency Hints for Ubuntu Linux

If you are using Ubuntu Linux, you may want to install some packages
before you run `makebook.sh`.

```
sudo apt update
sudo apt install pandoc texlive texlive-latex-extra xmlstarlet libxml2-utils
```

## Dependency Hints for macOS

If you are using macOS, you may want to install the `wget`, `pandoc`,
`xmlstarlet` and `basictex` packages with [brew](https://brew.sh/) before
running `makebook.sh`.

```
brew install wget
brew install pandoc
brew install xmlstarlet
brew install basictex --cask      # Restart your Terminal session after this
sudo tlmgr update --self
sudo tlmgr install collection-fontsrecommended
sudo tlmgr install titling
sudo tlmgr install lastpage
```

## Dependency Hints for Windows 10+

While it is possible to get this to work in Windows, it is time consuming to get
all of the dependencies installed. It may not be worth your time.

### Easiest Way

The easiest way will be to use [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) and follow the Linux hints above. This approach has been tested in Windows 10 with WSL2 and "Ubuntu" as installed in a `CMD.exe` session (run-as Administrator) with:

```
wsl --install -d Ubuntu
```

To get WSL to install, you may also need to install [wsl_update_x64.msi](https://learn.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package).

Then, after this completes, launch the "Ubuntu" app and run these commands:

```
sudo apt update
sudo apt install pandoc texlive texlive-latex-extra xmlstarlet libxml2-utils
```

To get those commands to work, you may need to edit `/etc/wsl.conf` to contain:

```
[network]
generatedResolvConf = false
```

And then edit `/etc/resolv.conf` to contain:

```
nameserver 8.8.8.8
```

You can edit those files with: `sudo vi {filename}` or `sudo nano {filename}`.

Then try the `apt` commands (above) again.

If all that works, then run:

```
cd ~
git clone https://github.com/brianhigh/OpsReportCardBook.git
cd ~/OpsReportCardBook
bash ./makebook.sh
```

And you should see the output in this folder in Windows File Explorer:
`\\wsl.localhost\Ubuntu\home\{username}\OpsReportCardBook` ... where {username}
would be replaced with your actual WSL Ubuntu username.

### Difficult Way

However, if you really want to try it natively in Windows, you will need
[Git](https://git-scm.com/download/win),
[Perl](https://www.activestate.com/activeperl/downloads),
[Wget](http://gnuwin32.sourceforge.net/packages/wget.htm),
[Pandoc](https://pandoc.org/installing.html#windows),
[XML utilities](http://xmlsoft.org/sources/win32/) (iconv, zlib, libxml2, and
libxmlsec), where the folders (`bin`, `include`, and `lib`) from these four XML
utilities are combined into a common parent folder, e.g. `C:\XML\`.

You will also need to install [MiKTeX](https://miktex.org/download). Then, from
MiKTeX's package manager, you will need to install "titling", "lastpage", and "url".

Lastly you will need to modify your PATH environment variable with the equivalent
of these changes:

```
set PATH=%PATH%;C:\Program Files\Git\bin;C:\XML\bin;C:\Perl\bin
set PATH=%PATH%;C:\Program Files (x86)\Pandoc;C:\Program Files (x86)\GnuWin32\bin
set PATH=%PATH%;C:\Program Files\MiKTeX 2.9\miktex\bin\x64
```

Do this in "Edit the system environment variables" (Control Panel, System
Properties, Environment Variables, System Variables) to make sure that shell
sessions will see these PATH changes.

From a fresh Git Bash shell, navigate to your local repository folder containing
`makebook.sh` and run:

```
bash ./makebook.sh
```
