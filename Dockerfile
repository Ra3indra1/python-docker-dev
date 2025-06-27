# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.11.9
FROM python:${PYTHON_VERSION}-slim AS base

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Prevents Python from buffering stdout/stderr.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-privileged user that the app will run under.
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Copy dependencies and install.
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

# Use the non-root user.
USER appuser

# Copy the source code.
COPY . .

# Expose app port.
EXPOSE 8000

# Run the FastAPI app using uvicorn.
CMD ["uvicorn", "app:app", "--host=0.0.0.0", "--port=8000"]
