# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2021-06-14
### Added
- Support for compound Staking.
- Locked LP value information.

### Fixed
- Properly load transaction history

## [1.1.0] - 2021-06-08
### Added
- Support for Ledger Nano S, Nano X and the Ethereum app.

### Changed
- Default gas limit for sending AVME has increased from 21000 to 70000.
- MacOS Display DPI support
- MacOS Libraries

### Fixed
- Project version should show up again at window title bar and the About screen.
- Market chart should now auto-reload its data along with the rest in the Overview screen.
- Tx confirmation popup should now focus automatically and accept Enter key as input.

## [1.0.0] - 2021-06-02
### Added
- Official release.
- Support for MacOS Big Sur.
- Base libs for Ledger support (not implemented yet).
- Toggle for mainnet and testnet when compiling from source.
  - `cmake -DTESTNET=ON`, this is off by default.

### Fixed
- Input logic on Send screen.
  - Coin/token amount regex should enable amounts like ".05" now.
  - Receiver address is now checked for input correctness.

## [0.1.1] - 2021-05-11
### Added
- "Copy to Clipboard" button and "Address:" label in the Account header.
- Confirmation popup before making a transaction.
- Warning message in the confirmation popup when sender and receiver Accounts are the same.
- Project version now shows up in the window bar and the About screen.
- Support for replay protection ([EIP-155](https://eips.ethereum.org/EIPS/eip-155)).

### Changed
- Wallet creation screen should be more intuitive/less confusing now.
  - "View seed" popup doesn't have leftover disabled controls anymore.
  - "View passphrase" checkbox was replaced with a button.
  - "Use default path" checkbox was removed.
  - "Confirm passphrase" input now has a visual check.
  - Folder and passphrase buttons now have icons.
- About popup is now a screen of its own, fitting better with the wallet's design.
- Better color contrast between button states.
- Pangolin's [Graph](https://api.thegraph.com/subgraphs/name/dasconnor/pangolin-dex) endpoint has been changed.
  - The old one is functional but has been deprecated and won't receive further updates.

### Removed
- Boost::log as a dependency (the removal helps with MacOS compiling).

### Fixed
- Market graph legends now shouldn't be cut off anymore (e.g. "05/..." instead of "05/03").
- **Linux:** redefine fontconfig path that made the program hang on startup.
- **Windows:** proper high DPI scaling using QT\_SCALE\_FACTOR.
- Fiat pricings in the overview are now properly rounded to two decimals.
  - This fixes balances being shown as scientific notations (e.g. "$3.4717e-16" instead of "$3.47").
- Gas checkboxes now don't lose their predefined values anymore when clicking too fast.

## [0.1.0] - 2021-05-01
### Added
- Initial open beta release.

