FROM nginx:1.11
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils \
                       locales
ENV LANG ja_JP.UTF-8
ENV LC_TIME C
ADD ./docker/web/nginx.conf /etc/nginx/nginx.conf
ADD ./docker/web/default.conf /etc/nginx/conf.d/default.conf
