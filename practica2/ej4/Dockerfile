FROM python:3.14.2-alpine
ENV FLASK_APP=counter.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000
ENV FLASK_DEBUG=True
RUN pip install flask redis MarkupSafe
RUN apk --no-cache add curl
WORKDIR /src
EXPOSE 5000/tcp
ENTRYPOINT ["flask", "run"]
