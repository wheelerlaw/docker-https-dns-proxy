FROM alpine:3.7

MAINTAINER Wheeler Law <whelderwheels613@gmail.com>

# Proxy settings might need to be set to run the container: (preferred)
# docker run --net=host -e "http_proxy=$http_proxy" -e "https_proxy=$https_proxy" --rm -it alpine sh
# OR (assumes that Cntlm can listen on Docker's bridge interface)
# docker run -e "http_proxy=http://`ip addr show docker0 | sed -n 's/.*inet \([0-9.]\+\)\/.*/\1/p'`:3128" -e "https_proxy=http://`ip addr show docker0 | sed -n 's/.*inet \([0-9.]\+\)\/.*/\1/p'`:3128" --rm -it alpine sh

RUN apk update && apk add build-base curl bash iptables git c-ares-dev curl-dev libev-dev cmake \
  && git clone https://github.com/aarond10/https_dns_proxy.git \
  && (cd https_dns_proxy/ && cmake .) \
  && make -C https_dns_proxy \
  && cp https_dns_proxy/https_dns_proxy /usr/local/bin


# Use a multi-stage build to cut down on image size
FROM alpine:3.7
RUN apk --no-cache add iptables c-ares libcurl libev ca-certificates bash
COPY --from=0 https_dns_proxy/https_dns_proxy /usr/local/bin

COPY entrypoint.sh /entrypoint.sh
COPY fw.sh /fw.sh

ENTRYPOINT ["/entrypoint.sh"]
