# Docker-confluence-for-testing (WIP)

Script that provides a one-off command to locally run any Atlassian Confluence version using an Oracle JRE on a Docker container.

It's purpose is just for quickly spin up any standalone version of Confluence to perform tests on it.

⚠️Important! This is not intended to be used in a production system.

## Requirements

The only requirement is to have [Docker installed](https://www.docker.com/products/docker-desktop).

Adjusting the available RAM for the Docker engine to at least 4GB is also required. You can find the settings in Docker -> Preferences -> Advanced.

## Before starting
##⚠️ <span style="color:Orange"> Important! Rename the ".env.sample" file to ".env" in which all the default values for the used environment variables are set.</span>

## Usage

Its main usage includes a container which will make use of the [puppeteer-confluence-setup image at Docker Hub](https://hub.docker.com/repository/docker/aruizca/puppeteer-confluence-setup) to automate also the initial setup process. For more info go to the [puppeteer-confluence-setup GitHub repo](https://github.com/aruizca/puppeteer-confluence-setup).

```bash
./scripts/run-confluence-container.sh

```

If you want to perform the setup process manually you could use the next flags:

### Version flag -v

```bash
./scripts/run-confluence-container-no-setup.sh -v [x.y.z]
```

-v [x.y.z] is an optional flag that follows with the Confluence version number you want to run.

Otherwise, the default version that appears on the .env file will be used.

### Alias flag -a

Using -a flag, you can add an alias to your docker container.

```bash
./scripts/run-confluence-container-no-setup.sh -a [alias]
```

This way, the container name will add the alias to the actual container name. 

So if we run the script without any flag:

```bash
./scripts/run-confluence-container-no-setup.sh
```
The container name will be: 7-9-0--8090

But if you run it with an alias:

```bash
./scripts/run-confluence-container-no-setup.sh -a aliasName
```

The container name will be: 7-9-0--8090--aliasName

### Environment variables flag -e

You also can set your own environment variables by using the "-e" flag.

```bash
./scripts/run-confluence-container-no-setup.sh -e "ENV=VALUE ENV2=VALUE"
```

This way the environment variables passed in the flag will override the actual ones and will be used in the script.
Note that if you want to set more than one environment variable, you will have to write them within the "" quotes.


## Default Confluence Build
The docker container will be generated using the ports showed below.

| ENV_VARIABLE          |      |      |     |     |     |     |
|-----------------------|------|:----:|-----|-----|-----|-----|
| CONFLUENCE_PORTS_LIST | 8090 | 9010 |  9020   |   9030  |   9040  |    9050 |
| LDAP_PORTS_LIST       | 388  | 389  |  387   |  386   |  385   |   384  |
| POSTGRES_PORTS_LIST   | 5543 | 5432 |   5654  |  5765   |   5876  |  5987   |
| DEBUG_PORTS_LIST      | 5007 | 5006 |  5008   |  5009   |  5010   | 5011    |

For each Confluence instance we try to start up, it will check if the port is being used, if so, it will use the next one according to the table.

This way, the first Confluence instance we create will be listening on <http://localhost:8090/confluence>, the second one <http://localhost:9010/confluence> and so on.

If you prefer using your own port lists, you can set them in your environment variables separating the ports with "," for example:

```bash 
export CONFLUENCE_PORTS_LIST=7980,7970,7960,7950,7940,7930
```

or pass the value in the -e flag:

```bash 
./scripts/run-confluence-container-no-setup.sh -e  CONFLUENCE_PORTS_LIST=7980,7970,7960,7950,7940,7930
```

## Confluence Volume

This script will also create a volume connected to the home path of the conflunce server in your machine to easily access the data of the server.
This way you can open the files using your favorite text editor.

The path of the directory is allocated in the same path of the project, but it can be modified by changing the "VOLUME_PATH" environment variable.

eg:

```bash
./scripts/run-confluence-container-no-setup.sh -v 7.20.0 -a volumeContainer
```

The created folder will have the next name: 7-20-0--9010--volumeContainer


## Other useful scripts

- `install-app.sh`: script to install an app via URL or file path. `install-app.sh -h` for details.

- `install-app-license.sh`: script to add licensing to a previously installed app. `install-app-license.sh -h` for details.

- `full-app-setup-example.sh`: this example shows the full cycle of installing Confluence, set it up, install an app, and add a license. This is useful to prepare the environment to execute e2e tests.

## Zenity based GUI script
### Description
In order to ease starting Confluence instances to users that are not familiar with the command line and are not familiar with the different available options to run the Confluence instance, there is a script that has a Graphic User Interface (GUI) guiding the user through them.

Once the selection of the options through the graphic interface is completed, then the right script with the right parameters will be run automatically.

### Requirements
This script was tested using [this custom Zenity implementation](https://github.com/ncruces/zenity) as a dependency. You can obtain the `zenity` command to make this script work, as follows:

On macOS/WSL using [Homebrew](https://brew.sh/) 🍺:

    brew install ncruces/tap/zenity

On Windows using [Scoop](https://scoop.sh/) 🍨:

    scoop install https://ncruces.github.io/scoop/zenity.json

### How to run it
This script can be run normally by running the following in a command console:

      ./scripts/confluence-setup-app.sh 

Or if you are in macOS you could simply rename `confluence-setup-app.sh` to `confluence-setup-app.command` which is an executable you can double-click on from your desktop.

Both options will prompt a window where you can start selecting the different options you wish your Confluence instance to have.

### Zenity Documentation
If you wish to know more about how this script with Zenity works and modify it to suit your needs, here you have some of the documentation used:

- https://manpages.ubuntu.com/manpages/trusty/man1/zenity.1.html

- https://help.gnome.org/users/zenity/stable/index.html.en

## Java JDK

You can choose with version of java is going to be installed in container.
To use this feature, you need to set JAVA_VERSION variable when runing the container.

Java version should be in the format vendor@version, as used in JABBA.
If no JAVA_VERSION is set, by default, version to be installed is: `zulu@1.8.232`

For example , to run a container with confluece 5.4.4 (which need java 7) and the zulu 1.7.95 version (which is supportorted by JABBA):

```bash
./scripts/run-confluence-container.sh -v 5.4.4 -e JAVA_VERSION=zulu@1.7.95
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
./scripts/run-confluence-container.sh -v [x.y.z] -e DATABASE=oracle
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
./scripts/run-confluence-container.sh -v 6.15.1 -e POSTGRESQL_VERSION=10.2
```

You can use any of the versions available in [the official PostgreSQL Docker repository](https://hub.docker.com/_/postgres)

⚠️Important! Versions earlier that 9.6 present problems with Collaborative Editing feature.

#### DB recommended version
| Confluence Version | PostgreSQL version |
|--------------------|:------------------:|
| 7.9.0 - 7.20.0     |        9.6         |
      |

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