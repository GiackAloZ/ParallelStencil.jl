"""
Module AD

Provides GPU-compatible wrappers for automatic differentiation functions of the Enzyme.jl package. Consult the Enzyme documentation to learn how to use the wrapped functions.

# Usage
    import ParallelStencil.AD

# Functions
- `autodiff_deferred!`: wraps function `autodiff_deferred`.
- `autodiff_deferred_thunk!`: wraps function `autodiff_deferred_thunk`.

# Examples
    const USE_GPU = true
    using ParallelStencil
    import ParallelStencil.AD
    using Enzyme
    @static if USE_GPU
        @init_parallel_stencil(CUDA, Float64, 3);
    else
        @init_parallel_stencil(Threads, Float64, 3);
    end

    @parallel_indices (ix) function f!(A, B, a)
        A[ix] += a * B[ix] * 100.65
        return
    end

    function main()
        N = 16
        a = 6.5
        A = @rand(N)
        B = @rand(N)
        Ā = @ones(size(A))
        B̄ = @ones(size(B))

        @info "running on CPU/GPU"
        @parallel f!(A, B, a) # normal call of f!
        @parallel configcall=f!(A, B, a) AD.autodiff_deferred!(Enzyme.Reverse, f!, Duplicated(A, Ā), DuplicatedNoNeed(B, B̄), Const(a)) # automatic differentiation of f!
        
        return
    end

    main()

!!! note "Enzyme runtime activity default"
    If ParallelStencil is initialized with Threads, then `Enzyme.API.runtimeActivity!(true)` is called at module load time to ensure correct behavior of Enzyme. If you want to disable this behavior, then call `Enzyme.API.runtimeActivity!(false)` after loading ParallelStencil.

To see a description of a function type `?<functionname>`.
"""
module AD
export autodiff_deferred!, autodiff_deferred_thunk!
import ..ParallelKernel.AD: autodiff_deferred!, autodiff_deferred_thunk!

end # Module AD
