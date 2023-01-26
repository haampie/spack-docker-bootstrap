# Spack in Docker with buildcache

This bootstraps Spack's own, optimized dependencies, but in the end still uses
the distro's compiler toolchain.

See [spack.yaml](spack.yaml) for things that are built by Spack, and
[Makefile](Makefile) and [Dockerfile](Dockerfile) for how it's built.

Docker buildkit is required.

Build with:

```
DOCKER_BUILDKIT=1 docker build -f linux-ubuntu22.04-x86_64_v2/Dockerfile -t spack-optimized --progress=plain .
```

Since this uses Python 3.11 and clingo with some optimizations, it should
generally be faster:

```
Benchmark 1: docker run --rm spack-optimized spack spec hdf5
  Time (mean ± σ):      8.494 s ±  0.401 s    [User: 0.015 s, System: 0.008 s]
  Range (min … max):    8.034 s …  8.763 s    3 runs

Benchmark 2: docker run --rm spack/ubuntu-focal spec hdf5
  Time (mean ± σ):     10.795 s ±  0.382 s    [User: 0.013 s, System: 0.009 s]
  Range (min … max):   10.355 s … 11.030 s    3 runs

Summary
  'docker run --rm spack-optimized spack spec hdf5' ran
    1.27 ± 0.07 times faster than 'docker run --rm spack/ubuntu-focal spec hdf5'
```

