FROM quay.io/keycloak/keycloak:26.5.0-0@sha256:5fdd7cda82e58775ed124294c7e16fabc33166d38dfc4aabebda7d64e7a964bf AS builder

# Enable health and metrics support.
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.1.3-0@sha256:2ce6c7c70994c70dbbd70b372a5422c3b4eebb32583175eac03751320609e52c
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
