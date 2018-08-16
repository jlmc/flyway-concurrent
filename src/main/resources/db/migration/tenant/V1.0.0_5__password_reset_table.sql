CREATE TABLE password_reset (
  id            UUID                      NOT NULL,
  account_id    UUID                      NOT NULL,
  created_at    TIMESTAMP WITH TIME ZONE  NOT NULL,
  expired_at    TIMESTAMP WITH TIME ZONE  NOT NULL,
  mail_url      TEXT                      NOT NULL,

  PRIMARY KEY (id)
);
