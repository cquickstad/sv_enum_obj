# Changelog

## [1.0.1]
### Fixed
- Minor documentation fixes.
- Minor code comment fixes.
- Fix benign type mismatch in static assignment.

## [1.0.0]
### Changed
- Macro DECL_SV_ENUM_OBJ_INST renamed to DECL_SV_ENUM_OBJ_ENUMERATOR. ("Inst" was poor terminology.)
- UVM support given its own specific define: SV_ENUM_OBJ_UVM (This is now explicit, compatible with all modern UVM versions, and doesn't force UVM users to accept the UVM base classes.)
- Nearly all methods renamed and many of the static methods were removed so they don't get confused with the virtual methods. (Results could be deceptive in the override case.)
- Tested with Xcelium, Questa, and VCS

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