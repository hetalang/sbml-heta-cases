# SBMLCases

The package is designed to test Simulation Software against [SBML Test Suite](https://github.com/sbmlteam/sbml-test-suite) cases in Julia.

## Overview

SBMLCases.jl contains:
- [SBML Test Suite](https://github.com/sbmlteam/sbml-test-suite) cases in `cases_path = "./cases/semantic"`. The original Matlab models were converted to Julia with Heta compiler. Julia code for each model is stored in `./cases/semantic/<case_num>/julia`, while models' settings and tags are stored in `cases_db = "./cases.json"`.
- API (documented in the *Usage* section) to upload `cases_db`, run simulations, save results to `output_path = "./cases/output"` and update status in `results_db = "./results.json"`. A simulation can end with one of the three status: `success` indicates the output file has passed [tolerance test](https://github.com/sbmlteam/sbml-test-suite/blob/master/cases/semantic/README.md#tolerances-and-errors-for-timecourse-tests), `failure` signifies that tolerance test for a given simulation was not passed and `error` stands for any error during the simulation (error message is printed to the `message` field in `results_db`).

Currently SBMLCases.jl suport only one `SimSolver` Simulation Backend.

## Usage

SBMLCases.jl exports the following functions:

```
    upload_cases(;json::AbstractString=cases_db)

Upload cases from `cases_db`.
```

```
    add_cases(;
        cases_path::AbstractString=cases_path,
        cases_db::AbstractString=cases_db
    )

Add new cases from `cases_path` to `cases_db`.
```

```
    update_results(
        case::AbstractString,
        cases_dict::AbstractDict=upload_cases(json=cases_db);
        cases_path::AbstractString=cases_path,
        cases_db::AbstractString=cases_db,
        results_db::AbstractString=results_db,
        backend::DataType=default_backend,
        kwargs...
    )

Reads `cases_db` to `cases_dict`, accesses the `case`,
solves it with the chosen `backend` solver and writes result to `results_db`.
```

```
    update_results(
        cases_vec::Vector{String},
        cases_dict::AbstractDict=upload_cases(json=cases_db);
        cases_path::AbstractString=cases_path,
        cases_db::AbstractString=cases_db,
        results_db::AbstractString=results_db,
        backend::DataType=default_backend,
        kwargs...
    )

Reads `cases_db` to `cases_dict`, accesses the selected cases from `cases_vec`,
solves it with the chosen `backend` solver and writes results to `results_db`.
```

```
    update_results(
        cases_dict::AbstractDict=upload_cases(json=cases_db);
        include_test_tags::Vector{String}=String[],
        include_component_tags::Vector{String}=String[],
        exclude_test_tags::Vector{String}=String[],
        exclude_component_tags::Vector{String}=String[],
        cases_path::AbstractString=cases_path,
        cases_db::AbstractString=cases_db,
        results_db::AbstractString=results_db,
        backend::DataType=default_backend,
        kwargs...
    )

Reads `cases_db` to `cases_dict`, filters the cases according to `include` and `exclude` tags,
solves it with the chosen `backend` solver and writes results to `results_db`.
```
