FROM nimlang/nim:latest

WORKDIR /app

COPY . /app/yami

WORKDIR /app/yami

RUN nimble install -y
RUN rm -f nimble.paths && nim c -d:release --opt:speed -o:bin/yami src/yami.nim

CMD ["./bin/yami"]