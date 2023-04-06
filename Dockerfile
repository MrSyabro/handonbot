FROM alpine:latest

RUN apk add lua5.3
RUN apk add luarocks5.3
RUN apk add lua5.3-filesystem
RUN apk add lua5.3-socket
RUN apk add lua5.3-sec
RUN apk add lua5.3-cjson
RUN alias lua=lua5.3

COPY handonbot-dev-1.rockspec .

RUN luarocks make handonbot-dev-1.rockspec

CMD handonbot