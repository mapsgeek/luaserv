#### PostGIS Day 2021 patterns/examples coming soon!

## Scriptable Web Server for lightweight geospatial services based on postgis and friends

Build some fast geospatial APIs, An [OpenResty][1] starter kit to write pure [Lua][2] APIs.

No framework or GIS server ! Forget about your favorite framework and mapping server, forget about Flask,
Express or even Sinatra, here the HTTP requests are handled directly in
[nginx][3] by executing [Lua][2] scripts to interact with PostGIS, pg_featureserv, pg_tileserv, and external API's.

Getting started


Configuration
-------------

For demo purposes, everything is contained in the [nginx configuration file](conf/nginx.conf) :

```nginx
worker_processes 1;

error_log logs/error.log info;

events {
    worker_connections 1024;
}

http {
    charset      utf-8;
    default_type application/json;

    # Docker DNS
    resolver 127.0.0.11;

    lua_package_path  '${prefix}lua/?.lua;;';
    lua_package_cpath '${prefix}lua/?.so;;';

    server {
        listen 8080;

        # Docker Compose services
        # db info here for quick start demo purposes only
        set $postgres_host     postgres;
        set $postgres_port     5432;
        set $postgres_database nyc;
        set $postgres_user     postgres;
        set $postgres_password password;
        set $opencageapikey enteryourOpenCageapikeyhere;

        location / {
            content_by_lua_file lua/bootstrap.lua;
        }
    }
}
```

> If you work outside Docker Compose, pay attention to `resolver` directive and
> "Docker Compose services" variables, you'll probably have to modify these
> values according to your environment.

Docker
------

A [Dockerfile](Dockerfile) is provided to build a Docker image of the API :

```shell
docker build -t luaserv .
```
> Note that :
> * The Docker image is based on the [OpenResty Official Docker Image][4]
> * OPM dependencies are installed during the building process (See below)

Once the Docker image is built, start the container with the following command :

```shell
docker run -it --rm -p 8080:8080 luaserv
```

Docker Compose
--------------

A [docker-compose.yml](docker-compose.yml) file is also provided to orchestrate
four containers :

* The API (See above)
* A PostGIS database
* A pg_tileserv microservice
* A pg_featureserv microservice

Take a look at the following component diagram :

![Docker Compose services](https://user-images.githubusercontent.com/4240439/142416525-6a4885bf-9dae-49f8-aeee-195d06d5f550.png)

To start the environment, simply run :

```shell
docker-compose up -d --build
```

> The Docker image of the API is built before start due to `--build` option.

OPM
---

Two libraries are installed during the Docker image building process :

* [lua-resty-http][5] : An HTTP Client
* [pgmoon][6] : A PostgreSQL driver
* [lua-resty-opencage-geocoder][7] : a simple client for the OpenCage forward/reverse geocoding API,
* [lua-resty-reqargs][8] : Helper to Retrieve application/x-www-form-urlencoded, multipart/form-data, and application/json Request Arguments.
* [lua-resty-mlcache][9] : Fast and automated layered caching for OpenResty.



Example routes
--------------

This stater kit comes with some example routes to demonstrate the usage of
libraries :

Route | Description | Script
----- | ----------- | ------
/ip | Call an external service 
/geocode | location for the OpenCage forward geocoding API geocode service
/reverse_geocode | location for the OpenCage reverse geocoding API geocode service
/get_features | Finds the intersecting features from input geojson and returns geojson
/get_tile | get bytea mvt tile from input params
/querydb | YesSQL - call templated SQL queries by name and input paramters
/pg_featureserv | proxy location for pg_featureserv
/pg_tileserv | proxy location for pg_tileserv
/status | status page for all the upstream services (pg_tileserv, pg_featureserv)


> Routes are defined in [routes.lua](lua/routes.lua) script.

[1]: https://github.com/openresty
[2]: http://www.lua.org
[3]: https://nginx.org
[4]: https://hub.docker.com/r/openresty/openresty
[5]: https://github.com/ledgetech/lua-resty-http
[6]: https://github.com/leafo/pgmoon
[7]: https://github.com/nmdguerreiro/lua-resty-opencage-geocoder
[8]: https://github.com/bungle/lua-resty-reqargs
[9]: https://github.com/thibaultcha/lua-resty-mlcache
