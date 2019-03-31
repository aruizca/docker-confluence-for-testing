docker-confluence-for-testing (WIP)
---

 
Script that provides a one-off command to locally run any Atlassian Confluence version using an Oracle JRE on a Docker container.

It's purpose is just for quickly spin up any standalone version of Confluence to perform tests on it.

⚠️Important! This is not intended to be used in a production system.

# Usage

```bash
./scripts/run-confluence-container.sh [x.y.z]

```
x.y.z is an optional parameter with the Confluence version number you want to run.

Otherwise the default version that appears on the .env file will be used.

Confluence instance will be listening on http://localhost:8090/confluence

# Additional settings

```bash
./scripts/run-confluence-container.sh [x.y.z] [ENV=VALUE ENV2=VALUE]
```

## Debugging port
By default debugging port from host is 5006 but you can customise
```
DEBUG_PORT=5006
```

## Change container localization and timezone
 ```bash
 TZ=America/Los_Angeles
 LC_ALL=en_US.UTF-8
 LANG=en_US.UTF-8
 LANGUAGE=en_US.UTF-8
 ```

# Runtime Environment Setup
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


