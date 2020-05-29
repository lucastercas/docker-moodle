FROM debian:10.3
LABEL mantainer "Lucas Terças <lucasmtercas@gmail.com>"
ARG NODE_VERSION="8.9.4"
ARG NVM_VERSION="0.35.3"
ARG PHP_VERSION="7.3"
# I need bash for some commands
RUN rm /bin/sh && ln -s /bin/bash /bin/sh; \
    apt-get update \
    && apt-get upgrade -y \
    && apt install -y curl apache2 git netcat php"${PHP_VERSION}" php"${PHP_VERSION}"-bcmath php"${PHP_VERSION}"-bz2 php"${PHP_VERSION}"-cgi php"${PHP_VERSION}"-cli php"${PHP_VERSION}"-common php"${PHP_VERSION}"-curl php"${PHP_VERSION}"-dba php"${PHP_VERSION}"-dev php"${PHP_VERSION}"-enchant php"${PHP_VERSION}"-fpm php"${PHP_VERSION}"-gd php"${PHP_VERSION}"-gmp php"${PHP_VERSION}"-imap php"${PHP_VERSION}"-interbase php"${PHP_VERSION}"-intl php"${PHP_VERSION}"-json php"${PHP_VERSION}"-ldap php"${PHP_VERSION}"-mbstring php"${PHP_VERSION}"-mysql php"${PHP_VERSION}"-odbc php"${PHP_VERSION}"-opcache php"${PHP_VERSION}"-pgsql php"${PHP_VERSION}"-phpdbg php"${PHP_VERSION}"-pspell php"${PHP_VERSION}"-readline php"${PHP_VERSION}"-recode php"${PHP_VERSION}"-snmp php"${PHP_VERSION}"-soap php"${PHP_VERSION}"-sqlite3 php"${PHP_VERSION}"-sybase php"${PHP_VERSION}"-tidy php"${PHP_VERSION}"-xml php"${PHP_VERSION}"-xmlrpc php"${PHP_VERSION}"-xsl php"${PHP_VERSION}"-zip libapache2-mod-php"${PHP_VERSION}" \
    && rm -rf /var/lib/apt/lists/*; \
    a2enmod rewrite; \
    service apache2 stop;
# Install node and NPM
ENV NVM_DIR="/usr/local/nvm" \
    NODE_PATH="$NVM_DIR/v$NODE_VERSION/lib/node_modules" \
    PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"
RUN mkdir "${NVM_DIR}" \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v"${NVM_VERSION}"/install.sh | bash \
    && source "${NVM_DIR}"/nvm.sh \
    && nvm install "${NODE_VERSION}" \
    && nvm alias default "${NODE_VERSION}" \
    && nvm use default
# Set Moodle settings
ARG MOODLE_VERSION="MOODLE_37_STABLE"
ENV MOODLE_DIR="/var/www/html/moodle" \
    MOODLEDATA_DIR="/var/www/moodledata" \
    MOODLE_WWWROOT="http://localhost/moodle"
WORKDIR "${MOODLE_DIR}"
# Clone Moodle repository, and checkout selected branch
RUN git clone -v --progress  git://git.moodle.org/moodle.git --depth=1 -b "${MOODLE_VERSION}" "${MOODLE_DIR}" \
    && mkdir "${MOODLEDATA_DIR}" \
    && chmod 777 -R "${MOODLEDATA_DIR}" \
    && chown root:www-data -R /var/www/ \
    && rm /var/www/html/index.html
# Copy custom scripts
COPY --chown=www-data:www-data ./scripts/docker-entrypoint.sh /usr/local/bin/
COPY ./scripts/check_db.php /scripts/check_db.php
EXPOSE 80 443
ENTRYPOINT [ "docker-entrypoint.sh" ]
