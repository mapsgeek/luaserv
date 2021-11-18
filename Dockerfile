FROM openresty/openresty:alpine

RUN apk add --no-cache curl perl \
  && opm get leafo/pgmoon ledgetech/lua-resty-http nmdguerreiro/lua-resty-opencage-geocoder bungle/lua-resty-reqargs thibaultcha/lua-resty-mlcache


COPY . /usr/local/openresty/nginx
