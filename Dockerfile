FROM nimlang/nim:latest

WORKDIR /app

COPY . /app/yami

WORKDIR /app/yami

RUN apt update && apt install sqlite3 docker.io -y
RUN nimble install -y
RUN rm -f nimble.paths && nim c -d:release --opt:speed -o:bin/yami src/yami.nim

CMD ["./bin/yami"]