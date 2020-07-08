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
    k3 = 1.5
    compartment = 1.0
    S2 = 1.5e-5 / compartment
    S4 = k3 * S2
    k1 = 150000.0
    S1 = 1e-5 / compartment
    reaction1 = compartment * k1 * S1 * S2
    k2 = 50.0
    S3 = 1e-5 / compartment
    reaction2 = compartment * k2 * S3
    
    # save results

    return (
        [
            S1 * compartment,
            S2 * compartment,
            S3 * compartment,
        ],
        
        [
            compartment,
            k1,
            k2,
            k3,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (compartment,k1,k2,k3,) = p.static
    (S1_,S2_,S3_,) = u 

    # Heta rules
    S2 = S2_ / compartment
    S4 = k3 * S2
    S1 = S1_ / compartment
    reaction1 = compartment * k1 * S1 * S2
    S3 = S3_ / compartment
    reaction2 = compartment * k2 * S3
    
    #p.static .= [compartment,k1,k2,k3,]
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
        (compartment,k1,k2,k3,) = integrator.p.static
        (S1_,S2_,S3_,) = u

        # Heta rules
        S2 = S2_ / compartment
        S4 = k3 * S2
        S1 = S1_ / compartment
        reaction1 = compartment * k1 * S1 * S2
        S3 = S3_ / compartment
        reaction2 = compartment * k2 * S3
        
        # calculate amounts
        compartment_ = compartment
        S4_ = S4 * compartment
        reaction1_ = reaction1
        reaction2_ = reaction2
        k1_ = k1
        k2_ = k2
        k3_ = k3

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00089 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00089 = x00089
)
tasks = ()

export models, tasks

end
