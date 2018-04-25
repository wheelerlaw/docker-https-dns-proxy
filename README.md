# How to use:

```
docker run --net=host --privileged wheelerlaw/https-dns-proxy -a 0.0.0.0
```

Behind a proxy server:

```
docker run --net=host --privileged wheelerlaw/https-dns-proxy -t $http_proxy -a 0.0.0.0
```

# Building:

```
docker build --network=host .
```

Or if your are behind a proxy server:

```
docker build --build-arg http_proxy --build-arg https_proxy --network=host .
```
