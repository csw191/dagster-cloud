FROM python:3.12-slim AS base
 
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1
 
# Install packages with optimized approach
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
RUN pip install uv
 
WORKDIR /app
 
# Copy dependency files and README.md
COPY pyproject.toml uv.lock* README.md ./
 
# Development stage
FROM base AS development
RUN uv sync --dev
COPY . .
CMD ["uv", "run", "dagster", "dev", "--host", "0.0.0.0"]
 
# Production stage  
FROM base AS production
RUN uv sync --no-dev
COPY . .
 
# Create directory for secrets (useful for Dagster Cloud)
RUN mkdir -p /app/secrets
 
# Health check - using a simple Python import check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD python -c "import dagster; print('OK')" || exit 1
 
# Use non-root user for security
USER 1001
 
# Use Dagster gRPC API on port 4000 for production/Dagster Cloud
CMD ["uv", "run", "dagster", "api", "grpc", "--host", "0.0.0.0", "--port", "4000"]
