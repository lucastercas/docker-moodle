FROM alpine:3.12.0 AS base
RUN apk add --no-cache git
ENV MOODLE_DIR "/var/www/html"
ARG MOODLE_VERSION="v3.8.3"
RUN git clone --progress --single-branch --depth=1 -b "${MOODLE_VERSION}" git://git.moodle.org/moodle.git "${MOODLE_DIR}" \
      && rm -rf "$MOODLE_DIR"/.git

FROM debian:10.4-slim
ARG MOODLE_VERSION="v3.8.3"
ARG BUILD_VERSION
ARG BUILD_NUMBER
ARG BUILD_DATE
ARG GIT_COMMIT
LABEL org.moodle.image.author="Lucas Terças <lucasmtercas@gmail.com>" \
  org.moodle.image.source="https://github.com/lucastercas/docker-moodle" \
  org.moodle.image.build="docker build -t lucastercas/moodle:$MOODLE_VERSION --build-arg MOODLE_VERSION=$MOODLE_VERSION --build-arg BUILD_DATE=$BUILD_DATE --build-arg BUILD_VERSION=$BUILD_VERSION  --build-arg BUILD_NUMBER=$BUILD_NUMBER  --build-arg GIT_COMMIT=$GIT_COMMIT" \
  org.moodle.image.title="lucastercas/moodle" \
  org.moodle.image.version=$BUILD_VERSION \
  org.moodle.image.description="Docker image for Moodle" \
  org.moodle.image.build_number=$BUILD_NUMBER \
  org.moodle.image.created=$BUILD_DATE \
  org.moodle.image.commit=$GIT_COMMIT
ARG PHP_VERSION="7.3"
RUN apt-get -y update && apt-get -y --no-install-recommends install apache2 \ 
      vim \
      netcat \
      php"$PHP_VERSION" \
      php"$PHP_VERSION"-bcmath \
      php"$PHP_VERSION"-bz2 \
      php"$PHP_VERSION"-cgi \
      php"$PHP_VERSION"-cli \
      php"$PHP_VERSION"-common \
      php"$PHP_VERSION"-curl \
      php"$PHP_VERSION"-dba \
      php"$PHP_VERSION"-enchant \
      php"$PHP_VERSION"-fpm \
      php"$PHP_VERSION"-gd \
      php"$PHP_VERSION"-gmp \
      php"$PHP_VERSION"-imap \
      php"$PHP_VERSION"-interbase \
      php"$PHP_VERSION"-intl \
      php"$PHP_VERSION"-json \
      php"$PHP_VERSION"-ldap \
      php"$PHP_VERSION"-mbstring \
      php"$PHP_VERSION"-odbc \
      php"$PHP_VERSION"-opcache \
      php"$PHP_VERSION"-phpdbg \
      php"$PHP_VERSION"-pspell \
      php"$PHP_VERSION"-readline \
      php"$PHP_VERSION"-recode \
      php"$PHP_VERSION"-snmp \
      php"$PHP_VERSION"-soap \
      php"$PHP_VERSION"-sqlite3 \
      php"$PHP_VERSION"-pgsql \
      php"$PHP_VERSION"-mysql \
      php"$PHP_VERSION"-sybase \
      php"$PHP_VERSION"-tidy \
      php"$PHP_VERSION"-xml \
      php"$PHP_VERSION"-xmlrpc \
      php"$PHP_VERSION"-xsl \
      php"$PHP_VERSION"-zip \
      php"$PHP_VERSION"-redis \
      libapache2-mod-php"$PHP_VERSION" \
      && apt-get purge -y --auto-remove \
      && rm -rf /var/lib/apt/lists/*; \
      a2dismod mpm_event \
      && a2enmod rewrite; \
      service apache2 stop
# Set some defaults for Moodle env variables
ENV MOODLE_DIR="/var/www/html" \
  MOODLEDATA_DIR="/var/www/moodledata" \
  MOODLE_ADMIN_USER="admin_user" \
  MOODLE_ADMIN_EMAIL="moodle.admin@mail.com" \
  MOODLE_NAME="moodle" \
  DB_NAME="moodle"
ARG DB_DRIVER
ARG DB_HOST
ARG DB_PORT
ARG DB_USER
ARG DB_PASSWORD
RUN mkdir -p "$MOODLEDATA_DIR" \
      && chmod 755 -R "$MOODLEDATA_DIR" \
      && chown www-data:www-data -R "$MOODLEDATA_DIR" \
      && rm "$MOODLE_DIR"/index.html
COPY --from=base --chown=www-data:www-data /var/www/html /var/www/html
WORKDIR "$MOODLE_DIR"
COPY --chown=www-data:www-data ./scripts/docker-entrypoint.sh /usr/local/bin/
COPY --chown=www-data:www-data ./scripts/check-db-tables.php /scripts/
STOPSIGNAL SIGWINCH
EXPOSE 80 443
VOLUME /var/www/moodledata
ENTRYPOINT [ "docker-entrypoint.sh" ]
