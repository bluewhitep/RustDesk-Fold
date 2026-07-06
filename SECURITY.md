# Security Policy

RustDesk Fold is an independent Android foldable-focused build based on
RustDesk. It is not an official RustDesk release.

## Supported Scope

Security reports for this repository should focus on Fold-specific Android
changes, packaging, release scripts, documentation, and dependency choices in
this repository.

The current supported release scope is:

- Android arm64 Fold builds published from this repository's GitHub Releases.
- The default branch: `foldable-split-keyboard-main`.

General RustDesk vulnerabilities that are not caused by RustDesk Fold changes
should also be reported to the upstream RustDesk project.

## Reporting a Vulnerability

Use GitHub's private vulnerability reporting flow from this repository's
Security tab when it is available.

Do not open a public issue with exploit details, private keys, credentials,
server addresses, device identifiers, or user data. If private vulnerability
reporting is not available, open a minimal public issue asking for a private
security contact path without including technical details.

Please include:

- Affected RustDesk Fold version, commit, or APK release asset name.
- Android device model, Android version, and whether the device is foldable.
- Steps to reproduce.
- Expected impact.
- Whether the issue is Fold-specific or also reproducible in official RustDesk.

## Release And Dependency Notes

RustDesk Fold release APKs are built manually from a trusted maintainer
environment. GitHub Actions and self-hosted runners are not used as the release
gate.

Known dependency-alert triage is tracked in
[SECURITY_DEPENDABOT_TRIAGE.md](SECURITY_DEPENDABOT_TRIAGE.md).
