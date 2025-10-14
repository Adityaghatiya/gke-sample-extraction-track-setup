# ============================================
# Stage 1: Builder - Install dependencies
# ============================================
FROM python:3.11-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install build dependencies (for psycopg2, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for layer caching
COPY requirements.txt .

RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy application source
COPY . .

# Collect static files during build (safe if settings require)
RUN python manage.py collectstatic --noinput || echo "Skipping collectstatic"

# ============================================
# Stage 2: Runtime - Minimal final image
# ============================================
FROM python:3.11-slim

WORKDIR /app

# Create a non-root user
RUN useradd -m appuser

# Copy only runtime essentials
COPY --from=builder /usr/local /usr/local
COPY --from=builder /app /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Expose port
EXPOSE 8000

# Switch to non-root user
USER appuser

# Run database migrations + start gunicorn
CMD ["sh", "-c", "gunicorn core.wsgi:application --bind 0.0.0.0:8000"]
