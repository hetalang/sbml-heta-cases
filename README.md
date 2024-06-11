# SBML Heta Cases

The repository is designed to test different aspects of Heta formats on [SBML Test Suite](https://github.com/sbmlteam/sbml-test-suite).

[![Heta project](https://img.shields.io/badge/%CD%B1-Heta_project-blue)](https://hetalang.github.io/)
[![Autotest](https://github.com/insysbio/sbml-heta-cases/actions/workflows/convert-to-heta.yml/badge.svg)](https://insysbio.github.io/sbml-heta-cases/)
[![GitHub issues](https://img.shields.io/github/issues/insysbio/sbml-heta-cases.svg)](https://GitHub.com/insysbio/sbml-heta-cases/issues/)
[![GitHub license](https://img.shields.io/github/license/insysbio/sbml-heta-cases.svg)](https://github.com/insysbio/sbml-heta-cases/blob/master/LICENSE)

## Summary

The GitHub Actions are utilized for the automatic testing.

1. Download SBML Test Suite v3.4.0 semantic cases from https://github.com/sbmlteam/sbml-test-suite.

2. Convert files of format SBML L2V5 and L3V2 (if presented) from semantic test suite to Heta format.

3. Store the converted models and `summary.json` in the the `result` branch.

4. The statistics of the conversion and result visualization can be seen in the https://insysbio.github.io/sbml-heta-cases/

## File content

- `.github/workflows` - GitHub Actions files.
- `bash` - bash scripts for the conversion.
- `result` (temporal) - the folder with the converted models and `summary.json`.
- `static` - the folder with the static files for the GitHub Pages.
- `README.md` - the current file.

## Authors

- Evgeny Metelkin
- Ivan Borisov
