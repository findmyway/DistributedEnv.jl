module DistributedEnv
export init_env, interact!, reset!, getstate, actionspace

import ReinforcementLearningBase: interact!, reset!, getstate, actionspace

include("denv.jl")

function init_env(envtype::DataType, id::String; n::Int=1, workers::Vector{Int}=workers(), kw...)
    [DEnv(envtype, id, wid; kw...) for wid in workers for _ in 1:n]
end

interact!(denv::DEnv, action) = send(denv, :interact!, action)
reset!(denv::DEnv) = send(denv, :reset!)
getstate(denv::DEnv) = send(denv, :getstate)
actionspace(denv::DEnv) = denv.actionspace

end # module
