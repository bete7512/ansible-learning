FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum* ./
COPY main.go ./

# Download dependencies if go.sum exists, otherwise create minimal module
RUN go mod tidy
RUN go build -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates curl
WORKDIR /root/

COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]