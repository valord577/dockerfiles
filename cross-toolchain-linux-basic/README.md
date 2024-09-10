cross-toolchain-linux-basic
------

* Cross Toolchain Basic (Single Sysroot) for Linux with GLIBC or MUSL
* Push to `Docker Hub Tags`
  - [ct-linux310-amd64-gnu](https://hub.docker.com/r/valord577/ct-linux310-amd64-gnu/tags)
  - [ct-linux310-arm64-gnu](https://hub.docker.com/r/valord577/ct-linux310-arm64-gnu/tags)
  - [ct-linux310-amd64-musl](https://hub.docker.com/r/valord577/ct-linux310-amd64-musl/tags)
  - [ct-linux310-arm64-musl](https://hub.docker.com/r/valord577/ct-linux310-arm64-musl/tags)
  - [ct-linux419-amd64-gnu](https://hub.docker.com/r/valord577/ct-linux419-amd64-gnu/tags)
  - [ct-linux419-arm64-gnu](https://hub.docker.com/r/valord577/ct-linux419-arm64-gnu/tags)
  - [ct-linux419-amd64-musl](https://hub.docker.com/r/valord577/ct-linux419-amd64-musl/tags)
  - [ct-linux419-arm64-musl](https://hub.docker.com/r/valord577/ct-linux419-arm64-musl/tags)

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "ct-linux310-amd64-gnu"  --build-arg "LINUX_UAPI_VERSION=310" --target "target-ct-amd64-glibc" .
docker build -t "ct-linux310-arm64-gnu"  --build-arg "LINUX_UAPI_VERSION=310" --target "target-ct-arm64-glibc" .
docker build -t "ct-linux310-amd64-musl" --build-arg "LINUX_UAPI_VERSION=310" --target "target-ct-amd64-musl"  .
docker build -t "ct-linux310-arm64-musl" --build-arg "LINUX_UAPI_VERSION=310" --target "target-ct-arm64-musl"  .
docker build -t "ct-linux419-amd64-gnu"  --build-arg "LINUX_UAPI_VERSION=419" --target "target-ct-amd64-glibc" .
docker build -t "ct-linux419-arm64-gnu"  --build-arg "LINUX_UAPI_VERSION=419" --target "target-ct-arm64-glibc" .
docker build -t "ct-linux419-amd64-musl" --build-arg "LINUX_UAPI_VERSION=419" --target "target-ct-amd64-musl"  .
docker build -t "ct-linux419-arm64-musl" --build-arg "LINUX_UAPI_VERSION=419" --target "target-ct-arm64-musl"  .
```
