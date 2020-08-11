#include("./src/SBMLCases.jl")
using Pkg
Pkg.activate(".")

using SBMLCases, DataStructures, JSON
using Dates

cases_dict = JSON.parsefile("./cases.json"; dicttype = OrderedDict)
build_dict = JSON.parsefile("./build.log"; dicttype = OrderedDict)

### run all cases

required_time = @elapsed begin
    for (id, value) in collect(cases_dict)
        build_errors = case_build_errors(
            value;
            build_dict = build_dict
        )
        value["build_errors"] = build_errors

        if (length(build_errors) == 0)
            sim_report = case_sim_result(
                value;
                cases_path = "./cases/semantic",
                output_path = "./cases/output"
            )
        else
            sim_report = Dict(
                "status" => "SKIPPED",
                "message" => "Model was not simulated because of build errors"
            )
        end

        value["result"] = sim_report
    end
end

#heta_version = ENV["heta_version"]
date = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
heta_version = length(ARGS) > 0 ? ARGS[1] : "unknown"
pkg = Pkg.installed()
report = Dict(
    "cases" => cases_dict,
    "required_time" => required_time,
    "date" => date,
    "heta_version" => heta_version,
    "simsolver_version" => string(pkg["SimSolver"])
)

open("./results.json", "w") do f
    JSON.print(f, report, 4)
end

### Draft
#=
# get report of builds
report = case_build_errors(
    cases_dict["01112"]; # 01112 00025
    build_dict = build_dict
)

# get report of simulation
report = case_sim_result(
    cases_dict["01001"];
    cases_path = "./cases/semantic", # path to models
    output_path = "./cases/output" # path to meta files
)
=#
