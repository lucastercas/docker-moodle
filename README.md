# Docker Image for Moodle

![Docker Image CI](https://github.com/lucastercas/docker-moodle/workflows/Docker%20Image%20CI/badge.svg)

## Supported tags and respective `Dockerfile` links

- [ `3.8`, `latest` ](https://github.com/lucastercas/docker-moodle)
- [ `3.7` ]()

## Quick reference

- **Where to get help**:
  [GitHub Issues Page](https://github.com/lucastercas/docker-moodle/issues)

- **Maintained by**:
  [lucastercas](https://github.com/lucastercas)

- **Source of this description**:
  [docs repo's `moodle/` directory](https://github.com/lucastercas/docker-moodle/blob/master/README.md)

## What is Moodle?

<img src="https://raw.githubusercontent.com/lucastercas/docker-moodle/master/moodle-logo.png" width="70%">

[Moodle oficial site](https://moodle.org/?lang=pt_br)

## How to use this image
```bash
$ docker run -it lucastercas/moodle
```

### Start a `Moodle` server instance

### Via `docker-compose`

If you run your own mysql on a container, the container needs this file for configuration:
```cnf
[client]
default-character-set = utf8mb4

[mysqld]
innodb_file_format = Barracuda
innodb_file_per_table = 1
innodb_large_prefix

character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
skip-character-set-client-handshake

[mysql]
default-character-set = utf8mb4
```

```yaml
version: "2.4"

services:

  moodle:
    image: lucastercas/moodle:latest
    container_name: moodle
    ports:
      - "80:80"
    volumes:
      - moodle_data:/var/www/moodledata
      - ./moodle/:/var/www/html/moodle # If on development
    networks:
      - moodle_net
    environment:
      DB_HOST: moodle_db
      DB_USER: moodle
      DB_PASS: example
      DB_DRIVER: mysqli
      DB_NAME: moodle
      MOODLE_ADMINPASS: example

  moodle_db:
    image: mysql:5.6.46
    container_name: moodle_db
    networks:
      - moodle_net
    volumes:
      - ./my.cnf:/etc/mysql/my.cnf
      - moodle_db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: example_root
      MYSQL_USER: moodle
      MYSQL_PASSWORD: example
      MYSQL_DATABASE: moodle

networks:
  moodle_net:

volumes:
  moodle_db_data:
    driver: local
  moodle_data:
    driver: local
```

### On development
```yaml
version: "2.4"
services:
  moodle:
    image: lucastercas/moodle
    ports:
      - "80:80"
    volumes:
      - .:/var/www/html/moodle
    environments:
      DB_USER: db_user
      DB_PASS: example
      DB_HOST: moodle_db
      DB_DRIVER: mysqli
      MOODLE_ADMINPASS: example

  moodle_db:
    image: mysql:5.6.46
    restart: always
    environment:
      MYSQL_USER: db_user
      MYSQL_PASSWORD: example
      MYSQL_DATABASE: moodle
      MYSQL_ROOT_PASSWORD: example_root
```

## Environment Variables
When you start this `moodle` image, you have to provide certain environment variables, so it knows where the database is located, as well as certain

### Installation configuration variables

#### `SKIP_DB_INSTALL`
Moodle needs a config.php file to run, that can be created using the `admin/cli/
install.php` script, which is used on the image to create it, everytime a
container is created, but this script also initializes the database, creating the
 tables and populating it. The `SKIP_DB_INSTALL` skips the database creation,
 and only writes the config.php file.

### Moodle configuration variables

#### `MOODLE_ADMINUSER`
Optional variable, sets the login to use for the `administrator` account, default is `admin`.

#### `MOODLE_ADMINPASS`
Password for the administrator account, there is no default.

#### `MOODLE_ADMINMAIL`
Optioanl variable, sets the email of the administrator user, default is `mail@email.com`.

#### `MOODLE_NAME`
Optional variable, sets the name of the Moodle instance, default is `moodle`.

#### `MOODLE_WWWROOT`
Location of the web site, default is `http://localhost/moodle`.

### Database configuration variables

#### `DB_HOST`
Host of the database.

#### `DB_PORT`
Optional variables, sets the port that the host of the database is exposing to access it, initial Moodle installation sets for the default port according to the `DB_DRIVER` used.

#### `DB_USER`
User of datbase.

#### `DB_PASS`
Password of `DB_USER`.

#### `DB_NAME`
Optional variable, name of database that this instance of Moodle will use, default is `moodle`.

#### `DB_DRIVER`
Type of driver, this can be `pgsql`, `mariadb`, `mysqli`, `sqlsrv` or `oci`. Depends on the type of the database on `DB_HOST`

## Caveats
