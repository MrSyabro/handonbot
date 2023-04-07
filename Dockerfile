FROM mrsyabro/tgbotlua

COPY . .

RUN luarocks make handonbot-dev-1.rockspec

CMD ["handonbot", "-c", "/run/secrets/handonbot"]