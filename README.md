# Docker Image for Moodle

![Docker Image CI](https://github.com/lucastercas/docker-moodle/workflows/Docker%20Deploy/badge.svg)

## Supported tags and respective `Dockerfile` links

- [ `v3.8.3`, `latest` ](https://github.com/lucastercas/docker-moodle)
- [ `v3.7.6` ](https://github.com/lucastercas/docker-moodle)

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

### Using `docker run`
``` bash
$ docker run --rm -it -p 80:80 lucastercas/moodle:latest
```
This will start an instance of Moodle on port `80` of the host. However, as there is no database,
it will crash

### Using `docker-compose.yml`
```yaml
version: "3.7"
services:
  moodle:
    image: lucastercas/moodle:v3.8.3
    ports:
      - "80:80"
    environments:
      DB_USER: db_user
      DB_PASS: db_pass
      DB_HOST: db
      DB_DRIVER: pgsql
      MOODLE_ADMINPASS: admin_pass

  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_USER: db_pass
      POSTGRES_PASSWORD: db_user
      POSTGRES_DB: moodle
```
```bash
$ docker-compose up
```

## Environment Variables
When you start this `moodle` image, you have to provide certain environment variables, so it knows where the database is located, as well as certain Moodle parameters.

### Moodle configuration variables

#### `MOODLE_ADMINUSER`
Optional variable, sets the login to use for the `administrator` account, default is `admin_user`.

#### `MOODLE_ADMINPASS`
Password for the administrator account, there is no default.

#### `MOODLE_ADMINMAIL`
Optional variable, sets the email of the administrator user, default is `mail@email.com`.

#### `MOODLE_NAME`
Optional variable, sets the name of the Moodle instance, default is `moodle`.

#### `MOODLE_WWWROOT`
Location of the web site, default is `http://localhost/moodle`.

#### `MOODLE_DIR`
Location of Moodle, default is `/var/www/html/moodle`.

#### `MOODLE_DATADIR`
Location of moodledata, default is `/var/www/moodledata`.

### Database configuration variables

#### `DB_HOST`
Host of the database.

#### `DB_USER`
User of database.

#### `DB_PASS`
Password of `DB_USER`.

#### `DB_NAME`
Optional variable, name of database that this instance of Moodle will use, default is `moodle`.

#### `DB_DRIVER`
Type of driver, this can be `pgsql`, `mariadb`, `mysqli`, `sqlsrv` or `oci`. Depends on the type of the database on `DB_HOST`

## Extending this image
