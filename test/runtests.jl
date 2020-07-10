using SBMLCases
using Test

cases_dict = upload_cases()

@testset "upload test" begin
    @test length(cases_dict) == 1780
end

@testset "filter test" begin
    s1 = filter_cases(
        cases_dict,
        include_test_tags=["LocalParameters"],
        include_component_tags=["EventNoDelay", "CSymbolTime"],
        exclude_test_tags=["FastReaction", "Concentration"],
        exclude_component_tags=["AlgebraicRule"]
    )
    s2 = filter_cases(cases_dict)
    @test length(s1) == 454
    @test length(s2) == 1780
end
