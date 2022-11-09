FROM nginx:latest

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./uwsgi_params /etc/nginx/uwsgi_params

RUN mkdir -p /vol/static && \
    chmod 755 /vol/static

VOLUME /vol/static
