# Elsa Nightly

Nightly releases for Elsa

## Builds
You can find all the builds on the [releases](https://github.com/elsaland/nightly/releases) page. All builds are tagged by the date they were built. Date format is `YYYY.MM.DD`. There is also a release named `latest` which is updated everyday with the latest build.

## Install

One-line commands to install Elsa Nightly builds on your system.

#### Latest Build

**With Bash:**

```sh
curl -fsSL https://raw.githubusercontent.com/elsaland/nightly/main/install.sh | sh
```

**With PowerShell:**

```powershell
iwr https://raw.githubusercontent.com/elsaland/nightly/main/install.ps1 -useb | iex
```


## Compatibility

- The Bash installer can be used on Windows via the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about).

## Known Issues

#### Unzip is required

The program [`unzip`](https://linux.die.net/man/1/unzip) is a requirement for the Bash installer.

```sh
$ curl -fsSL https://raw.githubusercontent.com/elsaland/nightly/main/install.sh | sh
Error: unzip is required to install Elsa
```

**When does this issue occur?**

During the installation process, `unzip` is used to extract the zip archive.

**How can this issue be fixed?**

You can install unzip via `brew install unzip` on MacOS or `apt-get install unzip -y` on Linux.

## License

Elsa is licensed under the [MIT License](https://github.com/elsaland/elsa/blob/master/LICENSE). The binaries and install scripts provided through this repository are also licensed under the same license

