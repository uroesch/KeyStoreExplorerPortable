# -----------------------------------------------------------------------------
# Description: Generic Update Script for PortableApps
# Author: Urs Roesch <github@bun.ch>
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Globals
# -----------------------------------------------------------------------------
$Version        = "0.0.9-alpha"
$AppRoot        = "$PSScriptRoot\..\.."
$AppDir         = "$AppRoot\App"
$AppInfoDir     = "$AppDir\AppInfo"
$AppInfoIni     = "$AppInfoDir\appinfo.ini"
$UpdateIni      = "$AppInfoDir\update.ini"
$Debug          = $True

# -----------------------------------------------------------------------------
# Classes
# -----------------------------------------------------------------------------
Class IniConfig {
  [string] $File
  [object] $Table
  [bool]   $Verbose = $False
  [bool]   $Parsed  = $False

  IniConfig(
    [string] $f
  ) {
    $This.File = $f
  }

  [void] Log([string] $Message) {
    If ($This.Verbose) {
      Write-Host "IniConfig: $Message"
    }
  }

  [void] Parse() {
    If ($this.Parsed) { return }
    $Content  = Get-Content $This.File
    $Section  = ''
    $This.Log($Content)
    $This.Table = @()
    Foreach ($Line in $Content) {
      $This.Log("Processing '$Line'")
      If ($Line[0] -eq ";") {
        Debug("Skip comment line")
      }
      ElseIf ($Line[0] -eq "[") {
        $Section = $Line -replace "[\[\]]", ""
        $This.Log("Found new section: '$Section'")
      }
      ElseIf ($Line -like "*=*") {
        $This.Log("Found Keyline")
        $This.Table += @{
          Section  = $Section
          Key      = $Line.split("=")[0].Trim()
          Value    = $Line.split("=")[1].Trim()
        }
      }
    }
    $This.Parsed = $True
  }

  [object] Section([string] $Key) {
    $This.Parse()
    $Section = @{}
    Foreach ($Item in $This.Table) {
      If ($Item["Section"] -eq $Key) {
        $Section += @{ $Item["Key"] = $Item["Value"] }
      }
    }
    return $Section
  }
}
# -----------------------------------------------------------------------------
Class Download {
  [string] $URL
  [string] $ExtractName
  [string] $TargetName
  [string] $Checksum
  [string] $DownloadDir = "$PSScriptRoot\..\..\Download"

  Download(
    [string] $u,
    [string] $en,
    [string] $tn,
    [string] $c
  ){
    $This.URL         = $u
    $This.ExtractName = $en
    $This.TargetName  = $tn
    $This.Checksum    = $c
  }

  [string] Basename() {
    $Elements = $This.URL.split('/')
    $Basename = $Elements[$($Elements.Length-1)]
    return $Basename
  }

  [string] ExtractTo() {
    # If Extract name is empty the downloaded archive has all files
    # placed in the root of the archive. In that case we use the
    # TargetName and and attach it to the script location
    If ($This.ExtractName -eq "") {
      return "$($This.DownloadDir)\$($This.TargetName)"
    }
    return $This.DownloadDir
  }

  [string] MoveFrom() {
    If ($This.ExtractName -eq "") {
      return "$($This.DownloadDir)\$($This.TargetName)"
    }
    return "$($This.DownloadDir)\$($This.ExtractName)"
  }

  [string] MoveTo() {
    return "$PSScriptRoot\..\..\App\$($This.TargetName)"
  }

  [string] OutFile() {
    return "$($This.DownloadDir)\$($This.Basename())"
  }
}

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
Function Debug() {
  param( [string] $Message )
  If (-Not($Debug)) { return }
  Write-Host $Message
}

# -----------------------------------------------------------------------------
Function Is-Unix() {
  ($PSScriptRoot)[0] -eq '/'
}

# -----------------------------------------------------------------------------
Function Check-Sum {
  param(
    [object] $Download
  )
  ($Algorithm, $Sum) = $Download.Checksum.Split(':')
  $Result = (Get-FileHash -Path $Download.OutFile() -Algorithm $Algorithm).Hash
  Debug "Checksum of INI ($Sum) and downloaded file ($Result)"
  return ($Sum -eq $Result)
}

# -----------------------------------------------------------------------------
Function Download-File {
  param(
    [object] $Download
  )
  If (!(Test-Path $Download.DownloadDir)) { 
    Debug "Creating directory $($Download.DownloadDir)"G 
    New-Item -Path $Download.DownloadDir -Type directory | Out-Null
  }
  If (!(Test-Path $Download.OutFile())) {
    Debug "Download URL $($Download.URL) to $($Download.OutFile()).part"
    Invoke-WebRequest -Uri $Download.URL `
      -OutFile "$($Download.OutFile()).part"

    Debug "Moving file '$($Download.OutFile).part to $($Download.OutFile())"
    Move-Item -Path "$($Download.OutFile()).part" `
      -Destination $Download.OutFile()
  }
  If (!(Check-Sum -Download $Download)) {
    Debug "Checksum of File $($Download.OutFile()) not match with '$Checksum'"
    Exit 1
  }
  Debug "Downloaded file '$($Download.OutFile())'"
}

# -----------------------------------------------------------------------------
Function Expand-Download {
  param(
    [object] $Download
  )
  If (!(Test-Path $Download.ExtractTo())) {
    Debug "Creating extract directory $($Download.ExtractTo())"
    New-Item -Path $Download.ExtractTo() -Type "directory" | Out-Null
  }
  Debug "Extract $($Download.OutFile()) to $($Download.ExtractTo())"
  Expand-Archive -LiteralPath $Download.OutFile() `
    -DestinationPath $Download.ExtractTo() -Force
}

# -----------------------------------------------------------------------------
Function Update-Release {
  param(
    [object] $Download
  )
  Switch -regex ($Download.Basename()) {
    '\.[Zz][Ii][Pp]$' {
      Expand-Download -Download $Download
      break
    }
  }
  If (Test-Path $Download.MoveTo()) {
    Debug "Cleanup $($Download.MoveTo())"
    Remove-Item -Path $Download.MoveTo() `
      -Force `
      -Recurse
  }
  Debug "Move release from $($Download.MoveFrom()) to $($Download.MoveTo())"
  Move-Item -Path $Download.MoveFrom() `
    -Destination $Download.MoveTo() `
    -Force
}

# -----------------------------------------------------------------------------
Function Update-Appinfo-Item() {
  param(
    [string] $IniFile,
    [string] $Match,
    [string] $Replace
  )
  If (Test-Path $IniFile) {
    Debug "Updating INI File $IniFile with $Match -> $Replace"
    $Content = (Get-Content $IniFile)
    $Content -replace $Match, $Replace | `
      Out-File -Encoding UTF8 -FilePath $IniFile
  }
}

# -----------------------------------------------------------------------------
Function Update-Appinfo() {
  $Version = $Config.Section("Version")
  Update-Appinfo-Item `
    -IniFile $AppInfoIni `
    -Match '^PackageVersion\s*=.*' `
    -Replace "PackageVersion=$($Version['Package'])"
  Update-Appinfo-Item `
    -IniFile $AppInfoIni `
    -Match '^DisplayVersion\s*=.*' `
    -Replace "DisplayVersion=$($Version['Display'])"
}

# -----------------------------------------------------------------------------
Function Update-Application() {
  $Archive = $Config.Section('Archive')
  $Position = 1
  While ($True) {
    If (-Not ($Archive.ContainsKey("URL$Position"))) {
      Break
    }
    $Download  = [Download]::new(
      $Archive["URL$Position"],
      $Archive["ExtractName$Position"],
      $Archive["TargetName$Position"],
      $Archive["Checksum$Position"]
    )
    Download-File -Download $Download
    Update-Release -Download $Download
    $Position += 1
  }
}

# -----------------------------------------------------------------------------
Function Postinstall() {
  $Postinstall = "$PSScriptRoot\Postinstall.ps1"
  If (Test-Path $Postinstall) {
    . $Postinstall
  }
}
# -----------------------------------------------------------------------------
Function Windows-Path() {
  param( [string] $Path )
  $Path = $Path -replace ".*drive_(.)", '$1:' 
  $Path = $Path.Replace("/", "\")
  return $Path
}

# -----------------------------------------------------------------------------
Function Create-Launcher() {
  Set-Location $AppRoot
  $AppPath  = (Get-Location)
  Try {
    Invoke-Helper -Command `
      "..\PortableApps.comLauncher\PortableApps.comLauncherGenerator.exe"
  }
  Catch {
    "FATAL: Unable to create PortableApps Launcher"
    Exit 21
  }
}

# -----------------------------------------------------------------------------
Function Create-Installer() {
  Try {
    Invoke-Helper -Sleep 5 -Command `
      "..\PortableApps.comInstaller\PortableApps.comInstaller.exe"
  }
  Catch {
    "FATAL: Unable to create installer for PortableApps"
    Exit 42
  }
}

# -----------------------------------------------------------------------------
Function Invoke-Helper() {
  param(
    [string] $Command,
    [int]    $Sleep = $Null
  )

  Set-Location $AppRoot
  $AppPath   = (Get-Location)

  If (Is-Unix) {
    Debug "Running PA Command: wine $Command $(Windows-Path $AppPath)"
    Invoke-Expression "wine $Command $(Windows-Path $AppPath)"
  }
  Else {
    # Windows seems to need a bit of break before
    # writing the file completely to disk
    Write-FileSystemCache $AppPath.Drive.Name
    If ($Sleep) {
      Debug "Waiting for filsystem cache to catch up"
      Sleep $Sleep
    }
    Debug "Running PA Command: $Command AppPath"
    Invoke-Expression "$Command $AppPath"
  }
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
$Config = [IniConfig]::new($UpdateIni)
Update-Application
Update-Appinfo
Postinstall
Create-Launcher
Create-Installer
