FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y git && apt-get clean

COPY pyproject.toml /app/
COPY src/ /app/src/

# Install dependencies
RUN pip install --no-cache-dir "astropy>=7.0.1" \
                "lightkurve>=2.5.0" \
                "polars>=1.26.0" \
                "tesswcs>=1.5.1" \
                "google-cloud-storage>=2.0.0" \
                "functions-framework>=3.0.0" \
                "git+https://github.com/spacetelescope/astrocut@Footprint-Cutout" \
                "git+https://github.com/soichiro-hattori/unpopular"

# Configure the container to use the Cloud Function entrypoint
ENV FUNCTION_TARGET=tess_pipeline
ENV PORT=8080

# Install Functions Framework
RUN pip install --no-cache-dir functions-framework

# Run the web service on container startup
CMD [ "functions-framework", "--target=tess_pipeline", "--source=src/main.py" ]