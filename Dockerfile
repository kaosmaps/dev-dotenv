# Build stage
FROM python:3.12-slim AS builder

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    # Prevent pip from caching
    PIP_NO_CACHE_DIR=1 \
    # Don't install unnecessary pip/poetry dependencies
    PIP_NO_DEPS=1 \
    POETRY_NO_DEV=1

WORKDIR /app

# Install poetry with pip's --no-cache-dir to save memory
RUN pip install --no-cache-dir poetry

# Copy just pyproject.toml first
COPY pyproject.toml README.md ./
# Copy lock file if it exists, otherwise create a new one
COPY poetry.lock* ./
RUN poetry lock --no-update || true

# Install dependencies
RUN poetry install --only main --no-root --no-interaction && rm -rf $POETRY_CACHE_DIR

# Build the wheel
COPY src ./src
RUN poetry build --format wheel

# Run stage
FROM python:3.12-slim AS runtime

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH" \
    # Default port if not set
    PORT=8501 \
    # Set production environment for dotenv-vault
    DOTENV_KEY=${DOTENV_KEY}

WORKDIR /app

# Copy the virtualenv with dependencies
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
# Copy the built wheel
COPY --from=builder /app/dist/*.whl ./

# Install our package from the wheel
RUN pip install *.whl && rm *.whl

# Copy only the vault file
COPY .env.vault .

EXPOSE ${PORT}

CMD streamlit run --server.port=${PORT} --server.address=0.0.0.0 src/dev_dotenv/app.py 