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
    k1 = 0.75
    compartment = 1.0
    S1 = 1e-4 / compartment
    reaction1 = compartment * k1 * S1
    k2 = 0.25
    S2 = 2e-4 / compartment
    reaction2 = compartment * k2 * S2
    k3 = 0.4
    reaction3 = compartment * k3 * S2
    k4 = 0.1
    S3 = 0.0 / compartment
    S4 = 0.0 / compartment
    reaction4 = compartment * k4 * S3 * S4
    
    # save results

    return (
        [
            S1 * compartment,
            S2 * compartment,
            S3 * compartment,
            S4 * compartment,
        ],
        
        [
            compartment,
            k1,
            k2,
            k3,
            k4,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (compartment,k1,k2,k3,k4,) = p.static
    (S1_,S2_,S3_,S4_,) = u 

    # Heta rules
    S1 = S1_ / compartment
    reaction1 = compartment * k1 * S1
    S2 = S2_ / compartment
    reaction2 = compartment * k2 * S2
    reaction3 = compartment * k3 * S2
    S3 = S3_ / compartment
    S4 = S4_ / compartment
    reaction4 = compartment * k4 * S3 * S4
    
    #p.static .= [compartment,k1,k2,k3,k4,]
    du .= [
      -reaction1+reaction2,  # dS1_/dt
      reaction1-reaction2-reaction3+reaction4,  # dS2_/dt
      reaction3-reaction4,  # dS3_/dt
      reaction3-reaction4,  # dS4_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (compartment,k1,k2,k3,k4,) = integrator.p.static
        (S1_,S2_,S3_,S4_,) = u

        # Heta rules
        S1 = S1_ / compartment
        reaction1 = compartment * k1 * S1
        S2 = S2_ / compartment
        reaction2 = compartment * k2 * S2
        reaction3 = compartment * k3 * S2
        S3 = S3_ / compartment
        S4 = S4_ / compartment
        reaction4 = compartment * k4 * S3 * S4
        
        # calculate amounts
        compartment_ = compartment
        reaction1_ = reaction1
        reaction2_ = reaction2
        reaction3_ = reaction3
        reaction4_ = reaction4
        k1_ = k1
        k2_ = k2
        k3_ = k3
        k4_ = k4

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00018 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00018 = x00018
)
tasks = ()

export models, tasks

end
