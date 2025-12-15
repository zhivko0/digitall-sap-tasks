FROM alpine:3.19

RUN apk add --no-cache bash openssl curl coreutils

WORKDIR /app

COPY check_certs.sh .
RUN chmod +x check_certs.sh

RUN mkdir -p /etc/cert-checker

CMD ["/app/check_certs.sh"]
