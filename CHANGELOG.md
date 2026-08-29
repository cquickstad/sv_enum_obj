# Changelog

## [0.2.1]
### Fixed
- README typo
- Possible unprotected indexing into empty _values[] array.

## [0.2.0]
### Fixed
- `prev()` wrapped from index 1 instead of going to index 0.
- Same name, but different values.
- Prevent $stacktrace from failing non-Cadence simulators.
### Added
- Updated documentation

## [0.1.0] - 2026-08-28
### Added
- Holder/singleton enum objects, INST/EXTEND macros, optional UVM factory.
### Known limitations
- Tested on Xcelium + Accellera UVM 1.2 only.