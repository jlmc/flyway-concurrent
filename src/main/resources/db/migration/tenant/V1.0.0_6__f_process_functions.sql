CREATE OR REPLACE FUNCTION f_processes_under_inclusive(account_id UUID, root_process_id VARCHAR DEFAULT NULL)
  RETURNS SETOF UUID LANGUAGE SQL AS $$

WITH organizarion_units_ids AS (
    SELECT id
    FROM f_organizations_units_ids_under_account( account_id ) as id
), process_ids as (

  WITH RECURSIVE ps AS (
    SELECT pr.id
    FROM process pr INNER JOIN organization_unit o on pr.organization_unit_id = o.id
    WHERE CASE WHEN root_process_id ISNULL OR root_process_id = ''
      THEN 1 = 1
          ELSE pr.id = CAST(root_process_id AS UUID) END
    UNION

    SELECT pc.id
    FROM process pc
      JOIN ps ON ps.id = pc.parent_id

  ) SELECT DISTINCT id
    FROM ps

)
SELECT id
FROM process_ids;

$$;
