# docker-https-dns-proxy

Wraps [https_dns_proxy](https://github.com/aarond10/https_dns_proxy) in an easy to use Docker image. 

### Usage:

To run:

```
docker run --net=host --privileged wheelerlaw/https-dns-proxy [-a <listen-addr>] [-p <list-port>] [-t <proxy-url>] [other https_dns_proxy arguments]
```

Options:

```
-a listen-addr         Local address to bind to. (127.0.0.1)
-p listen-port         Local port to bind to. (5053)
-t proxy-URL           Upstream proxy server to forward requests to (http://localhost:3128).
```

The proxy can also be specified by environment variable:

```
docker run --net=host --privileged -e http_proxy wheelerlaw/https-dns-proxy [-a <listen-addr>] [-p <list-port>]
```


**Note:** By default, `https_dns_proxy` will listen on `127.0.0.1`. You will probably want to change it to the `docker0` address so your other containers can connect to it:

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
