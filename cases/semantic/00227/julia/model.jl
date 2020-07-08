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
    compartment = 1.0
    S2 = 1e-6 / compartment
    k1 = 1.5
    S1 = 1.5e-6 / compartment
    reaction1 = compartment * k1 * S1
    
    # save results

    return (
        [
            S1 * compartment,
        ],
        
        [
            compartment,
            S2,
            k1,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (compartment,S2,k1,) = p.static
    (S1_,) = u 

    # Heta rules
    S1 = S1_ / compartment
    reaction1 = compartment * k1 * S1
    
    #p.static .= [compartment,S2,k1,]
    du .= [
      -reaction1,  # dS1_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (compartment,S2,k1,) = integrator.p.static
        (S1_,) = u

        # Heta rules
        S1 = S1_ / compartment
        reaction1 = compartment * k1 * S1
        
        # calculate amounts
        compartment_ = compartment
        S2_ = S2 * compartment
        reaction1_ = reaction1
        k1_ = k1

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00227 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00227 = x00227
)
tasks = ()

export models, tasks

end
