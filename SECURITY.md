# Security Policy

## Overview

MyBash V2 is a Bash environment configuration tool that downloads and installs third-party software from the internet. This document outlines the security measures implemented and considerations for users.

## Security Measures Implemented

### 1. URL Validation
All downloads from GitHub are validated to ensure:
- URLs use HTTPS protocol
- URLs originate from `github.com` domain
- Prevents arbitrary URL injection attacks

### 2. Download Integrity
- **Checksum Verification**: Optional SHA256 checksum verification for downloaded files
- **GPG Key Handling**: GPG keys are downloaded to temporary locations before import
- **Error Handling**: Failed downloads abort the installation process

### 3. Script Execution Safety
- **No Direct Piping**: External scripts are downloaded first, then executed (not piped directly to shell)
- **Explicit Permissions**: Downloaded scripts are made executable only when needed
- **Cleanup**: Temporary files are removed after installation

### 4. Privilege Management
- **User Confirmation**: Sudo usage requires explicit user consent
- **Graceful Fallback**: Can install tools locally without sudo when unavailable
- **Minimal Privileges**: Only requests elevated privileges when necessary

### 5. Code Quality
- **Error Exit**: `set -e` ensures script exits on errors
- **Quoted Variables**: Prevents word splitting and glob expansion vulnerabilities
- **Input Validation**: User responses are validated before use

## Security Considerations for Users

### Before Installation

1. **Review the Code**: Always review `install.sh` and other scripts before running them
2. **Understand Dependencies**: This installer downloads software from:
   - GitHub releases (official repositories)
   - Official package repositories (apt)
   - Starship.rs (official Starship installer)
   - deb.gierens.de (eza community repository)

3. **Check Your Environment**: Ensure you're installing on a system you control

### Trust Chain

This installer relies on the security of:
- **GitHub**: For hosting official releases
- **Package Maintainers**: For official apt repositories
- **HTTPS/TLS**: For secure transmission
- **DNS**: For domain name resolution

### Recommended Practices

1. **Run on Trusted Networks**: Avoid running installer on untrusted/public networks
2. **Inspect Downloads**: Optionally verify checksums manually for critical tools
3. **Use Dedicated User**: Consider using a dedicated user account for testing
4. **Backup First**: Backup existing `.bashrc` and config files before installation

## Known Limitations

1. **Checksum Availability**: Not all GitHub releases provide checksums
2. **GPG Key Distribution**: GPG keys are fetched from the same sources as the software
3. **Third-Party Trust**: Security depends on the security of upstream projects

## Reporting Security Issues

If you discover a security vulnerability in MyBash V2:

1. **DO NOT** open a public issue
2. Email the maintainer with:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Version Support

Security updates will be provided for:
- Latest version on main branch
- Previous release (if applicable)

## Security Best Practices for Contributors

If you contribute to this project:

1. **Never commit secrets**: No API keys, passwords, or tokens
2. **Validate inputs**: Always validate user inputs and external data
3. **Use secure downloads**: HTTPS only, validate sources
4. **Document security implications**: Note security considerations in PR descriptions
5. **Test error conditions**: Ensure errors fail safely

## Audit History

- **2025-12-19**: Initial security audit and hardening
  - Added URL validation
  - Implemented checksum verification
  - Fixed curl pipe-to-shell pattern
  - Improved GPG key handling
  - Added comprehensive security documentation

## Additional Resources

- [OWASP Bash Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Shell_Script_Security_Cheat_Sheet.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [ShellCheck](https://www.shellcheck.net/) - Shell script static analysis tool

## Disclaimer

This software is provided "as is" without warranty of any kind. Users install and use this software at their own risk. Always review code before executing it with elevated privileges.
