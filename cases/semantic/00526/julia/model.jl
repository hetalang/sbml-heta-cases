#= 
    This code was generated by heta-compiler of v0.5.3
    
=#

module julia 
using SimSolver

### create default constants
constants_ = NamedTuple{(
  :k__reaction1_local,
)}(Float64[
  0.5,
])

### initialization of ODE variables and Records
function start_(cons)
    #(k__reaction1_local,) = cons

    # Heta initialize
    t = 0.0 # initial time
    k = 50.0
    C = k / 50.0
    S2 = 1.5 / C
    S1 = 1.0 / C
    reaction1 = C * cons[1] * S1
    
    # save results

    return (
        [
            S1 * C,
            S2 * C,
        ],
        
        [
            C,
            k,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (C,k,) = p.static
    (S1_,S2_,) = u 

    # Heta rules
    S2 = S2_ / C
    S1 = S1_ / C
    reaction1 = C * cons[1] * S1
    
    #p.static .= [C,k,]
    du .= [
      -reaction1,  # dS1_/dt
      reaction1,  # dS2_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (C,k,) = integrator.p.static
        (S1_,S2_,) = u

        # Heta rules
        S2 = S2_ / C
        S1 = S1_ / C
        reaction1 = C * cons[1] * S1
        
        # calculate amounts
        C_ = C
        reaction1_ = reaction1
        k_ = k

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00526 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00526 = x00526
)
tasks = ()

export models, tasks

end
