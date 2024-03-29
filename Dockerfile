FROM imolein/luarocks:5.4

COPY src src
COPY lib lib
COPY handonbot-dev-1.rockspec .

RUN luarocks make handonbot-dev-1.rockspec

CMD ["handonbot", "-c", "/run/secrets/handonbot"]