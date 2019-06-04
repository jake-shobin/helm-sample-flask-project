FROM python:3.7-alpine

ENV PYTHONUNBUFFERED 1

RUN addgroup -S flask \
    && adduser -S -G flask flask

WORKDIR /app

COPY . .
RUN pip install -r requirements.txt

USER flask

EXPOSE 5000

CMD ["/bin/sh", "-c", "gunicorn -b 0.0.0.0:5000 app:app"]