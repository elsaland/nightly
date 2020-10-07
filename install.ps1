#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

if ($v) {
  $Version = "${v}"
}
if ($args.Length -eq 1) {
  $Version = $args.Get(0)
}

$ElsaInstall = $env:ELSA_INSTALL
$BinDir = if ($ElsaInstall) {
  "$ElsaInstall\bin"
}
else {
  "$Home\.elsa\bin"
}

$ElsaExe = "$BinDir\elsa-nightly.exe"
$Target = 'x86_64-pc-windows-msvc'

$TmpDir = if ($ElsaInstall) {
  "$ElsaInstall\tmp"
}
else {
  "$Home\.elsa\tmp"
}

$TempZip = "$TmpDir\elsa.zip"
$TempExe = "$TmpDir\elsa-windows-latest"


# GitHub requires TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ElsaUri = if (!$Version) {
  $Response = Invoke-WebRequest 'https://github.com/elsaland/nightly/releases' -UseBasicParsing
  if ($PSVersionTable.PSEdition -eq 'Core') {
    $Response.Links |
    Where-Object { $_.href -like "/elsaland/nightly/releases/download/latest/elsa-nightly-${Target}.zip" } |
    ForEach-Object { 'https://github.com' + $_.href } |
    Select-Object -First 1
  }
  else {
    $HTMLFile = New-Object -Com HTMLFile
    if ($HTMLFile.IHTMLDocument2_write) {
      $HTMLFile.IHTMLDocument2_write($Response.Content)
    }
    else {
      $ResponseBytes = [Text.Encoding]::Unicode.GetBytes($Response.Content)
      $HTMLFile.write($ResponseBytes)
    }
    $HTMLFile.getElementsByTagName('a') |
    Where-Object { $_.href -like "about:/elsaland/nightly/releases/download/latest/elsa-nightly-${Target}.zip" } |
    ForEach-Object { $_.href -replace 'about:', 'https://github.com' } |
    Select-Object -First 1
  }
}
else {
  "https://github.com/elsaland/nightly/releases/download/${Version}/elsa-nightly-${Target}.zip"
}

if (!(Test-Path $BinDir)) {
  New-Item $BinDir -ItemType Directory | Out-Null
}

if (!(Test-Path $TmpDir)) {
  New-Item $TmpDir -ItemType Directory | Out-Null
}

Invoke-WebRequest $ElsaUri -OutFile $TempZip -UseBasicParsing

if (Get-Command Expand-Archive -ErrorAction SilentlyContinue) {
  Expand-Archive $TempZip -Destination $TmpDir -Force
}
else {
  if (Test-Path $TempExe) {
    Remove-Item $TempExe
  }
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [IO.Compression.ZipFile]::ExtractToDirectory($TempZip, $TmpDir)
}

Move-Item -Path "$TempExe" -Destination "$ElsaExe"
Remove-Item -LiteralPath "$TmpDir" -Force -Recurse -ErrorAction SilentlyContinue

$User = [EnvironmentVariableTarget]::User
$Path = [Environment]::GetEnvironmentVariable('Path', $User)
if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) {
  [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User)
  $Env:Path += ";$BinDir"
}

Write-Output "Elsa (Nightly) was installed successfully to $ElsaExe"
Write-Output "Run 'elsa-nightly --help' to get started"
