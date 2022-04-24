FROM golang:1.18-alpine as builder
WORKDIR /app
ADD . /app
RUN go build -o booking-server cmd/booking-server/main.go

FROM alpine:3.15.0
WORKDIR /app
COPY --from=builder /app/booking-server .

EXPOSE 5000
CMD ./booking-server
