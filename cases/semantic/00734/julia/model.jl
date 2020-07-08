#= 
    This code was generated by heta-compiler of v0.5.3
    
=#

module julia 
using SimSolver

### create default constants
constants_ = NamedTuple{(
  :k1__reaction1_local,:k2__reaction2_local,
)}(Float64[
  0.01,0.4,
])

### initialization of ODE variables and Records
function start_(cons)
    #(k1__reaction1_local,k2__reaction2_local,) = cons

    # Heta initialize
    t = 0.0 # initial time
    C = 1.0
    S2 = 1.5e-5 / C
    k3 = 1.5
    S1 = 1e-5 / C
    S4 = k3 * S1
    reaction1 = C * cons[1] * S1
    S3 = 1e-5 / C
    reaction2 = C * cons[2] * S3
    k2 = 0.5
    k1 = 0.015
    S2_proc = k2 * S3 + (-1.0) * k1 * S1
    
    # save results

    return (
        [
            S1 * C,
            S2 * C,
            S3 * C,
        ],
        
        [
            C,
            k1,
            k2,
            k3,
        ]
    )
end

### calculate RHS of ODE
function ode_(du, u, p, t)
    cons = p.constants
    (C,k1,k2,k3,) = p.static
    (S1_,S2_,S3_,) = u 

    # Heta rules
    S2 = S2_ / C
    S1 = S1_ / C
    S4 = k3 * S1
    reaction1 = C * cons[1] * S1
    S3 = S3_ / C
    reaction2 = C * cons[2] * S3
    S2_proc = k2 * S3 + (-1.0) * k1 * S1
    
    #p.static .= [C,k1,k2,k3,]
    du .= [
      -reaction1+reaction2,  # dS1_/dt
      S2_proc*C,  # dS2_/dt
      reaction1-reaction2,  # dS3_/dt
    ]
end

### output function
function make_saving_(outputIds::Vector{Symbol})
    function saving_(u, t, integrator)
        cons = integrator.p.constants
        (C,k1,k2,k3,) = integrator.p.static
        (S1_,S2_,S3_,) = u

        # Heta rules
        S2 = S2_ / C
        S1 = S1_ / C
        S4 = k3 * S1
        reaction1 = C * cons[1] * S1
        S3 = S3_ / C
        reaction2 = C * cons[2] * S3
        S2_proc = k2 * S3 + (-1.0) * k1 * S1
        
        # calculate amounts
        C_ = C
        S4_ = S4 * C
        reaction1_ = reaction1
        reaction2_ = reaction2
        k1_ = k1
        k2_ = k2
        k3_ = k3
        S2_proc_ = S2_proc

        d = Base.@locals
        return [d[id] for id in outputIds]
    end
end

### events


### OUTPUT ###

x00734 = Model(
  start_,
  ode_,
  [],
  [], # place for discrete events, not used
  make_saving_,
  constants_
)

models = (
    x00734 = x00734
)
tasks = ()

export models, tasks

end
