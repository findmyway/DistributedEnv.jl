# DistributedEnv.jl

This package aims to provide a thin wrapper to enable different reinforcement learning environments to run in parallel.

In current implementation, an environment is running infinitely on a worker process as a `Task`, which is bind with a `RemoteChannel`.
For some light-weight environments(like CartPole), this implementation is not that efficient. In the future, a global scheduler will be added to  orchestrate remote environments, actors and learners. Just like the [IMPALA](https://deepmind.com/blog/impala-scalable-distributed-deeprl-dmlab-30/) architecture proposed by DeepMind.

## Install

```
(v1.0) pkg> add https://github.com/JuliaReinforcementLearning/DistributedEnv.jl.git
```

## How to use?

```julia
julia> using Distributed

julia> addprocs()
4-element Array{Int64,1}:
 2
 3
 4
 5

julia> @everywhere using DistributedEnv

julia> @everywhere using ReinforcementLearningEnvironmentClassicControl

julia> envs = [RemoteEnv(CartPole; pid=x) for x in workers()]
4-element Array{RemoteEnv{CartPole},1}:
 RemoteEnv{CartPole}(RemoteChannel{Channel{DistributedEnv.Message}}(2, 1, 38), ReinforcementLearningBase.DiscreteSpace(2, 1))
 RemoteEnv{CartPole}(RemoteChannel{Channel{DistributedEnv.Message}}(3, 1, 43), ReinforcementLearningBase.DiscreteSpace(2, 1))
 RemoteEnv{CartPole}(RemoteChannel{Channel{DistributedEnv.Message}}(4, 1, 48), ReinforcementLearningBase.DiscreteSpace(2, 1))
 RemoteEnv{CartPole}(RemoteChannel{Channel{DistributedEnv.Message}}(5, 1, 53), ReinforcementLearningBase.DiscreteSpace(2, 1))
```