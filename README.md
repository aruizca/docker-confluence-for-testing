This README is still WIP
---

 docker-confluence-for-testing
Docker image to run Atlassian Confluence using an Oracle JRE

# Overview
 
This Docker container makes it easy to get an instance of Confluence up and running.

# Main Usage

```bash
./scripts/run-confluence-container.sh [x.y.z]

```
x.y.z is an optional parameter with the Confluence version number you want to run.

Otherwise the default version that appears on the .env file will be used.


## Additional settings

```
./scripts/run-confluence-container.sh [x.y.z] [ENV=VALUE ENV2=VALUE]
```

### Debugging port
```
DEBUG_PORT=5006
```

### Change container localization and timezone
 ```
 TZ=America/Los_Angeles
 LC_ALL=en_US.UTF-8
 LANG=en_US.UTF-8
 LANGUAGE=en_US.UTF-8
 ```

--------
--------
### From here the documentation needs to be updated to reflect some of the changes made

 
# Quick Start
 
For the directory in the environmental variable `CONFLUENCE_HOME` that is used to store Confluence data
(amongst other things) we recommend mounting a host directory as a [data volume](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume):
 
Start Atlassian Confluence Server:
 
    $> docker run -v /data/your-confluence-home:/var/atlassian/application-data/confluence --name="confluence" -d -p 8090:8090 -p 8091:8091 atlassian/confluence-server
 

**Success**. Confluence is now available on [http://localhost:8090](http://localhost:8090)*
 
Please ensure your container has the necessary resources allocated to it.
We recommend 2GiB of memory allocated to accommodate the application server.
See [Supported Platforms](https://confluence.atlassian.com/display/DOC/Supported+platforms) for further information.
     
 
_* Note: If you are using `docker-machine` on Mac OS X, please use `open http://$(docker-machine ip default):8090` instead._
 
## Memory / Heap Size

If you need to override Confluence Server's default memory allocation, you can control the minimum heap (Xms) and maximum heap (Xmx) via the below environment variables.

* `JVM_MINIMUM_MEMORY` (default: 1024m)

   The minimum heap size of the JVM

* `JVM_MAXIMUM_MEMORY` (default: 1024m)

   The maximum heap size of the JVM

## Reverse Proxy Settings

If Confluence is run behind a reverse proxy server, then you need to specify extra options to make Confluence aware of the setup. They can be controlled via the below environment variables.

* `CATALINA_CONNECTOR_PROXYNAME` (default: NONE)

   The reverse proxy's fully qualified hostname.

* `CATALINA_CONNECTOR_PROXYPORT` (default: NONE)

   The reverse proxy's port number via which Confluence is accessed.

* `CATALINA_CONNECTOR_SCHEME` (default: http)

   The protocol via which Confluence is accessed.

* `CATALINA_CONNECTOR_SECURE` (default: false)

   Set 'true' if CATALINA_CONNECTOR_SCHEME is 'https'.

## JVM configuration

If you need to pass additional JVM arguments to Confluence such as specifying a custom trust store, you can add them via the below environment variable

* `JVM_SUPPORT_RECOMMENDED_ARGS`

   Additional JVM arguments for Confluence
   
Example:

    $> docker run -e JVM_SUPPORT_RECOMMENDED_ARGS=-Djavax.net.ssl.trustStore=/var/atlassian/application-data/confluence/cacerts -v confluenceVolume:/var/atlassian/application-data/confluence --name="confluence" -d -p 8090:8090 -p 8091:8091 atlassian/confluence-server

 
# Upgrade
 
To upgrade to a more recent version of Confluence Server you can simply stop the `Confluence`
container and start a new one based on a more recent image:
 
    $> docker stop confluence
    $> docker rm confluence
    $> docker run ... (see above)
 
As your data is stored in the data volume directory on the host, it will still
be available after the upgrade.
 
_Note: Please make sure that you **don't** accidentally remove the `confluence`
container and its volumes using the `-v` option._
 
# Backup
 
For evaluating Confluence you can use the built-in database that will store its files in the Confluence Server home directory. In that case it is sufficient to create a backup archive of the directory on the host that is used as a volume (`/data/your-confluence-home` in the example above).
 
Confluence's [automatic backup](https://confluence.atlassian.com/display/DOC/Configuring+Backups) is currently supported in the Docker setup. You can also use the [Production Backup Strategy](https://confluence.atlassian.com/display/DOC/Production+Backup+Strategy) approach if you're using an external database.
 
Read more about data recovery and backups: [Site Backup and Restore](https://confluence.atlassian.com/display/DOC/Site+Backup+and+Restore)
 
# Versioning
 
The `latest` tag matches the most recent release of Atlassian Confluence Server.
So `atlassian/confluence-server:latest` will use the newest stable version of Confluence Server available.
 
Alternatively, you can use a specific minor version of Confluence Server by using a version number
tag: `atlassian/confluence-server:5.10`. This will install the latest `5.10.x` version that
is available.
