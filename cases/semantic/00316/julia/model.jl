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
    k1 = 0.0365
    p1 = 0.1
    p2 = 1.5
    C = 1.0
    S1 = 1.0 / C
    S2 = 1.5 / C
    reaction1 = C * k1 * S1 * S2
    k2 = 0.0025
    S3 = 1.1 / C
    S4 = 1.0 / C
    reaction2 = C * k2 * S3 * S4
    p2_proc = 0.1
    
    # save results

    return (
        [
            S1 * C,
            S2 * C,
            S3 * C,
            S4 * C,
            p2,
        ],
        
        [
            k1,
            k2,
            p1,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (k1,k2,p1,) = p.static
    (S1_,S2_,S3_,S4_,p2_,) = u 

    # Heta rules
    p2 = p2_
    C = p1 * p2
    S1 = S1_ / C
    S2 = S2_ / C
    reaction1 = C * k1 * S1 * S2
    S3 = S3_ / C
    S4 = S4_ / C
    reaction2 = C * k2 * S3 * S4
    p2_proc = 0.1
    
    #p.static .= [k1,k2,p1,]
    du .= [
      -reaction1+reaction2,  # dS1_/dt
      -reaction1+reaction2,  # dS2_/dt
      reaction1-reaction2,  # dS3_/dt
      reaction1-reaction2,  # dS4_/dt
      p2_proc,  # dp2_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (k1,k2,p1,) = integrator.p.static
        (S1_,S2_,S3_,S4_,p2_,) = u

        # Heta rules
        p2 = p2_
        C = p1 * p2
        S1 = S1_ / C
        S2 = S2_ / C
        reaction1 = C * k1 * S1 * S2
        S3 = S3_ / C
        S4 = S4_ / C
        reaction2 = C * k2 * S3 * S4
        p2_proc = 0.1
        
        # calculate amounts
        C_ = C
        reaction1_ = reaction1
        reaction2_ = reaction2
        k1_ = k1
        k2_ = k2
        p1_ = p1
        p2_proc_ = p2_proc

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00316 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00316 = x00316
)
tasks = ()

export models, tasks

end
