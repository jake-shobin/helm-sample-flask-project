import os
from flask import Flask
from celery import Celery


app = Flask(__name__)

celery = Celery(__name__, broker=os.environ.get("REDIS_URL"))

@app.route("/")
def hello():
    return "Hello World!"


@celery.task
def add(x, y):
    return x + y
