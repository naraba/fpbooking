FROM mysql:8.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils \
                       locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
COPY ./docker/mysql/my.cnf /etc/mysql/conf.d/my.cnf
