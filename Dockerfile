# The build image, used to build the virtual environment
FROM python:3.9-buster as build

RUN pip install poetry==1.4.2

# Set environment variables for Poetry and pip
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV POETRY_NO_INTERACTION=1
ENV POETRY_VIRTUALENVS_IN_PROJECT=1
ENV POETRY_VIRTUALENVS_CREATE=1
ENV POETRY_CACHE_DIR=/tmp/poetry_cache
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_DEFAULT_TIMEOUT=100

WORKDIR /app

COPY pyproject.toml poetry.lock ./

# Install dependencies
RUN poetry install --no-root --no-interaction && rm -rf $POETRY_CACHE_DIR

# The runtime image, used to just run the code provided the virtual environment
FROM public.ecr.aws/lambda/python:3.9 as runtime

COPY --from=build /app/.venv/lib/python3.9/site-packages /var/task/
# COPY ./src src
COPY main.py main.py

ENTRYPOINT [ "python3" ]
CMD [ "main.py" ]

