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
    S2 = 0.5 / compartment
    k1 = 1.78
    S1 = 1.5 / compartment
    S3 = 1.2 / compartment
    reaction1 = compartment * k1 * S1 * S3
    
    # save results

    return (
        [
            S1 * compartment,
            S2 * compartment,
        ],
        
        [
            compartment,
            S3,
            k1,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (compartment,S3,k1,) = p.static
    (S1_,S2_,) = u 

    # Heta rules
    S2 = S2_ / compartment
    S1 = S1_ / compartment
    reaction1 = compartment * k1 * S1 * S3
    
    #p.static .= [compartment,S3,k1,]
    du .= [
      -reaction1,  # dS1_/dt
      reaction1,  # dS2_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (compartment,S3,k1,) = integrator.p.static
        (S1_,S2_,) = u

        # Heta rules
        S2 = S2_ / compartment
        S1 = S1_ / compartment
        reaction1 = compartment * k1 * S1 * S3
        
        # calculate amounts
        compartment_ = compartment
        S3_ = S3 * compartment
        reaction1_ = reaction1
        k1_ = k1

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00254 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00254 = x00254
)
tasks = ()

export models, tasks

end
