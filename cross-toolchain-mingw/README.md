cross-toolchain-mingw
------

* Cross Toolchain Basic (Mixed Sysroot) for LLVM MinGW
* Push to `Docker Hub`
  - [ct-mingw-ucrt](https://hub.docker.com/r/valord577/ct-mingw-ucrt/tags)

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "ct-mingw-ucrt" .
```
