# Tests

Host-side unit tests for pure logic in the firmware. Built and run on a
developer machine, not on the embedded target.

## Framework

[doctest](https://github.com/doctest/doctest) v2.4.11, vendored as a git
submodule at `external/doctest`. Header-only, single-include.

## Running

```
make test
```

Produces `tests/run_tests` and executes it. Exits non-zero on any
failing assertion.

## Adding a test

Create a new `tests/test_*.cpp` file. Include `doctest.h` (the make
target adds `external/doctest/doctest` to the include path) and use
`TEST_CASE` / `CHECK` / `REQUIRE`. The `make test` target globs every
`tests/test_*.cpp` automatically.

Do not put `main()` in a new test file — `tests/test_main.cpp` already
provides the doctest entrypoint.

## Current coverage

Only pure math helpers are covered today. Most of the firmware is
tightly coupled to the global `OpenSprinkler os` instance and to
hardware/IO, which makes direct linking impractical. The goal is to
expand coverage by extracting pure logic into its own translation
units as the codebase is refactored — the framework is in place so a
new test can land alongside each refactor.
