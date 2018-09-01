using Distributed
using ReinforcementLearningBase
export sample
export RemoteEnv, whereis, send

struct Message
    resbox::Distributed.AbstractRemoteRef
    method::Symbol
    args::Tuple
    kw::Iterators.Pairs
end

struct RemoteEnv{T <: AbstractEnv}
    mailbox::RemoteChannel{Channel{Message}}
    actionspace::AbstractSpace
end


"""
Create an environment on a worker.

    RemoteEnv(envtype::Type{T}, args...; pid::Int=myid(), kw...) where T <: AbstractEnv

The `args` and `kw` are passed to `envtype` to create an environment at a worker
specified by `pid`.
"""
function RemoteEnv(envtype::Type{T}, args...; pid::Int=myid(), kw...) where T <: AbstractEnv
    envtype <: AbstractEnv || throw("Unsupported Environment type $envtype")
    mailbox = RemoteChannel(pid) do
        Channel(;ctype=Message, csize=Inf) do c
            try
                env = envtype(args...; kw...)
                while true
                    msg = take!(c)
                    method = @eval Main.$(msg.method)
                    put!(msg.resbox, method(env, msg.args...; msg.kw...))
                end
            catch e
                @error e
            end
        end
    end
    actionspace = send(mailbox, :actionspace) |> fetch
    RemoteEnv{T}(mailbox, actionspace)
end

"Return the worker id of an `RemoteEnv`"
whereis(env::RemoteEnv) = env.mailbox.where

function send(mailbox::RemoteChannel{Channel{Message}} , method::Symbol, args...; kw...)
    resbox = Future(mailbox.where)
    put!(mailbox, Message(resbox, method, args, kw))
    resbox
end

send(env::RemoteEnv, method::Symbol, args...; kw...) = send(env.mailbox, method, args...; kw...)