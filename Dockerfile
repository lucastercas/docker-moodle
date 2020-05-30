FROM debian:10.4-slim AS base
RUN apt-get -y update && apt-get -y --no-install-recommends install git
ENV MOODLE_DIR "/var/www/html/moodle"
ARG MOODLE_VERSION="v3.8.3"
RUN git clone -v --progress --single-branch --depth=1 -b "${MOODLE_VERSION}" git://git.moodle.org/moodle.git "${MOODLE_DIR}" \
      && rm -rf "$MOODLE_DIR"/.git

FROM debian:10.4-slim
LABEL mantainer "Lucas Terças <lucasmtercas@gmail.com>"
ARG PHP_VERSION="7.3"
RUN apt-get -y update && apt-get -y --no-install-recommends install apache2 \ 
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
      libapache2-mod-php"$PHP_VERSION" \
      && rm -rf /var/lib/apt/lists/*; \
      a2enmod rewrite; \
      service apache2 stop
# Set Moodle settings
ENV MOODLE_DIR="/var/www/html/moodle" \
  MOODLEDATA_DIR="/var/www/moodledata" \
  MOODLE_WWWROOT="http://localhost/moodle" \
  MOODLE_ADMINUSER="admin_user" \
  MOODLE_ADMINMAIL="mail@mail.com" \
  MOODLE_NAME="moodle" \
  DB_NAME="moodle"
COPY --from=base /var/www/html/moodle /var/www/html/moodle
RUN mkdir "$MOODLEDATA_DIR" \
      && chmod 777 -R "$MOODLEDATA_DIR" \
      && chown root:www-data -R "$MOODLEDATA_DIR" \
      && rm /var/www/html/index.html
WORKDIR "$MOODLE_DIR"
COPY --chown=www-data:www-data ./scripts/docker-entrypoint.sh /usr/local/bin/
COPY ./scripts/check_db.php /scripts/check_db.php
EXPOSE 80 443
ENTRYPOINT [ "docker-entrypoint.sh" ]
