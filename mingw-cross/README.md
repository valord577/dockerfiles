mingw-cross
------

* Cross Toolchain for LLVM MinGW included Mixed Sysroot
* Push to `Docker Hub`
  - [mingw-cross-ucrt](https://hub.docker.com/r/valord577/mingw-cross-ucrt/tags)

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "mingw-cross-ucrt" .
```
