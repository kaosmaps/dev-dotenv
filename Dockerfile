# Build stage
FROM python:3.12-slim AS builder

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

RUN pip install poetry

# First install deps without the package
COPY pyproject.toml poetry.lock README.md ./
RUN poetry install --only main --no-root && rm -rf $POETRY_CACHE_DIR

# Build the wheel
COPY src ./src
RUN poetry build --format wheel

# Run stage
FROM python:3.12-slim AS runtime

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH" \
    # Default port if not set
    PORT=8501

WORKDIR /app

# Copy the virtualenv with dependencies
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
# Copy the built wheel
COPY --from=builder /app/dist/*.whl ./

# Install our package from the wheel
RUN pip install *.whl && rm *.whl

COPY .env .

EXPOSE ${PORT}

CMD streamlit run --server.port=${PORT} --server.address=0.0.0.0 src/dev_dotenv/app.py 