module SBMLCases

using JSON, SimSolver, DataFrames, CSV, DataStructures

const json_path = "./cases.json"
const semantic_path = "./cases/semantic"
const output_path = "./cases/output"

function add_cases(;cases_path::AbstractString=semantic_path, json_path::AbstractString=json_path)
    cases_dict = upload_cases(json=json_path)
    foreach(readdir(cases_path)) do case
        if !haskey(cases_dict, case)
            @show case
             cases_dict[case] = add_single_case(cases_path, case)
        end
    end
    save_as_json(cases_dict; json=json_path)
    return nothing
end

function add_single_case(path::AbstractString, case::AbstractString)
    Dict(
        "name" => case,
        "settings" => add_settings(path, case),
        "tags" => add_tags(path, case)
    )
end

function add_settings(path::AbstractString, case::AbstractString)
    settings = OrderedDict{String,Any}()
    for line in eachline("$path/$case/$case-settings.txt")
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
    return settings
end

function add_tags(path::AbstractString, case::AbstractString)
    tags = OrderedDict{String,Vector{String}}()
    flag = 0
    for line in eachline("$path/$case/$case-model.m")
        split_line = split(line, ": ")
        k = strip(first(split_line))
        v = strip(last(split_line))

        if k in ["componentTags", "testTags"]
            tags[k] = String[]
            for v_i in split(v, ",")
                push!(tags[k], strip(v_i))
            end
            flag += 1
        end

        flag == 2 && break
    end
    return tags
end

function save_as_json(dict::AbstractDict; json::AbstractString=json_path)
    stringdata = JSON.json(dict)
    open(json, "w") do f
        write(f, stringdata)
    end
    return nothing
 end

function upload_cases(;json::AbstractString=json_path)
    f = open(json)
    dict = JSON.parse(f, dicttype=OrderedDict)
    close(f)
    return dict
end


function solve_case(case::AbstractDict;alg::Symbol=:Vern9)
    case_name = case["name"]
    file_path = "$semantic_path/$case_name/julia/model.jl"
    isfile(file_path) ? include(file_path) : "julia model for $case_name doesn't exist"

    model = eval_model(Main.julia.models)

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
    df_ans = DataFrame!(CSV.File("$semantic_path/$case_name/$case_name-results.csv"))

    return compare_results(case, df_sim, df_ans)
end

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

function update_results(
    case::AbstractString;
    cases_path::AbstractString=semantic_path,
    json_path::AbstractString=json_path,
    kwargs...
)
    cases_dict = upload_cases(json=json_path)
    cases_dict[case]["result"] = OrderedDict()
    status = try solve_case(cases_dict[case]; kwargs...)
        catch e
            cases_dict[case]["result"]["status"] = "error"
            cases_dict[case]["result"]["message"] = "Check the model: $e"
            save_as_json(cases_dict; json=json_path)
            return nothing
        end
        if status
            cases_dict[case]["result"]["status"] = "success"
            cases_dict[case]["result"]["message"] = ""
        else
            cases_dict[case]["result"]["status"] = "failure"
            cases_dict[case]["result"]["message"] = "tolerance test not passed"
        end

    save_as_json(cases_dict; json=json_path)
    return nothing
end

function update_results(
    cases_vec::Vector{String};
    kwargs...
)
    cases_dict = upload_cases(json=json_path)

    for case in cases_vec
        cases_dict[case]["result"] = OrderedDict()
        status = try solve_case(cases_dict[case]; kwargs...)
            catch e
                cases_dict[case]["result"]["status"] = "error"
                cases_dict[case]["result"]["message"] = "Check the model: $e"
                continue
            end
            if status
                cases_dict[case]["result"]["status"] = "success"
                cases_dict[case]["result"]["message"] = ""
            else
                cases_dict[case]["result"]["status"] = "failure"
                cases_dict[case]["result"]["message"] = "tolerance test not passed"
            end
        end
    save_as_json(cases_dict; json=json_path)
    return nothing
end

function update_results(;
    include_test_tags::Vector{String}=String[],
    include_component_tags::Vector{String}=String[],
    exclude_test_tags::Vector{String}=String[],
    exclude_component_tags::Vector{String}=String[],
    cases_path::AbstractString=semantic_path,
    json_path::AbstractString=json_path,
    kwargs...
)
    cases_dict = upload_cases(json=json_path)
    cases_vec = filter_cases(cases_dict,
        include_test_tags,
        include_component_tags,
        exclude_test_tags,
        exclude_component_tags,
)
    for case in cases_vec
        cases_dict[case]["result"] = OrderedDict()
        status = try solve_case(cases_dict[case]; kwargs...)
            catch e
                cases_dict[case]["result"]["status"] = "error"
                cases_dict[case]["result"]["message"] = "Check the model: $e"
                continue
            end
            if status
                cases_dict[case]["result"]["status"] = "success"
                cases_dict[case]["result"]["message"] = ""
            else
                cases_dict[case]["result"]["status"] = "failure"
                cases_dict[case]["result"]["message"] = "tolerance test not passed"
            end
        end
    save_as_json(cases_dict; json=json_path)
    return nothing
end

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

function eval_model(model_code)
    Model(
        (cons)->Base.invokelatest(model_code.start, cons),
        (du, u, p, t)->Base.invokelatest(model_code.ode, du, u, p, t),
        [((u, t, integrator)->Base.invokelatest(cond, u, t, integrator), (integrator)->Base.invokelatest(ass, integrator)) for (cond,ass) in model_code.events],
        [((u, t, integrator)->Base.invokelatest(cond, u, t, integrator), (integrator)->Base.invokelatest(ass, integrator)) for (cond,ass) in model_code.discrete], # place for discrete events, not used
        (outputIds)->Base.invokelatest(model_code.saving, outputIds),
        model_code.default_constants
    )
end

export upload_cases, filter_cases, add_cases, update_results

end #module
