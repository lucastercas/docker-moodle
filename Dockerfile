FROM debian:latest

USER root

RUN apt-get update; \
    apt-get upgrade -y; \
    apt install git -y; \
    apt install apache2 -y; \
    apt install npm -y; \
    a2enmod rewrite; \
    service apache2 stop; \
    apt install vim php7.3 php7.3-bcmath php7.3-bz2 php7.3-cgi php7.3-cli php7.3-common php7.3-curl php7.3-dba php7.3-dev php7.3-enchant php7.3-fpm php7.3-gd php7.3-gmp php7.3-imap php7.3-interbase php7.3-intl php7.3-json php7.3-ldap php7.3-mbstring php7.3-mysql php7.3-odbc php7.3-opcache php7.3-pgsql php7.3-phpdbg php7.3-pspell php7.3-readline php7.3-recode php7.3-snmp php7.3-soap php7.3-sqlite3 php7.3-sybase php7.3-tidy php7.3-xml php7.3-xmlrpc php7.3-xsl php7.3-zip libapache2-mod-php7.3 netcat -y; \
    npm i -g npm@latest

# Moodle installation settings
ARG MOODLEDATA_DIR=/var/www
ENV MOODLEDATA_DIR ${MOODLEDATA_DIR}
ARG MOODLE_BRANCH=MOODLE_38_STABLE
ENV MOODLE_BRANCH ${MOODLE_BRANCH}
ARG SKIP_DB_INSTALL
ENV SKIP_DB_INSTALL ${SKIP_DB_INSTALL}

# Configure moodle and moodledata folder permissions
RUN mkdir ${MOODLEDATA_DIR}/moodledata; \
    chmod 777 -R ${MOODLEDATA_DIR}/moodledata; \
    chown root:www-data -R ${MOODLEDATA_DIR}/moodledata

WORKDIR /var/www/html
RUN git clone -v --progress  git://git.moodle.org/moodle.git; \
    (cd moodle; git branch --track ${MOODLE_BRANCH} origin/${MOODLE_BRANCH}); \
    (cd moodle; git checkout ${MOODLE_BRANCH}); \
    rm /var/www/html/index.html; \
    chown root:www-data -R ./

COPY ./scripts/ /scripts/
RUN chmod 777 -R /scripts

# Moodle admin settings
ARG MOODLE_ADMINUSER=admin
ENV MOODLE_ADMINUSER ${MOODLE_ADMINUSER}
ARG MOODLE_ADMINPASS
ARG MOODLE_ADMINMAIL=mail@email.com
ENV MOODLE_ADMINMAIL ${MOODLE_ADMINMAIL}
ARG MOODLE_NAME=moodle
ENV MOODLE_NAME ${MOODLE_NAME}
ARG MOODLE_WWWROOT=http://localhost/moodle
ENV MOODLE_WWWROOT ${MOODLE_WWWROOT}

# Moodle DB settings
ARG DB_HOST
ARG DB_PORT
ARG DB_USER
ARG DB_PASS
ARG DB_NAME=moodle
ENV DB_NAME ${DB_NAME}
ARG DB_DRIVER

ENTRYPOINT [ "/scripts/run.sh" ]
