----------------------------------------------
-- Organization Unit
----------------------------------------------
CREATE TABLE organization_unit (
  id          UUID         NOT NULL,
  description VARCHAR(500),
  name        VARCHAR(100) NOT NULL,
  parent_id   UUID,

  PRIMARY KEY (id)
);

ALTER TABLE organization_unit
  ADD CONSTRAINT fk_organization_unit_parent_id
FOREIGN KEY (parent_id)
REFERENCES organization_unit (id) ON DELETE CASCADE;

----------------------------------------------
-- Typologies
----------------------------------------------
CREATE TABLE document_type (
  id    UUID         NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE control_type (
  id    UUID         NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE control_system_type (
  id    UUID         NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE process_type (
  id    UUID         NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE control_nature_type (
  id    UUID         NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE risk_category_type (
  id    UUID         NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE impacted_objective_type (
  id    UUID         NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE control_periodicity_type (
  id    UUID         NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

----------------------------------------------
-- Risk Source
----------------------------------------------
CREATE TABLE risk_source (
  id          UUID         NOT NULL,
  name        VARCHAR(100) NOT NULL,
  description VARCHAR(500) NOT NULL,
  PRIMARY KEY (id)
);

----------------------------------------------
-- Document
----------------------------------------------
CREATE TABLE document (
  id               UUID         NOT NULL,
  risk_source_id   UUID         NOT NULL,
  name             VARCHAR(500) NOT NULL,
  media_type       VARCHAR(100) NOT NULL,
  document_type_id UUID         NOT NULL,
  file_content     BYTEA,
  PRIMARY KEY (id)
);

ALTER TABLE document
  ADD CONSTRAINT fk_document__document_type_id
FOREIGN KEY (document_type_id) REFERENCES document_type (id);

ALTER TABLE document
  ADD CONSTRAINT fk_document__risk_source_id
FOREIGN KEY (risk_source_id)
REFERENCES risk_source (id) ON DELETE CASCADE;

CREATE INDEX document_document_type_id_index
  ON document (document_type_id);
CREATE INDEX document_risk_source_id_index
  ON document (risk_source_id);

----------------------------------------------
-- Matrix
----------------------------------------------
CREATE TABLE matrix (
  id        UUID NOT NULL,
  dimension INT4 NOT NULL,
  PRIMARY KEY (id)
);

----------------------------------------------
-- Parameter
----------------------------------------------
CREATE TABLE parameter (
  id        UUID NOT NULL,
  matrix_id UUID NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE parameter
  ADD CONSTRAINT fk_parameter__matrix_id FOREIGN KEY (matrix_id) REFERENCES matrix (id);

CREATE INDEX parameter_matrix_id_index
  ON parameter (matrix_id);

----------------------------------------------
-- Impact
----------------------------------------------
CREATE TABLE impact (
  id           UUID         NOT NULL,
  parameter_id UUID,
  index        INT4         NOT NULL,
  name         VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE impact
  ADD CONSTRAINT fk_impact__parameter_id FOREIGN KEY (parameter_id) REFERENCES parameter (id);

CREATE INDEX impact_parameter_id_index
  ON impact (parameter_id);

----------------------------------------------
-- Probability
----------------------------------------------
CREATE TABLE probability (
  id           UUID         NOT NULL,
  parameter_id UUID,
  index        INT4         NOT NULL,
  name         VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE probability
  ADD CONSTRAINT fk_probability__parameter_id FOREIGN KEY (parameter_id) REFERENCES parameter (id);

CREATE INDEX probability_parameter_id_index
  ON probability (parameter_id);

----------------------------------------------
-- Interval
----------------------------------------------
CREATE TABLE interval (
  id           UUID NOT NULL,
  parameter_id UUID,
  start_index  INT4 NOT NULL,
  end_index    INT4 NOT NULL,
  color        VARCHAR(50),
  label        VARCHAR(255),
  PRIMARY KEY (id)
);

ALTER TABLE interval
  ADD CONSTRAINT fk_interval__parameter_id FOREIGN KEY (parameter_id) REFERENCES parameter (id);

CREATE INDEX interval_parameter_id_index
  ON interval (parameter_id);

----------------------------------------------
-- Dimension
----------------------------------------------
CREATE TABLE dimension (
  id           UUID         NOT NULL,
  name         VARCHAR(255) NOT NULL,
  weight       DOUBLE PRECISION,
  parameter_id UUID,
  PRIMARY KEY (id)
);

ALTER TABLE dimension
  ADD CONSTRAINT fk_dimension__parameter_id FOREIGN KEY (parameter_id) REFERENCES parameter (id);

CREATE INDEX dimension_parameter_id_index
  ON dimension (parameter_id);

----------------------------------------------
-- Dimension impact
----------------------------------------------
CREATE TABLE dimension_impact (
  id           UUID         NOT NULL,
  dimension_id UUID,
  index        INT4         NOT NULL,
  name         VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE dimension_impact
  ADD CONSTRAINT fk_dimension_impact__dimension_id FOREIGN KEY (dimension_id) REFERENCES dimension (id);

CREATE INDEX dimension_impact_dimension_id_index
  ON dimension_impact (dimension_id);

----------------------------------------------
-- Organization Unit membership
----------------------------------------------
CREATE TABLE organization_unit_membership (
  account_id           UUID NOT NULL,
  organization_unit_id UUID NOT NULL,
  PRIMARY KEY (account_id)
);

ALTER TABLE organization_unit_membership
  ADD CONSTRAINT fk_organization_unit_membership__organization_unit_id
FOREIGN KEY (organization_unit_id)
REFERENCES organization_unit (id);

CREATE INDEX organization_unit_membership_organization_unit_id_index
  ON organization_unit_membership (organization_unit_id);

----------------------------------------------
-- Pivot risk owner
----------------------------------------------
CREATE TABLE risk_owner (
  id         UUID NOT NULL,
  account_id UUID NOT NULL,
  owner_id   UUID NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_risk_owner__account_id_owner_id
  ON risk_owner (account_id, owner_id);

----------------------------------------------
-- Process
----------------------------------------------
CREATE TABLE process (
  id                   UUID         NOT NULL,
  name                 VARCHAR(100) NOT NULL,
  description          VARCHAR(500) NULL,
  type_id              UUID         NOT NULL,
  parent_id            UUID         NULL,
  organization_unit_id UUID         NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE process
  ADD CONSTRAINT fk_process__parent_id
FOREIGN KEY (parent_id)
REFERENCES process (id) ON DELETE CASCADE;

ALTER TABLE process
  ADD CONSTRAINT fk_process__organization_unit_id
FOREIGN KEY (organization_unit_id)
REFERENCES organization_unit (id);

ALTER TABLE process
  ADD CONSTRAINT fk_process__type_id
FOREIGN KEY (type_id)
REFERENCES process_type (id);

CREATE INDEX process_parent_id_index
  ON process (parent_id);
CREATE INDEX process_organization_unit_id_index
  ON process (organization_unit_id);
CREATE INDEX process_type_id_index
  ON process (type_id);

----------------------------------------------
-- Risk
----------------------------------------------
CREATE TABLE risk (
  id                     UUID                         NOT NULL,
  custom_identifier      VARCHAR(255)                 NOT NULL,
  owner_id               UUID,
  pivot_id               UUID,
  name                   VARCHAR(255)                 NOT NULL,
  description            VARCHAR(500)                 NOT NULL,
  status                 VARCHAR(100)                 NOT NULL,
  workflow_status        VARCHAR(100)                 NOT NULL,
  common                 VARCHAR(100)                 NOT NULL,
  probability_id         UUID                         NOT NULL,
  impact_id              UUID,
  response               VARCHAR(100)                 NOT NULL,
  comment                VARCHAR(500)                 NOT NULL,
  potential_consequences VARCHAR(500)                 NULL,
  cic                    BOOLEAN DEFAULT FALSE        NOT NULL,
  score                  FLOAT8 DEFAULT 0,
  version                INTEGER DEFAULT 0            NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE RISK
  ADD CONSTRAINT risk_custom_identifier_unique UNIQUE (custom_identifier);

ALTER TABLE risk
  ADD CONSTRAINT fk_risk__owner_id FOREIGN KEY (owner_id) REFERENCES organization_unit_membership (account_id);

ALTER TABLE risk
  ADD CONSTRAINT fk_risk__pivot_id FOREIGN KEY (pivot_id) REFERENCES organization_unit_membership (account_id);

ALTER TABLE risk
  ADD CONSTRAINT fk_risk__impact_id FOREIGN KEY (impact_id) REFERENCES impact (id);

ALTER TABLE risk
  ADD CONSTRAINT fk_risk__probability_id FOREIGN KEY (probability_id) REFERENCES probability (id);

CREATE INDEX risk_impact_id_index
  ON risk (impact_id);
CREATE INDEX risk_probability_id_index
  ON risk (probability_id);

CREATE UNIQUE INDEX risk_custom_identifier_unique_index
  ON risk (custom_identifier);

----------------------------------------------
-- Risk process
----------------------------------------------
CREATE TABLE risk_process (
  risk_id    UUID NOT NULL,
  process_id UUID NOT NULL,
  PRIMARY KEY (risk_id, process_id)
);

ALTER TABLE risk_process
  ADD CONSTRAINT fk_risk_process__risk_id FOREIGN KEY (risk_id) REFERENCES risk (id);

ALTER TABLE risk_process
  ADD CONSTRAINT fk_risk_process__process_id FOREIGN KEY (process_id) REFERENCES process (id);

CREATE INDEX risk_process_risk_id_index
  ON risk_process (risk_id);

CREATE INDEX risk_process_process_id_index
  ON risk_process (process_id);

----------------------------------------------
-- Risk source risk
----------------------------------------------
CREATE TABLE risk_source_risk (
  risk_id        UUID NOT NULL,
  risk_source_id UUID NOT NULL,
  PRIMARY KEY (risk_id, risk_source_id)
);

ALTER TABLE risk_source_risk
  ADD CONSTRAINT fk_risk_source_risk__risk_id FOREIGN KEY (risk_id) REFERENCES risk (id);

ALTER TABLE risk_source_risk
  ADD CONSTRAINT fk_risk_source_risk__risk_source_id FOREIGN KEY (risk_source_id) REFERENCES risk_source (id);

CREATE INDEX risk_source_risk_risk_id_index
  ON risk_source_risk (risk_id);

CREATE INDEX risk_source_risk_risk_source_id_index
  ON risk_source_risk (risk_source_id);

----------------------------------------------
-- Risk category typology field
----------------------------------------------
CREATE TABLE risk_category (
  risk_id               UUID NOT NULL,
  risk_category_type_id UUID NOT NULL,
  PRIMARY KEY (risk_id, risk_category_type_id)
);

ALTER TABLE risk_category
  ADD CONSTRAINT fk_risk_category__risk_id FOREIGN KEY (risk_id) REFERENCES risk (id);

ALTER TABLE risk_category
  ADD CONSTRAINT fk_risk_category__risk_category_type_id FOREIGN KEY (risk_category_type_id)
REFERENCES risk_category_type (id);

CREATE INDEX risk_category_risk_id_index
  ON risk_category (risk_id);
CREATE INDEX risk_category_risk_category_type_id_index
  ON risk_category (risk_category_type_id);

----------------------------------------------
-- Risk dimension impact
----------------------------------------------
CREATE TABLE risk_dimension_impact (
  id                  UUID NOT NULL,
  risk_id             UUID NOT NULL,
  dimension_id        UUID NOT NULL,
  dimension_impact_id UUID,
  PRIMARY KEY (id)
);

ALTER TABLE risk_dimension_impact
  ADD CONSTRAINT fk_risk_dimension_impact__dimension_id FOREIGN KEY (dimension_id) REFERENCES dimension (id);

ALTER TABLE risk_dimension_impact
  ADD CONSTRAINT fk_risk_dimension_impact__dimension_impact_id FOREIGN KEY (dimension_impact_id) REFERENCES dimension_impact (id);

ALTER TABLE risk_dimension_impact
  ADD CONSTRAINT fk_risk_dimension_impact__risk_id FOREIGN KEY (risk_id) REFERENCES risk (id);

CREATE INDEX risk_dimension_impact_dimension_id_index
  ON risk_dimension_impact (dimension_id);
CREATE INDEX risk_dimension_impact_dimension_impact_id_index
  ON risk_dimension_impact (dimension_impact_id);
CREATE INDEX risk_dimension_impact_risk_id_index
  ON risk_dimension_impact (risk_id);

----------------------------------------------
-- Risk impacted objective
----------------------------------------------
CREATE TABLE risk_impacted_objective (
  risk_id                    UUID NOT NULL,
  impacted_objective_type_id UUID NOT NULL,
  PRIMARY KEY (risk_id, impacted_objective_type_id)
);

ALTER TABLE risk_impacted_objective
  ADD CONSTRAINT fk_risk_impacted_objective__impacted_objective_type_id FOREIGN KEY (impacted_objective_type_id) REFERENCES impacted_objective_type (id);

ALTER TABLE risk_impacted_objective
  ADD CONSTRAINT fk_risk_impacted_objective__risk_id FOREIGN KEY (risk_id) REFERENCES risk (id);

CREATE INDEX risk_impacted_impacted_objective_type_id_index
  ON risk_impacted_objective (impacted_objective_type_id);
CREATE INDEX risk_impacted_objective_risk_id_index
  ON risk_impacted_objective (risk_id);

----------------------------------------------
-- Risk workflow history
----------------------------------------------
CREATE TABLE risk_workflow_history (
  id              UUID,
  risk_id         UUID                     NOT NULL,
  workflow_status VARCHAR(100)             NOT NULL,
  comment         VARCHAR(255),
  created_by      JSONB,
  created_at      TIMESTAMP WITH TIME ZONE NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE risk_workflow_history
  ADD CONSTRAINT fk_risk_workflow_history__risk_id FOREIGN KEY (risk_id) REFERENCES risk (id);

CREATE INDEX risk_workflow_history_risk_id_index
  ON risk_workflow_history (risk_id);

----------------------------------------------
-- Control
----------------------------------------------
CREATE TABLE control (
  id              UUID                         NOT NULL,
  type_id         UUID                         NOT NULL,
  nature_id       UUID                         NOT NULL,
  owner_id        UUID,
  system_id       UUID                         NOT NULL,
  implemented     BOOLEAN DEFAULT FALSE,
  effectiveness   BOOLEAN DEFAULT FALSE,
  workflow_status VARCHAR(100)                 NOT NULL,
  name            VARCHAR(255)                 NOT NULL,
  description     VARCHAR(500)                 NOT NULL,
  evidences       VARCHAR(255),
  periodicity_id  UUID                         NOT NULL,
  version         INTEGER DEFAULT 0            NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE control
  ADD CONSTRAINT fk_control__owner_id FOREIGN KEY (owner_id)
REFERENCES organization_unit_membership (account_id);

ALTER TABLE control
  ADD CONSTRAINT fk_control_type__type_id
FOREIGN KEY (type_id)
REFERENCES control_type (id);

ALTER TABLE control
  ADD CONSTRAINT fk_control_system_type__system_id
FOREIGN KEY (system_id)
REFERENCES control_system_type (id);

ALTER TABLE control
  ADD CONSTRAINT fk_control__periodicity_id
FOREIGN KEY (periodicity_id)
REFERENCES control_periodicity_type;

ALTER TABLE control
  ADD CONSTRAINT fk_control_nature_id
FOREIGN KEY (nature_id)
REFERENCES control_nature_type (id);

ALTER TABLE control
  ADD CONSTRAINT fk_control__system_id
FOREIGN KEY (system_id)
REFERENCES control_system_type (id);

CREATE INDEX control_type_id_index
  ON control (type_id);
CREATE INDEX control_nature_id_index
  ON control (nature_id);
CREATE INDEX control_system_id_index
  ON control (system_id);
CREATE INDEX control_periodicity_id_index
  ON control (periodicity_id);

----------------------------------------------
-- control workflow history
----------------------------------------------
CREATE TABLE control_workflow_history (
  id              UUID,
  control_id      UUID                     NOT NULL,
  workflow_status VARCHAR(100)             NOT NULL,
  comment         VARCHAR(255)             NULL,
  created_by      JSONB                    NULL,
  created_at      TIMESTAMP WITH TIME ZONE NOT NULL,
  PRIMARY KEY (id)
);

ALTER TABLE control_workflow_history
  ADD CONSTRAINT fk_control_workflow_history__control_id
FOREIGN KEY (control_id)
REFERENCES control (id);

CREATE INDEX control_workflow_history_control_id_index
  ON control_workflow_history (control_id);

----------------------------------------------
-- Control action plan
----------------------------------------------
CREATE TABLE control_action_plan (
  control_id            UUID                     NOT NULL,
  name                  VARCHAR(1000)            NOT NULL,
  monitor_comment       VARCHAR(500)             NULL,
  manager_comment       VARCHAR(500)             NULL,
  effective_cost        FLOAT8                   NULL,
  estimated_cost        FLOAT8                   NULL,
  approval_date         TIMESTAMP WITH TIME ZONE NULL,
  predictive_start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  predictive_end_date   TIMESTAMP WITH TIME ZONE NOT NULL,
  effective_start_date  TIMESTAMP WITH TIME ZONE NULL,
  effective_end_date    TIMESTAMP WITH TIME ZONE NULL,
  PRIMARY KEY (control_id)
);

ALTER TABLE control_action_plan
  ADD CONSTRAINT fk_control_action_plan__control_id
FOREIGN KEY (control_id)
REFERENCES control (id);

CREATE INDEX control_action_plan_control_id_index
  ON control_action_plan (control_id);

----------------------------------------------
-- Control action plan organization unit
----------------------------------------------
CREATE TABLE control_action_plan_organization_unit (
  control_action_plan_id UUID NOT NULL,
  organization_unit_id   UUID NOT NULL,
  PRIMARY KEY (control_action_plan_id, organization_unit_id)
);

ALTER TABLE control_action_plan_organization_unit
  ADD CONSTRAINT fk_control_action_plan_organization_unit__control_action_plan
FOREIGN KEY (control_action_plan_id)
REFERENCES control_action_plan;

ALTER TABLE control_action_plan_organization_unit
  ADD CONSTRAINT fk_control_action_plan_organization_unit__organization_unit
FOREIGN KEY (organization_unit_id)
REFERENCES organization_unit;

CREATE INDEX control_action_plan_organization_unit_organization_unit_id_ix
  ON control_action_plan_organization_unit (organization_unit_id);
CREATE INDEX control_action_plan_organization_unit_control_action_plan_id_ix
  ON control_action_plan_organization_unit (control_action_plan_id);

----------------------------------------------
-- Treatment
----------------------------------------------
CREATE TABLE treatment (
  risk_id              UUID                         NOT NULL,
  residual_impact      UUID                         NULL,
  residual_probability UUID                         NOT NULL,
  score                FLOAT8 DEFAULT 0,
  version              INTEGER DEFAULT 0            NOT NULL,
  PRIMARY KEY (risk_id)
);

ALTER TABLE treatment
  ADD CONSTRAINT fk_treatment__residual_impact
FOREIGN KEY (residual_impact)
REFERENCES impact;

ALTER TABLE treatment
  ADD CONSTRAINT fk_treatment__residual_probability
FOREIGN KEY (residual_probability)
REFERENCES probability;

ALTER TABLE treatment
  ADD CONSTRAINT fk_treatment__risk_id
FOREIGN KEY (risk_id)
REFERENCES risk;

CREATE INDEX treatment_residual_impact_index
  ON treatment (residual_impact);
CREATE INDEX treatment_residual_probability_index
  ON treatment (residual_probability);
CREATE INDEX treatment_risk_id_index
  ON treatment (risk_id);

----------------------------------------------
-- Treatment dimension impact
----------------------------------------------
CREATE TABLE treatment_dimension_impact (
  treatment_id             UUID NOT NULL,
  dimension_impact_id      UUID,
  risk_dimension_impact_id UUID
);

ALTER TABLE treatment_dimension_impact
  ADD CONSTRAINT fk_treatment_dimension_impact__dimension_impact_id
FOREIGN KEY (dimension_impact_id)
REFERENCES dimension_impact;

ALTER TABLE treatment_dimension_impact
  ADD CONSTRAINT fk_treatment_dimension_impact__risk_dimension_impact_id
FOREIGN KEY (risk_dimension_impact_id)
REFERENCES risk_dimension_impact;

ALTER TABLE treatment_dimension_impact
  ADD CONSTRAINT fk_treatment_dimension_impact__treatment_id
FOREIGN KEY (treatment_id)
REFERENCES treatment;

CREATE INDEX treatment_dimension_impact_dimension_impact_id_index
  ON treatment_dimension_impact (dimension_impact_id);
CREATE INDEX treatment_dimension_impact_risk_dimension_impact_id_index
  ON treatment_dimension_impact (risk_dimension_impact_id);
CREATE INDEX treatment_dimension_impact_treatment_id_index
  ON treatment_dimension_impact (treatment_id);

----------------------------------------------
-- Treatment control
----------------------------------------------
CREATE TABLE treatment_control (
  risk_id    UUID NOT NULL,
  control_id UUID NOT NULL,
  PRIMARY KEY (risk_id, control_id)
);

ALTER TABLE treatment_control
  ADD CONSTRAINT fk_treatment__control_id
FOREIGN KEY (control_id)
REFERENCES control;

ALTER TABLE treatment_control
  ADD CONSTRAINT fk_treatment__risk_id
FOREIGN KEY (risk_id)
REFERENCES treatment;

CREATE INDEX treatment_control_risk_id_index
  ON treatment_control (risk_id);
CREATE INDEX treatment_control_control_id_index
  ON treatment_control (control_id);

----------------------------------------------
-- risk snapshot
----------------------------------------------
CREATE TABLE risk_snapshot (
  id                 UUID                     NOT NULL,
  risk_id            UUID                     NOT NULL,
  created_at         TIMESTAMP WITH TIME ZONE NOT NULL,
  created_by         JSONB                    NOT NULL,
  risk_json          JSONB                    NOT NULL,
  profile_start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  profile_end_date   TIMESTAMP WITH TIME ZONE NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT risk_snapshot_profile_dates_check CHECK (profile_end_date >= profile_start_date)
);

ALTER TABLE risk_snapshot
  ADD CONSTRAINT risk_snapshot_risk_id_created_at_pk UNIQUE (risk_id, created_at);

ALTER TABLE risk_snapshot
  ADD CONSTRAINT risk_snapshot__risk_id_profile_start_date_pk UNIQUE (risk_id, profile_start_date, profile_end_date);

CREATE INDEX risk_snapshot_risk_id_index
  ON risk_snapshot (risk_id);

CREATE INDEX risk_snapshot_risk_id_profile_end_date_index
  ON risk_snapshot (risk_id, profile_end_date);

----------------------------------------------
-- Control snapshot
----------------------------------------------
CREATE TABLE control_snapshot (
  id                 UUID                     NOT NULL,
  control_id         UUID                     NOT NULL,
  created_at         TIMESTAMP WITH TIME ZONE NOT NULL,
  created_by         JSONB                    NOT NULL,
  control_json       JSONB                    NOT NULL,
  profile_start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  profile_end_date   TIMESTAMP WITH TIME ZONE NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT control_snapshot_profile_dates_check CHECK (profile_end_date >= profile_start_date)
);

ALTER TABLE control_snapshot
  ADD CONSTRAINT control_snapshot__control_id_created_at_pk UNIQUE (control_id, created_at);

ALTER TABLE control_snapshot
  ADD CONSTRAINT control_snapshot__control_id_profile_dates_pk UNIQUE (control_id, profile_start_date, profile_end_date);

CREATE INDEX control_snapshot_control_id_index
  ON control_snapshot (control_id);

----------------------------------------------
-- Loss Event
----------------------------------------------

CREATE TABLE loss_event (
  id                UUID                     NOT NULL,
  real_value        FLOAT8                   NOT NULL,
  comment           VARCHAR(500)             NOT NULL,
  loss_date         TIMESTAMP WITH TIME ZONE NOT NULL,
  risk_snapshot_id  UUID                     NOT NULL,
  risk              JSONB                    NOT NULL,
  impact            JSONB                    NULL,
  processes         JSONB                    NULL,
  dimension_impacts JSONB                    NULL,

  PRIMARY KEY (id)
);

ALTER TABLE loss_event
  ADD CONSTRAINT fk_loss_event__risk_snapshot_id
FOREIGN KEY (risk_snapshot_id) REFERENCES risk_snapshot (id);

CREATE INDEX loss_event_risk_snapshot_id_index
  ON loss_event (risk_snapshot_id);
