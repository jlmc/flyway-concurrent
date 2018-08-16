CREATE OR REPLACE FUNCTION f_document_type_is_disable(UUID)
  RETURNS BOOLEAN
AS $$
SELECT EXISTS(SELECT 1
              FROM document d
              WHERE d.document_type_id = $1
              LIMIT 1);

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION f_control_type_is_disable(UUID)
  RETURNS BOOLEAN
AS $$
SELECT EXISTS(SELECT 1
              FROM control d
              WHERE d.type_id = $1
              LIMIT 1);

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION f_control_system_type_is_disable(UUID)
  RETURNS BOOLEAN
AS $$
SELECT EXISTS(SELECT 1
              FROM control d
              WHERE d.system_id = $1
              LIMIT 1);

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION f_control_periodicity_type_is_disable(UUID)
  RETURNS BOOLEAN
AS $$
SELECT EXISTS(SELECT 1
              FROM control d
              WHERE d.periodicity_id = $1
              LIMIT 1);

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION f_control_nature_type_is_disable(UUID)
  RETURNS BOOLEAN
AS $$
SELECT EXISTS(SELECT 1
              FROM control d
              WHERE d.nature_id = $1
              LIMIT 1);

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION f_process_type_is_disable(UUID)
  RETURNS BOOLEAN
AS $$
SELECT EXISTS(SELECT 1
              FROM process d
              WHERE d.type_id = $1
              LIMIT 1);

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION f_risk_category_type_is_disable(UUID)
  RETURNS BOOLEAN
AS $$
SELECT EXISTS(SELECT 1
              FROM risk_category d
              WHERE d.risk_category_type_id = $1
              LIMIT 1);

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION f_impacted_objective_type_is_disable(UUID)
  RETURNS BOOLEAN
AS $$
SELECT EXISTS(SELECT 1
              FROM risk_impacted_objective d
              WHERE d.impacted_objective_type_id = $1
              LIMIT 1);

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION f_number_of_associated_risk_with_the_control(uuid)
  RETURNS BIGINT
AS $$
SELECT COUNT(tc.risk_id)
FROM treatment_control tc INNER JOIN risk r ON tc.risk_id = r.id
WHERE tc.control_id = $1

$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION  f_organizations_units_ids_under_inclusive (x UUID)
  RETURNS SETOF UUID LANGUAGE SQL AS $$
WITH RECURSIVE organizations_unit_ids AS (
  SELECT id, parent_id, name, 0 AS deep
  FROM organization_unit
  WHERE id = $1

  UNION

  SELECT m.id, m.parent_id, m.name, 1 + organizations_unit_ids.deep AS deep
  FROM organization_unit m
    JOIN organizations_unit_ids ON organizations_unit_ids.id = m.parent_id

)
SELECT organizations_unit_ids.id FROM organizations_unit_ids order by deep;

$$;

CREATE OR REPLACE FUNCTION f_organizations_units_ids_under_account(x UUID)
  RETURNS SETOF UUID LANGUAGE SQL AS $$
WITH RECURSIVE t_organizations_unit_ids AS (

  SELECT r.id, r.parent_id, 0 AS deep
  FROM organization_unit r
    INNER JOIN organization_unit_membership o ON r.id = o.organization_unit_id
  WHERE o.account_id = $1

  UNION

  SELECT m.id, m.parent_id, 1 + t_organizations_unit_ids.deep AS deep
  FROM organization_unit m
    JOIN t_organizations_unit_ids ON t_organizations_unit_ids.id = m.parent_id

)
SELECT id FROM t_organizations_unit_ids ORDER BY deep;

$$;
