linux-cross
------

* Push to `Docker Hub Tags`
  - [linux310-cross][1]
  - [linux419-cross][2]
* Cross Toolchain for Linux with GLIBC 2.17+ or MUSL

How to build 
------

```shell
export DOCKER_BUILDKIT=1
docker build -t "linux310-cross" --build-arg "LINUX_UAPI_VERSION=310" .
docker build -t "linux419-cross" --build-arg "LINUX_UAPI_VERSION=419" .
```

[1]: https://hub.docker.com/r/valord577/linux310-cross/tags
[2]: https://hub.docker.com/r/valord577/linux419-cross/tags
