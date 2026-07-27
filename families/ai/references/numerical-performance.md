# Numerical and Accelerator Performance

Load this reference only for numerical, tensor, accelerator, or data-intensive
paths where performance can affect feasibility.

## Design

- Batch or vectorize work when the operation and memory budget support it.
- Stream or chunk inputs when full materialization is unnecessary.
- Make copies, materialization, precision changes, host/device transfers, and
  synchronization points visible.
- Reuse the repository's data-loading, accelerator, and mixed-precision
  conventions.
- Bound parallel work and preserve deterministic ownership of resources.

## Measure

- Profile before adding custom kernels, concurrency, caching, or lower-level
  implementations.
- Measure end-to-end throughput, latency, peak memory, and solution quality
  together.
- Benchmark representative shapes and input distributions.
- Warm up and synchronize correctly when the framework or device requires it.
- Compare against the simplest credible implementation.

## Optimize

Optimize the measured bottleneck. Accept localized complexity when it changes
feasibility, then isolate, explain, benchmark, and test that path. Do not trade
away numerical stability or evaluation validity for an unmeasured speedup.
