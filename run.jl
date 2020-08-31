#include("./src/SBMLCases.jl")
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using SBMLCases, DataStructures, JSON, Dates

cases_dict = JSON.parsefile("./cases.json"; dicttype = OrderedDict)
build_dict = JSON.parsefile("./build.log"; dicttype = OrderedDict)

### run all cases

required_time = @elapsed run_and_update_status!(
    cases_dict;
    build_dict = build_dict,
    range = 1:1780
)

#heta_version = ENV["heta_version"]
date = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
heta_version = length(ARGS) > 0 ? ARGS[1] : "unknown"
pkg = Pkg.installed()
report = Dict(
    "cases" => cases_dict,
    "required_time" => required_time,
    "date" => date,
    "heta_version" => heta_version,
    "solver" => "SimSolver"
)
if haskey(pkg, "SimSolver")
    report["solver_version"] = string(pkg["SimSolver"])
end

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
