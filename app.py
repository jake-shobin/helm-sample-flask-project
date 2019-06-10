from flask import Flask
from celery import Celery


app = Flask(__name__)

celery = Celery(__name__, broker="redis://redis-master:6379", backend="redis://redis-master:6379")

@app.route("/")
def hello():
    return "Hello World!"


@celery.task
def add(x, y):
    return x + y
