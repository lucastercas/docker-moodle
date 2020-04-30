FROM debian:10.3

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update \
    && apt-get upgrade -y \
    && apt install -y curl

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.9.4

RUN mkdir "${NVM_DIR}" \
    && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash;

RUN source "${NVM_DIR}"/nvm.sh \
    && nvm install "${NODE_VERSION}" \
    && nvm alias default "${NODE_VERSION}" \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN apt install apache2 -y; \
    a2enmod rewrite; \
    service apache2 stop; \
    apt install -y git php7.3 php7.3-bcmath php7.3-bz2 php7.3-cgi php7.3-cli php7.3-common php7.3-curl php7.3-dba php7.3-dev php7.3-enchant php7.3-fpm php7.3-gd php7.3-gmp php7.3-imap php7.3-interbase php7.3-intl php7.3-json php7.3-ldap php7.3-mbstring php7.3-mysql php7.3-odbc php7.3-opcache php7.3-pgsql php7.3-phpdbg php7.3-pspell php7.3-readline php7.3-recode php7.3-snmp php7.3-soap php7.3-sqlite3 php7.3-sybase php7.3-tidy php7.3-xml php7.3-xmlrpc php7.3-xsl php7.3-zip libapache2-mod-php7.3 netcat;

# Configure moodledata folder permissions
ENV MOODLEDATA_DIR /var/www/moodledata
RUN mkdir "${MOODLEDATA_DIR}" \
    && chmod 777 -R "${MOODLEDATA_DIR}" \
    && chown root:www-data -R "${MOODLEDATA_DIR}" \
    && rm /var/www/html/index.html;

ENV MOODLE_DIR /var/www/html/moodle
ENV MOODLE_BRANCH=MOODLE_38_STABLE
WORKDIR "${MOODLE_DIR}"
RUN git clone -v --progress  git://git.moodle.org/moodle.git "${MOODLE_DIR}" \
    && git branch --track "${MOODLE_BRANCH}" origin/"${MOODLE_BRANCH}" \
    && git checkout "${MOODLE_BRANCH}" \
    && chown root:www-data -R /var/www/html

COPY ./scripts/ /scripts/
RUN chmod 777 -R /scripts

# Moodle admin settings
ENV MOODLE_ADMINUSER admin
ENV MOODLE_ADMINPASS admin_passwd
ENV MOODLE_ADMINMAIL mail@email.com
ENV MOODLE_NAME moodle
ENV MOODLE_WWWROOT http://localhost/moodle

# Moodle DB settings
ARG DB_HOST
ARG DB_PORT
ARG DB_USER
ARG DB_PASS
ARG DB_NAME=moodle
ARG DB_DRIVER

EXPOSE 80
# EXPOSE 443

ENTRYPOINT [ "/scripts/run.sh" ]
