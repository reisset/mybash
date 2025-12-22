# MyBash V2 Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.1] - 2024-12-21

### Fixed

- **Critical Bug Fix**: Fixed nerdfetch download failure (404 error) during `--server` mode installation
  - Changed URL from `https://raw.githubusercontent.com/TadeasKriz/nerdfetch/master/nerdfetch` 
  - To `https://raw.githubusercontent.com/ThatOneCalculator/NerdFetch/main/nerdfetch`
  - Verified with HTTP 200 response

- **Syntax Error Fix**: Resolved "local: can only be used in a function" error in install.sh
  - Removed `local` keyword from line 197: `kitty_path="$(command -v kitty)"`
  - Script now passes `bash -n` syntax validation

### Changed

- **Installation Script**: Improved error handling and URL validation for external downloads
- **Documentation**: Removed deprecated DEBUGGING.txt and TODOlist.txt files
- **Code Cleanup**: Removed obsolete checksum verification references

### Security

- **URL Validation**: Enhanced GitHub URL validation in install.sh to prevent malicious downloads
- **Path Safety**: Ensured PATH modifications use safe append pattern instead of overwrite

## [2.0.0] - 2024-12-20

### Added

- **Server Mode**: Added `--server` flag for headless/server installations
- **Architecture Support**: Added ARM64/aarch64 architecture detection and support
- **New Tools**: Added support for glow, gping, and NerdFetch utilities
- **Kitty Configuration**: Added default kitty terminal opacity setting (0.90)

### Changed

- **Installation Logic**: Refactored to use conditional logic based on installation mode
- **Path Management**: Improved PATH handling to preserve existing user configurations
- **Error Handling**: Enhanced error messages and user prompts

### Removed

- **Checksum Verification**: Removed non-functional checksum verification system
- **Obsolete Documentation**: Updated SECURITY.md to remove checksum references

## [1.0.0] - 2024-11-15

### Added

- Initial MyBash V2 release
- Core installation script with basic tool setup
- Configuration files for kitty, starship, and delta
- Custom bash aliases and functions

[Unreleased]: https://github.com/king/mybash/compare/v2.0.1...HEAD
[2.0.1]: https://github.com/king/mybash/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/king/mybash/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/king/mybash/releases/tag/v1.0.0