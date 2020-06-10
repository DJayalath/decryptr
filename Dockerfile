FROM python:3.7

COPY . /app

WORKDIR /app

RUN pip3 install -r requirements.txt

CMD ["gunicorn --workers 5 --bind 0.0.0.0:5000 app:app"]
