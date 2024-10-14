cross-toolchain-mingw
------

* Cross Toolchain Mixed Sysroot for LLVM MinGW
* Push to `Docker Hub`
  - [cross-sysroot-mingw](https://hub.docker.com/r/valord577/cross-sysroot-mingw/tags)

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "cross-sysroot-mingw" .
```
