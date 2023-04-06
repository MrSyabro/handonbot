FROM imolein/luarocks:5.4

COPY . .

RUN luarocks make handonbot-dev-1.rockspec

CMD ["handonbot", "-c", "/run/secrets/handonbot"]