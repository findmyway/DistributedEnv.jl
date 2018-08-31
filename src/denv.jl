using Distributed
using ReinforcementLearningBase

export DEnv, whereis, send

struct Message
    resbox::Distributed.AbstractRemoteRef
    method::Symbol
    args::Tuple
    kw::Iterators.Pairs
end

struct DEnv{T <: AbstractEnv}
    id::String
    mailbox::RemoteChannel{Channel{Message}}
    actionspace::AbstractSpace
end


function DEnv(envtype::DataType, id::String, pid::Int=myid(); kw...)
    mailbox = RemoteChannel(pid) do
        Channel(;ctype=Message, csize=Inf) do c
            try
                env = envtype(id; kw...)
                while true
                    msg = take!(c)
                    put!(msg.resbox, @eval $(msg.method)(env, msg.args...; msg.kw...))
                end
            catch e
                @error e
            end
        end
    end
    actionspace = send(mailbox, :actionspace) |> fetch
    DEnv{envtype}(id, mailbox, actionspace)
end

whereis(env::DEnv) = env.mailbox.where

function send(mailbox::RemoteChannel{Channel{Message}} , method::Symbol, args...; kw...)
    resbox = Future(mailbox.where)
    put!(mailbox, Message(resbox, method, args, kw))
    resbox
end

send(env::DEnv, method::Symbol, args...; kw...) = send(env.mailbox, method, args...; kw...)