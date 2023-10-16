FROM python:3.10-alpine AS builder
ENV PYTHONBUFFERED=1
RUN apk add build-base libffi-dev

RUN pip3 install poetry==1.2.1

WORKDIR /app1

COPY poetry.lock pyproject.toml /app1/
RUN mkdir /app1/updateservice && touch /app1/updateservice/app.py && poetry build -f wheel
COPY ./updateservice /app1/updateservice



FROM --platform=linux/amd64 python:3.10-slim

WORKDIR /app



COPY --from=builder /app1 /app/
RUN pip3 install poetry==1.2.1
RUN poetry install
COPY --from=builder /app1/dist/updateservice*.whl /app/
RUN pip3 install updateservice*.whl
COPY ./alembic /app/alembic
COPY alembic.ini /app
COPY ./alembic_test /app/alembic_test
COPY alembic-test.ini /app


EXPOSE 8080

CMD ["uvicorn","updateservice.app:app", "--host=0.0.0.0", "--port=8080"]
