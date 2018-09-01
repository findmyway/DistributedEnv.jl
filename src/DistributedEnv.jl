module DistributedEnv
export interact!, reset!, getstate, actionspace

import ReinforcementLearningBase: interact!, reset!, getstate, actionspace

include("denv.jl")

interact!(denv::RemoteEnv, action) = send(denv, :interact!, action)
reset!(denv::RemoteEnv) = send(denv, :reset!)
getstate(denv::RemoteEnv) = send(denv, :getstate)
actionspace(denv::RemoteEnv) = denv.actionspace

end # module
