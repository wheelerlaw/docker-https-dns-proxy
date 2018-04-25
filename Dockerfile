FROM alpine:3.7

MAINTAINER Wheeler Law <whelderwheels613@gmail.com>

# Proxy settings might need to be set to run the container: (preferred)
# docker run --net=host -e "http_proxy=$http_proxy" -e "https_proxy=$https_proxy" --rm -it alpine sh
# OR (assumes that Cntlm can listen on Docker's bridge interface)
# docker run -e "http_proxy=http://`ip addr show docker0 | sed -n 's/.*inet \([0-9.]\+\)\/.*/\1/p'`:3128" -e "https_proxy=http://`ip addr show docker0 | sed -n 's/.*inet \([0-9.]\+\)\/.*/\1/p'`:3128" --rm -it alpine sh

RUN apk update && apk add build-base curl bash git c-ares-dev curl-dev libev-dev \
  && git clone https://github.com/aarond10/https_dns_proxy.git \
  && make -C redsocks-release-0.5/ \
  && cp redsocks-release-0.5/redsocks /usr/local/bin

COPY redsocks.tmpl /etc/redsocks.tmpl
COPY redsocks.sh /usr/local/bin/redsocks.sh
COPY fw.sh /usr/local/bin/fw.sh

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/redsocks.sh"]
