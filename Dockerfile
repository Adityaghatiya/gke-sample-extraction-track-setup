# =======================================
# Stage 1: Builder - Install dependencies
# =======================================
FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Prevent Python from writing pyc files and buffer logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies required for building packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip setuptools wheel
# Install app dependencies + gunicorn (since not in requirements.txt)
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy the entire project
COPY . .

# Try to collect static files (don’t fail if settings missing)
RUN python manage.py collectstatic --noinput || echo "Skipping collectstatic step"

# =======================================
# Stage 2: Runtime Image
# =======================================
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN useradd -m appuser

# Copy Python environment and app from builder
COPY --from=builder /usr/local /usr/local
COPY --from=builder /app /app

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Expose port 8000 (Django)
EXPOSE 8000

# Switch to non-root user
USER appuser

# Default command: run database migrations, collectstatic, and start Gunicorn
CMD ["sh", "-c", "python manage.py migrate --noinput && python manage.py collectstatic --noinput && gunicorn core.wsgi:application --bind 0.0.0.0:8000"]
