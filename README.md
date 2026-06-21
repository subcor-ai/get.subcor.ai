# get.subcor.ai

Public distribution point for the [Subcor](https://subcor.ai) command-line
interface. This repository hosts the installer and the released CLI binaries —
**no application source lives here.**

## Install

```sh
curl -fsSL https://get.subcor.ai/install.sh | sh
```

This downloads the right binary for your platform, verifies its checksum, and
installs `subcor` to `~/.subcor/bin` (no sudo). macOS and Linux on amd64/arm64
are supported.

Signing in requires an invite; installation does not.

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

## What's here

- `install.sh` — the installer (served at `https://get.subcor.ai/install.sh`).
- `index.html` — landing page.
- Releases — CLI binaries (`subcor_<os>_<arch>.tar.gz`) and `checksums.txt`,
  published automatically from the Subcor build pipeline.

The binaries are compiled from a private source repository; only the artifacts
are public. The installer is open for inspection — issues and PRs against
`install.sh` are welcome.
