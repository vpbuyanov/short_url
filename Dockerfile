FROM golang:1.22-alpine AS builder

WORKDIR /usr/local/src

COPY ["../go.mod", "../go.sum", "./"]
RUN go mod tidy
RUN go mod download

COPY .. /usr/local/src

RUN go build -o ./bin/app cmd/shortener/main.go

FROM alpine:latest AS runner

COPY --from=builder /usr/local/src/bin/app /

CMD ["/app"]