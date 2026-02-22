FROM debian:bookworm-slim

WORKDIR /tmp
ADD https://download.redis.io/releases/redis-8.4.0.tar.gz redis.tar.gz
RUN apt-get update \
	&& mkdir redis \
	&& tar -xzf redis.tar.gz -C redis --strip-components=1 \
	&& apt-get install -y gcc g++ make \
	&& make -C redis \
	&& make -C redis install \
	&& rm -rf redis.tar.gz redis \
	&& apt-get purge -y --autoremove gcc g++ make \
	&& apt-get clean all \
	&& rm -rf /var/lib/apt/lists/* \
	&& groupadd -r -g 990 redis \
	&& useradd -r -g redis -u 990 redis

ENV REDIS_DATA=/data 
WORKDIR ${REDIS_DATA}
RUN chown redis:redis ${REDIS_DATA}
USER redis
EXPOSE 6379
ENTRYPOINT ["redis-server", "--protected-mode", "no", "--save", "5", "1"]
