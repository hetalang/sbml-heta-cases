#include("./src/SBMLCases.jl")

using SBMLCases, DataStructures, JSON

cases_dict = JSON.parsefile("./cases.json"; dicttype = OrderedDict)
build_dict = JSON.parsefile("./build.log"; dicttype = OrderedDict)

### run all cases

for (id, value) in collect(cases_dict)[1:5]
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

report = Dict(
    "cases" => cases_dict
)

#save_as_json(cases_dict, "./res.json")
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
