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
    k1 = 1000000.0
    compartment = 1.0
    S1 = 1e-6 / compartment
    S2 = 1.5e-6 / compartment
    reaction1 = compartment * k1 * S1 * S2
    k2 = 300000.0
    S3 = 2e-6 / compartment
    S4 = 5e-7 / compartment
    reaction2 = compartment * k2 * S3 * S4
    k1_proc = 1000000.0
    
    # save results

    return (
        [
            S1 * compartment,
            S2 * compartment,
            S3 * compartment,
            S4 * compartment,
            k1,
        ],
        
        [
            compartment,
            k2,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (compartment,k2,) = p.static
    (S1_,S2_,S3_,S4_,k1_,) = u 

    # Heta rules
    k1 = k1_
    S1 = S1_ / compartment
    S2 = S2_ / compartment
    reaction1 = compartment * k1 * S1 * S2
    S3 = S3_ / compartment
    S4 = S4_ / compartment
    reaction2 = compartment * k2 * S3 * S4
    k1_proc = 1000000.0
    
    #p.static .= [compartment,k2,]
    du .= [
      -reaction1+reaction2,  # dS1_/dt
      -reaction1+reaction2,  # dS2_/dt
      reaction1-reaction2,  # dS3_/dt
      reaction1-reaction2,  # dS4_/dt
      k1_proc,  # dk1_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (compartment,k2,) = integrator.p.static
        (S1_,S2_,S3_,S4_,k1_,) = u

        # Heta rules
        k1 = k1_
        S1 = S1_ / compartment
        S2 = S2_ / compartment
        reaction1 = compartment * k1 * S1 * S2
        S3 = S3_ / compartment
        S4 = S4_ / compartment
        reaction2 = compartment * k2 * S3 * S4
        k1_proc = 1000000.0
        
        # calculate amounts
        compartment_ = compartment
        reaction1_ = reaction1
        reaction2_ = reaction2
        k2_ = k2
        k1_proc_ = k1_proc

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00066 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00066 = x00066
)
tasks = ()

export models, tasks

end
