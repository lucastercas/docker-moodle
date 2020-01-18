# Docker Image for Moodle

## Supported tags and respective `Dockerfile` links

- [`3.8`, `latest`](https://github.com/lucastercas/docker-moodle)

## Quick reference

- **Where to get help**:
  [GitHub Issues Page](https://github.com/lucastercas/docker-moodle/issues)

- **Maintened by**:
  [lucastercas](https://github.com/lucastercas)

- **Source of this description**:
  [docs repo's `moodle/` directory](https://github.com/lucastercas/docker-moodle/blob/master/README.md)

## What is Moodle?

![logo](https://raw.githubusercontent.com/lucastercas/docker-moodle/master/moodle-logo.png | width=100)

## How to use this image
```console
$ docker run -it lucastercas/moodle
```

### Start a `Moodle` server instance

### Via `docker-compose`
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

#### `MOODLEDATA_DIR`
Directory on filesystem where the `moodledata` will be stored. Moodle

#### `SKIP_DB_INSTALL`
Optional variable, serves to instruct the installation if it should install the moodle tables on the database, then create the config.php file. Default is "false", set it to "true" on the so the scripts skip the database installation.

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