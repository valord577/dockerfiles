cross-toolchain-linux
------

* Cross Toolchain Basic (Mixed Sysroot) for Linux with GLIBC or MUSL
* Push to `Docker Hub Tags`
  - [ct-linux310](https://hub.docker.com/r/valord577/ct-linux310/tags)
  - [ct-linux419](https://hub.docker.com/r/valord577/ct-linux419/tags)

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "ct-linux310" --build-arg "LINUX_UAPI_VERSION=310" .
docker build -t "ct-linux419" --build-arg "LINUX_UAPI_VERSION=419" .
```
