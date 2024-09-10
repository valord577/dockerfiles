linux-cross
------

* Cross Toolchain for Linux with GLIBC or MUSL included Mixed Sysroot
* Push to `Docker Hub Tags`
  - [linux310-cross](https://hub.docker.com/r/valord577/linux310-cross/tags)
  - [linux419-cross](https://hub.docker.com/r/valord577/linux419-cross/tags)

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "linux310-cross" --build-arg "LINUX_UAPI_VERSION=310" .
docker build -t "linux419-cross" --build-arg "LINUX_UAPI_VERSION=419" .
```
