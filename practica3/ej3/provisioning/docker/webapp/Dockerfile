FROM python:3.14.2-alpine
RUN apk add --no-cache mariadb-connector-c \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        pkgconf \
        mariadb-dev \
    && pip install --no-cache-dir flask flask-sqlalchemy mysqlclient \
    && apk del .build-deps
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000
ENV FLASK_DEBUG=True
WORKDIR /var/www
COPY src .
EXPOSE 5000
ENTRYPOINT ["flask", "run"]