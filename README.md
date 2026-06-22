# Subcor CLI Installer (get.subcor.ai)

This is the official distribution channel for the Subcor CLI binaries. This
repository hosts both the Subcor CLI installer script and the released CLI
binaries.

## Install using Installer (recommended)

```sh
curl -fsSL https://get.subcor.ai/install.sh | sh
```

This downloads the right binary for your platform, verifies its checksum, and
installs `subcor` to `~/.subcor/bin` (no sudo required).

### Supported Platforms

| Platform | Architectures    |
| -------- | ---------------- |
| Linux    | `amd64`, `arm64` |
| macOS    | `amd64`, `arm64` |

Windows is not currently supported.

### Options

| Environment variable    | Effect                                                        |
| ----------------------- | ------------------------------------------------------------- |
| `SUBCOR_VERSION`        | Install an exact version (e.g. `SUBCOR_VERSION=1.4.0`)         |
| `SUBCOR_INSTALL`        | Install prefix (default `~/.subcor`; binary in `<prefix>/bin`) |
| `SUBCOR_NO_MODIFY_PATH` | Skip editing your shell profile                               |

### Uninstall

```sh
rm -rf ~/.subcor
```

…and remove the `# subcor (managed)` block from your shell profile
(`~/.zshrc`, `~/.bashrc`/`~/.bash_profile`, or `~/.config/fish/config.fish`).

## Install with Homebrew (macOS)

```sh
brew install subcor-ai/tap/subcor
```

Or in two steps:

```sh
brew tap subcor-ai/tap
brew install subcor
```

Upgrade with `brew upgrade subcor`; remove with `brew uninstall subcor`. Homebrew
installs are macOS only — on Linux, use the installer above. This pulls the same
binary as the installer, from the [tap](https://github.com/subcor-ai/homebrew-tap).

## Manual installation

Each release is a single self-contained executable — if you'd rather not run the
installer, download it and drop it anywhere on your `PATH`. Grab your platform's
asset from the [latest release](https://github.com/subcor-ai/get.subcor.ai/releases/latest):

Example for macOS `arm64`:

```sh
curl -LO https://github.com/subcor-ai/get.subcor.ai/releases/latest/download/subcor_darwin_arm64.tar.gz
tar -xzf subcor_darwin_arm64.tar.gz
mv subcor /usr/local/bin/
subcor --version
```

Optionally, verify the download against the published checksums first:

```sh
curl -LO https://github.com/subcor-ai/get.subcor.ai/releases/latest/download/checksums.txt
shasum -a 256 -c checksums.txt --ignore-missing
```

Asset names are `subcor_<os>_<arch>.tar.gz` (`os`: `darwin`, `linux`; `arch`:
`amd64`, `arm64`). On Linux, use `sha256sum -c` in place of `shasum -a 256 -c`.

## What's here

- `install.sh` — the installer (served at `https://get.subcor.ai/install.sh`).
- `index.html` — landing page.
- Releases — CLI binaries (`subcor_<os>_<arch>.tar.gz`) and `checksums.txt`,
  published automatically from the Subcor build pipeline.

The binaries are compiled from a private source repository; only the artifacts
are public. The installer is open for inspection — issues and PRs against
`install.sh` are welcome.
