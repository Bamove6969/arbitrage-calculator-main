# Use slim to keep the image small
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv for fast package installation
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Copy requirements first for better caching
COPY requirements.txt .
RUN uv pip install --system -r requirements.txt

# Copy the app
COPY backend/ backend/
COPY main.py .
COPY client/ client/
COPY start.sh .
COPY AGENTS.md .

# Expose ports (backend + dashboard)
EXPOSE 8000 5000

# Environment
ENV PYTHONPATH=/app
ENV IB_GATEWAY_URL=http://ibga:4000

# Run the app
CMD ["python", "-m", "uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]