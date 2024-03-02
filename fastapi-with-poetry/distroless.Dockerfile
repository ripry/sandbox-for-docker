FROM python:3.11-slim as deps-base

# Setup poetry
# ref: https://github.com/orgs/python-poetry/discussions/1879#discussioncomment-216865
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl build-essential

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    POETRY_NO_INTERACTION=1
ENV PATH="$POETRY_HOME/bin:$PATH"

# Uninstall unnecessary packages before installing poetry
RUN pip uninstall --yes pip setuptools pkg_resources distutils && \
    curl -sSL https://install.python-poetry.org | python3 -


FROM deps-base as deps
WORKDIR /app

# Install dependencies
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev


FROM gcr.io/distroless/python3-debian12:nonroot as runner
WORKDIR /app

ARG PYTHON_VERSION="3.11"

ENV PYTHONPATH="/usr/local/lib/python${PYTHON_VERSION}/site-packages"

# ref: https://future-architect.github.io/articles/20200514/
COPY --from=deps /usr/local/lib/python${PYTHON_VERSION}/site-packages/ /usr/local/lib/python${PYTHON_VERSION}/site-packages/

COPY main.py ./

EXPOSE 8000
ENTRYPOINT [ "python3", "-m", "uvicorn", "main:app", "--host", "0.0.0.0" ]
