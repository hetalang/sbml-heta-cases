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
    k1 = 1.7
    compartment = 1.0
    S1 = 1.0 / compartment
    S2 = 2.0 / compartment
    reaction1 = compartment * k1 * S1 * S2
    k2 = 0.3
    S3 = 1.0 / compartment
    S4 = 1.5 / compartment
    reaction2 = compartment * k2 * S3 * S4
    
    # save results

    return (
        [
            S1 * compartment,
            S2 * compartment,
            S3 * compartment,
        ],
        
        [
            compartment,
            S4,
            k1,
            k2,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (compartment,S4,k1,k2,) = p.static
    (S1_,S2_,S3_,) = u 

    # Heta rules
    S1 = S1_ / compartment
    S2 = S2_ / compartment
    reaction1 = compartment * k1 * S1 * S2
    S3 = S3_ / compartment
    reaction2 = compartment * k2 * S3 * S4
    
    #p.static .= [compartment,S4,k1,k2,]
    du .= [
      -reaction1+reaction2,  # dS1_/dt
      -reaction1+reaction2,  # dS2_/dt
      reaction1-reaction2,  # dS3_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (compartment,S4,k1,k2,) = integrator.p.static
        (S1_,S2_,S3_,) = u

        # Heta rules
        S1 = S1_ / compartment
        S2 = S2_ / compartment
        reaction1 = compartment * k1 * S1 * S2
        S3 = S3_ / compartment
        reaction2 = compartment * k2 * S3 * S4
        
        # calculate amounts
        compartment_ = compartment
        S4_ = S4 * compartment
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

x00064 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00064 = x00064
)
tasks = ()

export models, tasks

end
