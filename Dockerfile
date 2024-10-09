FROM python:3.11-alpine

LABEL org.label-schema.name="Lehrstuhl für Informations- und Automatisierungssyteme der RWTH Aachen" \
      org.label-schema.version="1.0" \
      org.label-schema.description="Docker image for the basyx-python-sdk server application" \
      org.label-schema.maintainer="IAT"

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


RUN apk update && apk add --no-cache nginx supervisor

# If we have more dependencies for the server it would make sense
# to refactor this to the pyproject.toml
RUN pip install uwsgi

RUN rm /etc/nginx/conf.d/default.conf

COPY uwsgi.ini /etc/uwsgi/

COPY supervisord.ini /etc/supervisor/conf.d/supervisord.ini

COPY stop-supervisor.sh /etc/supervisor/stop-supervisor.sh
RUN chmod +x /etc/supervisor/stop-supervisor.sh

# Makes it possible to use a different configuration
ENV UWSGI_INI /app/uwsgi.ini


# object stores aren't thread-safe yet
# https://github.com/eclipse-basyx/basyx-python-sdk/issues/205
ENV UWSGI_CHEAPER 0
ENV UWSGI_PROCESSES 1

# Should match client_body_buffer_size defined in nginx/body-buffer-size.conf
ENV NGINX_MAX_UPLOAD 1M

ENV NGINX_WORKER_PROCESSES 1

ENV LISTEN_PORT 80



RUN pip install --no-cache-dir git+https://github.com/rwth-iat/basyx-python-sdk@main

COPY ./app /app
COPY ./nginx /etc/nginx/conf.d

CMD ["/usr/bin/supervisord"]