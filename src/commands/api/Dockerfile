FROM python:3.13

WORKDIR /app

COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

COPY . /app

CMD ["fastapi", "run", "main.py", "--port", "8080"]
