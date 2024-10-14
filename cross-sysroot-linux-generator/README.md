cross-sysroot-linux-generator
------

* Cross Toolchain Mixed Sysroot Generator for Linux
* Push to `Docker Hub`
  - [cross-sysroot-linux-amd64-gnu](https://hub.docker.com/r/valord577/cross-sysroot-linux-amd64-gnu/tags)
  - [cross-sysroot-linux-arm64-gnu](https://hub.docker.com/r/valord577/cross-sysroot-linux-arm64-gnu/tags)
  - [cross-sysroot-linux-armhf-gnu](https://hub.docker.com/r/valord577/cross-sysroot-linux-armhf-gnu/tags)
  - [cross-sysroot-linux-amd64-musl](https://hub.docker.com/r/valord577/cross-sysroot-linux-amd64-musl/tags)
  - [cross-sysroot-linux-arm64-musl](https://hub.docker.com/r/valord577/cross-sysroot-linux-arm64-musl/tags)

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "cross-sysroot-linux-amd64-gnu"  --target "target-ct-amd64-glibc" .
docker build -t "cross-sysroot-linux-arm64-gnu"  --target "target-ct-arm64-glibc" .
docker build -t "cross-sysroot-linux-armhf-gnu"  --target "target-ct-armhf-glibc" .
docker build -t "cross-sysroot-linux-amd64-musl" --target "target-ct-amd64-musl"  .
docker build -t "cross-sysroot-linux-arm64-musl" --target "target-ct-arm64-musl"  .
```
