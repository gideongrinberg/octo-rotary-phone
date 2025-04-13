FROM public.ecr.aws/lambda/python:3.12

RUN dnf install -y git
RUN pip install "astropy>=7.0.1" \ 
                "lightkurve>=2.5.0" \
                "polars>=1.26.0" \
                "tesswcs>=1.5.1" \ 
                "git+https://github.com/spacetelescope/astrocut@Footprint-Cutout" \ 
                "git+https://github.com/soichiro-hattori/unpopular"

RUN yes | pip uninstall asyncio

COPY src/popular/__init__.py ${LAMBDA_TASK_ROOT}/popular/
COPY src/pipeline.py ${LAMBDA_TASK_ROOT}

CMD ["pipeline.lambda_handler"]