#= 
    This code was generated by heta-compiler of v0.5.3
    
=#

module julia 
using SimSolver

### create default constants
constants_ = NamedTuple{(
  
)}(Float64[
  
])

### initialization of ODE variables and Records
function start_(cons)
    #() = cons

    # Heta initialize
    t = 0.0 # initial time
    k1 = 0.35
    compartment = 0.3
    S1 = 1.5e-4 / compartment
    reaction1 = compartment * k1 * S1
    k2 = 180.0
    S2 = 0.0 / compartment
    reaction2 = compartment * k2 * ^(S2, 2.0)
    
    # save results

    return (
        [
            S1 * compartment,
            S2 * compartment,
        ],
        
        [
            compartment,
            k1,
            k2,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (compartment,k1,k2,) = p.static
    (S1_,S2_,) = u 

    # Heta rules
    S1 = S1_ / compartment
    reaction1 = compartment * k1 * S1
    S2 = S2_ / compartment
    reaction2 = compartment * k2 * ^(S2, 2.0)
    
    #p.static .= [compartment,k1,k2,]
    du .= [
      -reaction1+reaction2,  # dS1_/dt
      2*reaction1-2*reaction2,  # dS2_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (compartment,k1,k2,) = integrator.p.static
        (S1_,S2_,) = u

        # Heta rules
        S1 = S1_ / compartment
        reaction1 = compartment * k1 * S1
        S2 = S2_ / compartment
        reaction2 = compartment * k2 * ^(S2, 2.0)
        
        # calculate amounts
        compartment_ = compartment
        reaction1_ = reaction1
        reaction2_ = reaction2
        k1_ = k1
        k2_ = k2

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00021 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00021 = x00021
)
tasks = ()

export models, tasks

end
