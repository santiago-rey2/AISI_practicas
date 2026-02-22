FROM alpine:3.20 as builder

WORKDIR /tmp
ADD https://download.redis.io/releases/redis-8.4.0.tar.gz redis.tar.gz
RUN apk add --no-cache build-base linux-headers openssl-dev \
	&& mkdir redis \
	&& tar -xzf redis.tar.gz -C redis --strip-components=1 \
	&& make -C redis MALLOC=libc \
	&& make -C redis install

FROM XXX

ENV REDIS_DATA=/data
WORKDIR	$REDIS_DATA 
RUN apk add --no-cache libstdc++ \
	&& addgroup -S redis -g 990 \
	&& adduser -S redis -G redis -u 990 \
	&& chown redis:redis $REDIS_DATA
USER redis
EXPOSE 6379/tcp
COPY --from=builder /usr/local/bin/redis-server /usr/local/bin/
COPY --from=builder /usr/local/bin/redis-cli /usr/local/bin/
ENTRYPOINT ["redis-server", "--protected-mode", "no", "--save", "5", "1"]
