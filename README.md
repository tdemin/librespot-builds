# Librespot builds

![GitHub release (latest by date)](https://img.shields.io/github/v/release/tdemin/librespot-builds?label=latest%20release)
[![Build Librespot](https://github.com/tdemin/librespot-builds/actions/workflows/build.yml/badge.svg)](https://github.com/tdemin/librespot-builds/actions/workflows/build.yml)

This is a repository hosting fresh builds of
[Librespot](https://github.com/librespot-org/librespot) for ARM64 (Raspberry
Pi 3/4), i686, and x86_64 for Linux. See the releases page.

This repository will reside until Librespot sets up its own automatic builds.

## Dependencies

Librespot is built with both PulseAudio and ALSA support, so you will
need to at least install `libpulse0` and `libasound2` in both use scenarios.

## Copying

For code residing in this repository, see [LICENSE](LICENSE). Librespot
itself is covered by its own
[license](https://raw.githubusercontent.com/librespot-org/librespot/dev/LICENSE).

Unpatched binary builds are provided by the [NixOS](https://nixos.org) project
and are grabbed from `https://cache.nixos.org`.
