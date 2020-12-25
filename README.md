[![Build](https://github.com/uroesch/KeyStoreExplorerPortable/workflows/build-package/badge.svg)](https://github.com/uroesch/KeyStoreExplorerPortable/actions?query=workflow%3Abuild-package)
[![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/uroesch/KeyStoreExplorerPortable?include_prereleases)](https://github.com/uroesch/KeyStoreExplorerPortable/releases)
[![Runs on](https://img.shields.io/badge/runs%20on-Win64%20%26%20Win32-blue)](#runtime-dependencies)
[![Depends on](https://img.shields.io/badge/depends%20on-Java-blue)](#runtime-dependencies)

# KeyStore Explorer Portable for PortableApps.com

<img src="App/AppInfo/appicon_128.png" align=left>

[KeyStore Explorer](https://keystore-explorer.org/) is an open source GUI 
replacement for the Java command-line utilities keytool and jarsigner. 
KeyStore Explorer presents their functionality, and more, via an intuitive 
graphical user interface.

KeyStore Explorer is written in Java and will run on any machine that 
has an Oracle JRE installed. Its capabilities are therefore available on 
Windows, macOS and Linux.

## Runtime dependencies
* 32-bit or 64-bit version of Windows.
* 32-bit version of Java e.g.
  [JRE](https://portableapps.com/apps/utilities/java_portable) or
  [JDK](https://portableapps.com/apps/utilities/jdkportable) 

## Support matrix

| OS              | 32-bit             | 64-bit              | 
|-----------------|:------------------:|:-------------------:|
| Windows XP      | ![nd][nd]          | ![nd][nd]           | 
| Windows Vista   | ![ps][ps]          | ![ps][ps]           | 
| Windows 7       | ![fs][fs]          | ![ps][ps]           |  
| Windows 8       | ![ps][ps]          | ![ps][ps]           |  
| Windows 10      | ![fs][fs]          | ![fs][fs]           |

Legend: ![ns][ns] not supported;  ![nd][nd] no data; ![ps][ps] supported but not verified; ![fs][fs] verified;
  

## Status 
This PortableApp project is in early beta stage. 

## Todo
- [ ] Documentation
- [x] Make work with OpenJDK Portable
- [x] Icons
- [x] Download script for updating


<!-- Start include INSTALL.md -->
## Installation

The Packages found under the release page are not digitally signed so there the installation
is a bit involved.

After download the `.paf.exe` installer trying to install may result in a windows defender
warning.

<img src="Other/Images/info_defender-protected.png" width="260">

To unblock the installer and install the application follow the annotated screenshot below.

<img src="Other/Images/howto_unblock-file.png" width="600">

1. Right click on the executable file.
2. Choose `Properties` at the bottom of the menu.
3. Check the unblock box.
<!-- End include INSTALL.md -->

<!-- Start include BUILD.md -->
### Build

#### Windows 10

To build the installer run the following command in the root of the git
repository.

```
powershell -ExecutionPolicy ByPass -File Other/Update/Update.ps1
```

#### Linux (Docker)

Note: This is currently the preferred way of building.

For a Docker build run the following command.

```
curl -sJL https://raw.githubusercontent.com/uroesch/PortableApps/master/scripts/docker-build.sh | bash
```

#### Linux (Wine)

To build the installer under Linux with Wine and PowerShell installed run the
command below.

```
pwsh Other/Update/Update.ps1
```
<!-- End include BUILD.md -->

[nd]: Other/Icons/no_data.svg
[ns]: Other/Icons/no_support.svg
[ps]: Other/Icons/probably_supported.svg
[fs]: Other/Icons/full_support.svg
