mingw-cross-cgo
------

* CGO Cross Toolchain for LLVM MinGW included Mixed Sysroot
* Push to `Docker Hub`
  - [mingw-cross-ucrt-cgo](https://hub.docker.com/r/valord577/mingw-cross-ucrt-cgo/tags)

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "mingw-cross-ucrt-cgo" .
```
