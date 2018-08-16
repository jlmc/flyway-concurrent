CREATE TABLE client (
  tenant_identifier  VARCHAR(64)  NOT NULL UNIQUE,
  PRIMARY KEY (tenant_identifier)
);

CREATE UNIQUE INDEX client_keycloak_id_uindex ON client (tenant_identifier);
