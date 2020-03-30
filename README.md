[![Build](https://github.com/uroesch/KeyStoreExplorerPortable/workflows/build-package/badge.svg)](https://github.com/uroesch/KeyStoreExplorerPortable/actions?query=workflow%3Abuild-package)
[![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/uroesch/KeyStoreExplorerPortable?include_prereleases)](https://github.com/uroesch/KeyStoreExplorerPortable/releases)
[![Runs on](https://img.shields.io/badge/runs%20on-Win64%20%26%20Win32-blue)](#runtime-dependencies)
[![Depends on](https://img.shields.io/badge/runs%20on-Java-blue)](#runtime-dependencies)

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
  [OpenJDK JRE](https://portableapps.com/apps/utilities/OpenJDKJRE),
  [OpenJDK](https://portableapps.com/apps/utilities/OpenJDK),
  [JRE](https://portableapps.com/apps/utilities/java_portable) or
  [JDK](https://portableapps.com/apps/utilities/jdkportable) 
  

## Status 
This PortableApp project is in early beta stage. 

## Todo
- [ ] Documentation
- [x] Icons
- [x] Download script for updating

## Build

### Prerequisites

* [PortableApps.com Launcher](https://portableapps.com/apps/development/portableapps.com_launcher)
* [PortableApps.com Installer](https://portableapps.com/apps/development/portableapps.com_installer)
* [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7)
* [Wine (Linux / MacOS only)](https://www.winehq.org/)

### Build

To build the installer run the following command in the root of the git repository.

```
powershell Other/Update/Update.ps1
```
