__precompile__(false)
module Env
export id2env, receive

include("Space/Space.jl")
include("abstractenv.jl")
include("pygymenv.jl")
include("ale.jl")
include("vizdoom.jl")

const supportedIDs = merge(Dict("pygym#" * x => GymEnv for x in pygym_ids),
                           Dict("atari#" * x => AtariEnv for x in atari_ids),
                           Dict("vizdoom#basic" => ViZDoomEnv))

function id2env(id::String; kw...)
    haskey(supportedIDs, id) || throw("$id is not supported yet!")
    category, game_id = split(id, '#'; limit=2)
    supportedIDs[id](String(game_id);kw...)
end

end