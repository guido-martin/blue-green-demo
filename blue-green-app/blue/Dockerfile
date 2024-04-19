FROM golang:alpine

COPY cmd/web/main.go /app/main.go
WORKDIR /app

RUN go build -ldflags "-X main.version=blue" -o bin/server /app/main.go

FROM alpine:latest

COPY --from=0 /app/bin/server /bin/server
EXPOSE 80

CMD ["/bin/server"]
