module SBMLCases

using JSON, SimSolver, DataFrames, CSV, DataStructures

# files containing settings and tags of sbml models
const cases_db = "./cases.json"
const results_db = "./results.json"
# models' dirs and output dir paths
const cases_path = "./cases/semantic"
const output_path = "./cases/output"
# default backend
const default_backend = Val{:SimSolver}


########################## Upload cases from cases_db ########################

"""
    upload_cases(;json::AbstractString=cases_db)

Upload cases from `cases_db`.
"""
function upload_cases(;json::AbstractString=cases_db)
    f = open(json, "r")
    dict = JSON.parse(f, dicttype=OrderedDict)
    close(f)
    return dict
end


########################## Add new cases #####################################

"""
    add_cases(;
        cases_path::AbstractString=cases_path,
        cases_db::AbstractString=cases_db
    )

Add new cases from `cases_path` to `cases_db`.
"""
function add_cases(;
    cases_path::AbstractString=cases_path,
    cases_db::AbstractString=cases_db
)
    cases_dict = upload_cases(json=cases_db)
    new_cases = 0
    foreach(readdir(cases_path)) do case
        if !haskey(cases_dict, case)
            @show case
            cases_dict[case] = add_single_case(cases_path, case)
            new_cases += 1
        end
    end
    new_cases > 0 && save_as_json(cases_dict, cases_db)
    return nothing
end

function add_single_case(path::AbstractString, case::AbstractString)
    OrderedDict(
        "name" => case,
        "settings" => add_settings(path, case),
        "tags" => add_tags(path, case)
    )
end

function add_settings(path::AbstractString, case::AbstractString)
    settings = OrderedDict{String,Any}()
    open("$path/$case/$case-settings.txt", "r") do f
        for line in eachline(f)
            split_line = split(line, ":")

            k = first(split_line)
            v = last(split_line)

            if k in ["start", "duration", "absolute", "relative"]
                settings[k] = !isempty(v) ? parse(Float64, v) : nothing
            elseif k == "steps"
                settings[k] = !isempty(v) ? parse(Int64, v) : nothing
            elseif k in ["variables", "amount", "concentration"]
                settings[k] = String[]
                for v_i in split(v, ",")
                    push!(settings[k], strip(v_i))
                end
            elseif !isempty(k)
                @warn "Case $case: setting $k currently not supported"
            end
        end
    end
    return settings
end

function add_tags(path::AbstractString, case::AbstractString)
    tags = OrderedDict{String,Vector{String}}()
    tags_parsed = 0
    open("$path/$case/$case-model.m", "r") do f
        for line in eachline(f)
            split_line = split(line, ": ")
            k = strip(first(split_line))
            v = strip(last(split_line))

            if k in ["componentTags", "testTags"]
                tags[k] = String[]
                for v_i in split(v, ",")
                    push!(tags[k], strip(v_i))
                end
                tags_parsed += 1
            end
            tags_parsed == 2 && break
        end
    end
    return tags
end

########################## Save cases or results ############################

function save_as_json(dict::AbstractDict, json::AbstractString)
    #stringdata = JSON.json(dict)
    open(json, "w") do f
        JSON.print(f, dict, 4)
    end
    return nothing
 end

############# Run simulations and update results in results_db ##############

"""
    update_results(
        case::AbstractString,
        cases_dict::AbstractDict=upload_cases(json=results_db);
        cases_path::AbstractString=cases_path,
        cases_db::AbstractString=cases_db,
        results_db::AbstractString=results_db,
        backend::DataType=default_backend,
        kwargs...
    )

Reads `cases_db` to `cases_dict`, accesses the `case`,
solves it with the chosen `backend` solver and writes result to `results_db`.
"""
function update_results(
    case::AbstractString,
    cases_dict::AbstractDict=upload_cases(json=results_db);
    cases_path::AbstractString=cases_path,
    cases_db::AbstractString=cases_db,
    results_db::AbstractString=results_db,
    backend::DataType=default_backend,
    kwargs...
)
    cases_dict[case]["result"] = OrderedDict()
    try
        status = solve_case(cases_dict[case], backend; kwargs...)
        if status
            cases_dict[case]["result"]["status"] = "success"
            cases_dict[case]["result"]["message"] = ""
            println("$case...................success")
        else
            cases_dict[case]["result"]["status"] = "failure"
            cases_dict[case]["result"]["message"] = "tolerance test not passed"
            println("$case...................failure")
        end
    catch e
        cases_dict[case]["result"]["status"] = "error"
        cases_dict[case]["result"]["message"] = "Check the model: $e"
        println("$case...................error")
    finally
        save_as_json(cases_dict, results_db)
    end
    return nothing
end

"""
    update_results(
        cases_vec::Vector{String},
        cases_dict::AbstractDict=upload_cases(json=results_db);
        cases_path::AbstractString=cases_path,
        cases_db::AbstractString=cases_db,
        results_db::AbstractString=results_db,
        backend::DataType=default_backend,
        kwargs...
    )

Reads `cases_db` to `cases_dict`, accesses the selected cases from `cases_vec`,
solves it with the chosen `backend` solver and writes results to `results_db`.
"""
function update_results(
    cases_vec::Vector{String},
    cases_dict::AbstractDict=upload_cases(json=results_db);
    cases_path::AbstractString=cases_path,
    cases_db::AbstractString=cases_db,
    results_db::AbstractString=results_db,
    backend::DataType=default_backend,
    kwargs...
)

    for case in cases_vec
        update_results(
            case,
            cases_dict;
            cases_path=cases_path,
            cases_db=cases_db,
            results_db=results_db,
            backend=default_backend,
            kwargs...
        )
    end
    return nothing
end

"""
    update_results(
        cases_range::UnitRange,
        cases_dict::AbstractDict=upload_cases(json=results_db);
        cases_path::AbstractString=cases_path,
        cases_db::AbstractString=cases_db,
        results_db::AbstractString=results_db,
        backend::DataType=default_backend,
        kwargs...
    )

Reads `cases_db` to `cases_dict`, accesses the selected cases from `cases_range`,
solves it with the chosen `backend` solver and writes results to `results_db`.
"""
function update_results(
    cases_range::UnitRange,
    cases_dict::AbstractDict=upload_cases(json=results_db);
    cases_path::AbstractString=cases_path,
    cases_db::AbstractString=cases_db,
    results_db::AbstractString=results_db,
    backend::DataType=default_backend,
    kwargs...
)
    for case in cases_range
        update_results(
            lpad(case, 5, "0"),
            cases_dict;
            cases_path=cases_path,
            cases_db=cases_db,
            results_db=results_db,
            backend=default_backend,
            kwargs...
        )
    end
    return nothing
end

"""
    update_results(
        cases_dict::AbstractDict=upload_cases(json=results_db);
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
"""
function update_results(
    cases_dict::AbstractDict=upload_cases(json=results_db);
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
    cases_vec = isempty(include_test_tags) &&
                isempty(include_component_tags) &&
                isempty(exclude_test_tags) &&
                isempty(exclude_component_tags) ? cases_dict.keys :
                    filter_cases(cases_dict;
                        include_test_tags=include_test_tags,
                        include_component_tags=include_component_tags,
                        exclude_test_tags=exclude_test_tags,
                        exclude_component_tags=exclude_component_tags,
                    )
    update_results(
        cases_vec,
        cases_dict;
        cases_path=cases_path,
        cases_db=cases_db,
        results_db=results_db,
        backend=default_backend,
        kwargs...
    )
end

# solve single model with SimSolver backend
function solve_case(
    case::AbstractDict,
    backend::Type{Val{:SimSolver}}=default_backend;
    cases_path::AbstractString=cases_path,
    output_path::AbstractString=output_path,
    alg::Symbol=:Vern9
)
    case_name = case["name"]
    file_path = "$cases_path/$case_name/julia/model.jl"
    isfile(file_path) ? include(file_path) : "julia model for $case_name doesn't exist"

    model = eval_model(SBMLCases.julia.models)

    tspan = (case["settings"]["start"],case["settings"]["duration"])
    step = (case["settings"]["duration"]-case["settings"]["start"])/case["settings"]["steps"]

    #outputs
    outputs = Symbol[]
    for v in case["settings"]["variables"]
        if v in case["settings"]["amount"]
            push!(outputs, Symbol(v*"_"))
        else
            push!(outputs, Symbol(v))
        end
    end

    # add step option to SimSolver
    saveat = collect(range(case["settings"]["start"],case["settings"]["duration"]; step=step))
    subtask = SubTask(saveat, outputs)

    solver = Dict(
        :alg=>alg,
        :reltol=>case["settings"]["relative"],
        :abstol=>case["settings"]["absolute"],
        #:maxiters => 10^5,
        #:dtmax => step/2
    )

    stask = SimpleSTask(
        model,
        NamedTuple(),
        subtask,
        tspan,
        solver=solver,
        evt_save=(false,false)
    )

    res = solve_task(stask)

    df_sim = DataFrame(time=res[1].axes[1].val)
    for v in outputs
        df_sim[!, v] = res[1][ids = v].data
    end
    CSV.write("$output_path/$case_name.csv",  df_sim)
    df_ans = DataFrame!(CSV.File("$cases_path/$case_name/$case_name-results.csv"))

    return compare_results(case, df_sim, df_ans)
end

# tolerance test according to:
# https://github.com/sbmlteam/sbml-test-suite/blob/master/cases/semantic/README.md#tolerances-and-errors-for-timecourse-tests
function compare_results(case::AbstractDict, df_sim::DataFrame, df_ans::DataFrame)
    (i_length,j_length) = size(df_sim)
    for i in 1:i_length
        for j in 2:j_length
            if abs(df_sim[i,j]-df_ans[i,j]) > (case["settings"]["absolute"] + case["settings"]["relative"] * abs(df_ans[i,j]))
                return false
            end
        end
    end
    return true
end

"""
    filter_cases(
        cases_dict::AbstractDict;
        include_test_tags::Vector{String}=String[],
        include_component_tags::Vector{String}=String[],
        exclude_test_tags::Vector{String}=String[],
        exclude_component_tags::Vector{String}=String[],
    )

Functions replicates the behavior of SBML Runner filter.
It filters out names of the cases which satisfy `include` and `exclude` tags.
"""
function filter_cases(
    cases_dict::AbstractDict;
    include_test_tags::Vector{String}=String[],
    include_component_tags::Vector{String}=String[],
    exclude_test_tags::Vector{String}=String[],
    exclude_component_tags::Vector{String}=String[],
)

    function include_filter_func(x)
        (!isempty(include_component_tags) ? any(in(cases_dict[x]["tags"]["componentTags"]).(include_component_tags)) : true) ||
        (!isempty(include_test_tags) ? any(in(cases_dict[x]["tags"]["testTags"]).(include_test_tags)) : true)
    end

    function exclude_filter_func(x)
        (!isempty(exclude_component_tags) ? !any(in(cases_dict[x]["tags"]["componentTags"]).(exclude_component_tags)) : true) &&
        (!isempty(exclude_test_tags) ? !any(in(cases_dict[x]["tags"]["testTags"]).(exclude_test_tags)) : true)
    end

    return filter(x->include_filter_func(x) && exclude_filter_func(x), keys(cases_dict))
end

# update functions after uploading a new model
function eval_model(model_code)
    Model(
        (cons)->Base.invokelatest(model_code.start, cons),
        (du, u, p, t)->Base.invokelatest(model_code.ode, du, u, p, t),
        [eval_event(evt) for evt in model_code.events],
        (outputIds)->Base.invokelatest(model_code.saving, outputIds),
        model_code.default_constants
    )
end

eval_event(evt::TimeEvent) = TimeEvent((cons)->Base.invokelatest(evt.condition_func, cons), (integrator)->Base.invokelatest(evt.affect_func, integrator))
eval_event(evt::DEvent) = DEvent((u, t, integrator)->Base.invokelatest(evt.condition_func, u, t, integrator), (integrator)->Base.invokelatest(evt.affect_func, integrator))
eval_event(evt::CEvent) = CEvent((u, t, integrator)->Base.invokelatest(evt.condition_func, u, t, integrator), (integrator)->Base.invokelatest(evt.affect_func, integrator))

export upload_cases, filter_cases, add_cases, update_results

end #module
