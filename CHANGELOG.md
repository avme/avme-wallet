# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- "Copy to Clipboard" button and "Address:" label in the Account header.
- Confirmation popup before making a transaction.
- Warning message in the confirmation popup when sender and receiver Accounts are the same.
- Project version now shows up in the window bar and the About screen.

### Changed
- Seed popup at Wallet creation should be less confusing now (no extra disabled controls).
- About popup is now a screen of its own, fitting better with the wallet's design.
- Better color contrast between button states.

### Fixed
- Market graph legends now shouldn't be cut off anymore (e.g. "05/..." instead of "05/03").
- **Linux:** redefine fontconfig path that made the program hang on startup.
- **Windows:** proper high DPI scaling using QT\_SCALE\_FACTOR.
- Fiat pricings in the overview are now properly rounded to two decimals.
  - This fixes balances being shown as scientific notations (e.g. "$3.4717e-16" instead of "$3.47").

## [0.1.0] - 2021-05-01
### Added
- Initial open beta release.

