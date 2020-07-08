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
    compartment = 0.0
    S2 = 0.0
    k1 = 1.023
    S1 = 0.15
    reaction1 = k1 * S1
    
    # save results

    return (
        [
            S2,
        ],
        
        [
            compartment,
            S1,
            k1,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (compartment,S1,k1,) = p.static
    (S2_,) = u 

    # Heta rules
    S2 = S2_
    reaction1 = k1 * S1
    
    #p.static .= [compartment,S1,k1,]
    du .= [
      reaction1,  # dS2_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (compartment,S1,k1,) = integrator.p.static
        (S2_,) = u

        # Heta rules
        S2 = S2_
        reaction1 = k1 * S1
        
        # calculate amounts
        compartment_ = compartment
        S1_ = S1
        reaction1_ = reaction1
        k1_ = k1

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00238 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00238 = x00238
)
tasks = ()

export models, tasks

end
