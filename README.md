# How to use:

```
docker run --net=host --privileged -p 5053 wheelerlaw/https-dns-proxy
```

Behind a proxy server:

```
docker run --net=host --privileged wheelerlaw/https-dns-proxy -t $http_proxy -a 0.0.0.0
```

# Building:

```
docker build .
```

Or if your are behind a proxy server (use `--network=host` just in case `$http_proxy` is `localhost`):

```
docker build --build-arg http_proxy --build-arg https_proxy --network=host .
```
