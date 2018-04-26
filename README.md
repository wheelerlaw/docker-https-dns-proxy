# docker-https-dns-proxy

Wraps [https_dns_proxy](https://github.com/aarond10/https_dns_proxy) in an easy to use Docker image. 

### Usage:

```
docker run --net=host --privileged wheelerlaw/https-dns-proxy [https_dns_proxy args]
```

You can specify the proxy server to connect through with the `-t` option:

```
docker run --net=host --privileged wheelerlaw/https-dns-proxy -t $http_proxy
```

By default, `https_dns_proxy` will listen on `127.0.0.1`. You will probably want to change it to the `docker0` address so your other containers can connect to it:

```
docker run --net=host --privileged wheelerlaw/https-dns-proxy -a 172.17.0.1
```


### Building

To build the image:

```
docker build .
```

If you are trying to build the image while behind a proxy, you can specify the proxy server:

```
docker build --build-arg "http_proxy=<proxy-URL>" --build-arg "https_proxy=<proxy-URL>" .
```

Or if your proxy host is defined in a local environment variable (`http_proxy`):

```
docker build --build-arg http_proxy --build-arg https_proxy .
```

If `http_proxy` is set to `http://localhost:3128` (if you are connecting through Cntlm for example), then it is likely the above commands won't work. You will need to tell the Docker daemon to use the host network stack:

```
docker build --build-arg http_proxy --build-arg https_proxy --network=host .
```
