# Docker-confluence-for-testing (WIP)

Script that provides a one-off command to locally run any Atlassian Confluence version using an Oracle JRE on a Docker container.

It's purpose is just for quickly spin up any standalone version of Confluence to perform tests on it.

⚠️Important! This is not intended to be used in a production system.

## Requirements

The only requirement is to have [Docker installed](https://www.docker.com/products/docker-desktop).

Adjusting the available RAM for the Docker engine to at least 4GB is also required. You can find the settings in Docker -> Preferences -> Advanced.

## Usage

Its main usage includes a container which will make use of the [puppeteer-confluence-setup image at Docker Hub](https://hub.docker.com/repository/docker/aruizca/puppeteer-confluence-setup) to automate also the initial setup process. For more info go to the [puppeteer-confluence-setup GitHub repo](https://github.com/aruizca/puppeteer-confluence-setup).

```bash
./scripts/run-confluence-container.sh [x.y.z]

```

If you want to perform the setup process manually:

```bash
./scripts/run-confluence-container-no-setup.sh [x.y.z]
```

x.y.z is an optional parameter with the Confluence version number you want to run.

Otherwise the default version that appears on the .env file will be used.

Confluence instance will be listening on <http://localhost:8090/confluence>

## Additional settings

```bash
./scripts/run-confluence-container.sh [x.y.z] [ENV=VALUE ENV2=VALUE]
```

⚠️ Note that it is recommended to provided an environment variable with a valid Confluence instance license, otherwise a [3 hours timebomb license provided by Atlassian](https://developer.atlassian.com/platform/marketplace/timebomb-licenses-for-testing-server-apps/) will be used. Example:

```bash
PPTR_CONFLUENCE_LICENSE=...
```

## Java JDK

You can choose with version of java is going to be installed in container.
To use this feature, you need to set JAVA_VERSION variable when runing the container.

Java version should be in the format vendor@version, as used in JABBA.
If no JAVA_VERSION is set, by default, version to be installed is: `zulu@1.8.232`

For example , to run a container with confluece 5.4.4 (which need java 7) and the zulu 1.7.95 version (which is supportorted by JABBA):

```bash
./scripts/run-confluence-container.sh 5.4.4 JAVA_VERSION=zulu@1.7.95
```

You can check available vendor/version
> <https://github.com/shyiko/jabba/blob/master/index.json>

## Database selection

By default, it uses postgres, but to make it easier to test with, now the script can also run diferent databases.
This databases are ready to work, and already configured to work with confluence, so there is no need to
do any modification (althouh you many need to install the driver into confluence)

These are the new supported databases:

mysql:
   - version: 5.6 
   - db: confluence
   - user: confluenceUser
   - pass: confluenceUser
   - root pass: password

oracle
    - version: 2017
    - b: confluence
    - user: confluenceUser
    - pass: confluenceUser
    - root pass: Confluenc3

sqlserver
    - version: 12C
    - db: CONFLUENCE_TS
    - user: confluence
    - pass: confluence
    - sid: xe

For example to run the oracle database jsut do the following:

```bash
./scripts/run-confluence-container.sh [x.y.z] DATABASE=oracle
```

## Debugging port

By default debugging port from host is 5006 but you can customise

```bash
DEBUG_PORT=5006
```

## Change container localization and timezone

 ```bash
 TZ=America/Los_Angeles
 LC_ALL=en_US.UTF-8
 LANG=en_US.UTF-8
 LANGUAGE=en_US.UTF-8
 ```

## Runtime Environment Setup

Several other services are started up along with the Confluence instance to customize your setup:

## Database

Instead of using the embedded H2 DB, you can configure your Confluence instance to use a proper DB engine. In fact this is really advisable if you want to run a Confluence version >= 6.x and use collaborative editing.

At the moment only PostgreSQL is available but we plan to support other DB engines in the future.

### PostgreSQL

By default a container named "postgres" is up using version 9.6, which seems to be the minimum version to run collaborative editing service "Synchrony" without issues.

#### Details

- Container name and hostname: postgres
- DB name: confluence
- DB username: postgres
- DB password: postgres
- JDBC connection URL: jdbc:postgresql://postgres:5432/confluence

#### Changing version

You can change the default PostgreSQL version (9.6) by adding the environment variable `POSTGRESQL_VERSION`. Eg:

```bash
./scripts/run-confluence-container.sh 6.15.1 POSTGRESQL_VERSION=10.2
```

You can use any of the versions available in [the official PostgreSQL Docker repository](https://hub.docker.com/_/postgres)

⚠️Important! Versions earlier that 9.6 present problems with Collaborative Editing feature.

#### DB recommended version
| Confluence Version | PostgreSQL version |
|--------------------|:------------------:|
| 5.8.x - 5.10.x     |        9.5         |
| 6.0.x - ...        |        9.6         |

## External user directory

Most companies use an external directory services to manage users authentication and authorization. To test that scenario I have forked and customized a [Docker image with OpenLDAP in this repository](https://github.com/aruizca/docker-test-openldap), so it can be used out of the box for that purpose.

A container using this image will be run along with Confluence and available if needed.

That repo contains also the setting to configure it inside Confluence.

## Troubleshooting

### After setting up Confluence everything is slow

This might be due to the synchrony server (collaborative editing) failing to start up correctly. You can disable synchrony via REST API using the following GET request:

> <http://localhost:8090/confluence/rest/synchrony-interop/disable?os_username=admin&os_password=admin>

Also makes sure that in the Advanced Docker preferences the amount of RAM available for the Docker engine is at least 4GB.

### Windows 10
When cloning this repo to a Windows machine, file endings won't be the same as in Unix. To avoid this,
you can either clone the repo specifying this option:
````bash
git clone git@github.com:aruizca/docker-confluence-for-testing.git --config core.autocrlf=input
````
Or modify the entrypoint.sh file to use Unix file ending (LF) instead of Windows file ending (CRLF).