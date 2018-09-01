using BenchmarkTools
using ReinforcementLearningEnvironmentClassicControl
using DistributedEnv
# install above packages first
using Distributed

function localenv(env, N)
    reset!(env)
    n_actions = 1
    while n_actions < N
        state, reward, isdone = interact!(env, sample(actionspace(env)))
        n_actions += 1
        isdone || reset!(env)
    end
end


function remoteenv(envs, N)
    map(envs) do env
        fetch(reset!(env))
    end
    n_actions = length(envs)
    while n_actions < N
        map(envs) do env
            _, _, isdone = fetch(interact!(env, sample(actionspace(env))))
            isdone || reset!(env)
        end
        n_actions += length(envs)
    end
end

N = 10000

@benchmark localenv(env, N) setup=(env = CartPole()) teardown=(env = nothing)

# BenchmarkTools.Trial:
#   memory estimate:  3.20 MiB
#   allocs estimate:  30000
#   --------------
#   minimum time:     2.059 ms (0.00% GC)
#   median time:      2.096 ms (0.00% GC)
#   mean time:        2.281 ms (5.52% GC)
#   maximum time:     50.664 ms (94.55% GC)
#   --------------
#   samples:          2178
#   evals/sample:     1

envs = [RemoteEnv(CartPole; pid=x) for x in workers()]
@benchmark remoteenv(envs, N)

# BenchmarkTools.Trial:
#   memory estimate:  36.58 MiB
#   allocs estimate:  976091
#   --------------
#   minimum time:     143.638 ms (5.72% GC)
#   median time:      177.707 ms (13.51% GC)
#   mean time:        185.569 ms (16.34% GC)
#   maximum time:     289.228 ms (33.72% GC)
#   --------------
#   samples:          27
#   evals/sample:     1