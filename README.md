# Spack in Docker with buildcache

This bootstraps Spack's own, optimized dependencies, but in the end still uses
the distro's compiler toolchain.

See [spack.yaml](spack.yaml) for things that are built by Spack, and
[Makefile](Makefile) and [Dockerfile](Dockerfile) for how it's built.

Docker buildkit is required.

Build with:

```
DOCKER_BUILDKIT=1 docker build -t hello --progress=plain .
```


