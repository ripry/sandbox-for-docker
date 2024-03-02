FROM python:3.12.2-slim as runner
WORKDIR /app

RUN pip install poetry

COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev

COPY main.py ./

EXPOSE 8000
CMD ["poetry", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--reload"]
