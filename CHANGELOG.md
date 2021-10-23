# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Seed words should be pasted correctly now regardless of which field it is pasted into.
- Seed words should be cleaned correctly now when changing phrase size.

## [2.0.0] - 22/10/2021
### Added
- Support for multiple ARC20 tokens (send, exchange, add/remove liquidity).
- Support for decentralized applications (DApps) in two ways:
  - Metamask-compatible DApps can connect to the Wallet's built-in websocket server.
  - Developers can make native QML DApps for the Wallet and submit them to a separate repo.
- "Developer Mode" (setting for devs to load their DApps locally for testing purposes).
- Slippage configuration in the Exchange screen.
- Component for loading async images (AVMEAsyncImage).
- Support for 24-word seed phrases and QR codes for addresses.
- (Opt-in) Setting for remembering the Wallet's passphrase for a given time when making transactions.
  - Keep in mind the password will be **unprotected** when enabling this setting.
- Contact list for sending transactions.
- Checkbox for auto-loading last opened Wallet at program startup.
- Support for using custom APIs for the Wallet and the Websocket server.
- Support for GIFs and SVGs (for DApp development).
- Right-click menu for enabled and writable inputs (cut/copy/paste, password inputs can only paste).

### Fixed
- Existing accounts no longer have a chance to be rewritten when creating new ones.
- Sending a value of 0 should be no longer possible.
- Support for unicode characters.
- Segfault caused by LevelDB not closing the right way.
- Coin prices lower than three decimals in the market chart should show correctly now.
- Library dependencies when compiling from source are better documented.
- (Most) popups and components should now properly handle focus and keyboard input.
- Overview pie chart now uses up to 16 different colors for better readability.
- Fiat and raw balance values in the Overview screen should be properly truncated now.
- Images are now properly antialiased.
- Amount displays for Staking/Compound were corrected.
- Importing a Ledger account that was already imported should be no longer possible.

### Changed
- UI has a new design (thanks to Natalya Chavez for the work!).
  - Most controls were customized to fit better with the theming.
  - **Pangolin exchange and liquidity screens were removed and converted to a DApp ("Pangolin DEX").**
  - ParaSwap exchange was added in place of Pangolin.
  - Create/Import/Load Wallet and Staking/Compound were properly separated into their own screens to avoid confusion.
- LevelDB is now being used in place of JSON files for ARC20 tokens, transaction history, registered Ledger accounts, DApps and settings.
  - This should make the wallet faster I/O-wise and fix a history duplication bug that happened with JSON files.
  - **The old JSON history file from 1.2.0 and below, if it exists, will be AUTOMATICALLY DELETED when opening the Account in 2.0.0 and above.**
- Code is now separated in a more logical way in the `src` folder.
- OpenSSL was moved to the depends system instead of being a git submodule.
- A new API for network requests is being used, with support for multiple requests (thanks to Markus for the work!).
- The JSON library was changed from [png85/json_spirit](https://github.com/png85/json_spirit) to [nlohmann/json](https://github.com/nlohmann/json).
  - (Most) network requests were also converted to be built using it instead of std::stringstream.
- Price history for assets can now be set to 1 week, 1 month or 3 months.
- Transactions which are likely to fail are now logged to the wallet's `debug.log`.
- API and Graph request loggings were disabled, which should make `debug.log` grow less over time.
- Transactions now have an extra progress step (build, sign, send and **confirm**).
- Transactions can now be optionally retried with a higher fee if they fail.
- Some hardcoded gas limits for certain operations were revised.
- Amount inputs should now permit values starting with a dot (e.g. ".01").
- Private key, Wallet seed and website permission popups were moved from the Settings screen to the Account header.
- Transaction statuses are now checked manually, and the history can be fully wiped with the press of a button.
- Token icons on Staking/Compound screens were changed to avoid confusion.

### Removed
- CLI executable for testing/debugging.
- Support for testnet (most features in the wallet only exist/work properly in the mainnet).

## [1.2.0] - 2021-06-14
### Added
- Support for compound staking (powered by YieldYak).
- Locked LP value information.

### Fixed
- Properly load transaction history.

## [1.1.0] - 2021-06-08
### Added
- Support for Ledger Nano S, Nano X and the Ethereum app.

### Changed
- Default gas limit for sending AVME has increased from 21000 to 70000.
- MacOS display DPI support.
- MacOS libraries.

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

