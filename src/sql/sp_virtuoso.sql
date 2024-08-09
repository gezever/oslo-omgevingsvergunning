-- PROCEDURE: b_omv_oslo.sp_virtuoso()

-- DROP PROCEDURE IF EXISTS b_omv_oslo.sp_virtuoso();

CREATE OR REPLACE PROCEDURE b_omv_oslo.sp_virtuoso(
)
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
BEGIN
    CREATE TEMP TABLE tmp_activiteit AS
    SELECT * FROM b_omv_oslo.fn_activiteit();

    CREATE TEMP TABLE tmp_activiteit_locatie AS
    SELECT * FROM b_omv_oslo.fn_activiteit_locatie();

    CREATE TEMP TABLE tmp_handeling AS
    SELECT * FROM b_omv_oslo.fn_handeling();

    CREATE TEMP TABLE tmp_zaak AS
    SELECT * FROM b_omv_oslo.fn_zaak();

    TRUNCATE TABLE b_omv_oslo.virtuoso;

    INSERT INTO b_omv_oslo.virtuoso

    WITH cte AS (
        SELECT row_number()over()/25 as rn, t.body
        FROM tmp_activiteit t),
         context as (
             SELECT context
             FROM b_omv_oslo.context)
    SELECT jsonb_build_object('@graph', jsonb_agg(cte.body), '@context', context.context) AS body
    FROM cte
    GROUP BY rn;

    INSERT INTO b_omv_oslo.virtuoso
    WITH cte AS (
        SELECT row_number()over()/25 as rn, t.body
        FROM tmp_activiteit_locatie t),
         context as (
             SELECT context
             FROM b_omv_oslo.context)
    SELECT jsonb_build_object('@graph', jsonb_agg(cte.body), '@context', context.context) AS body
    FROM cte
    GROUP BY rn;

    INSERT INTO b_omv_oslo.virtuoso
    WITH cte AS (
        SELECT row_number()over()/25 as rn, t.body
        FROM tmp_handeling t),
         context as (
             SELECT context
             FROM b_omv_oslo.context)
    SELECT jsonb_build_object('@graph', jsonb_agg(cte.body), '@context', context.context) AS body
    FROM cte
    GROUP BY rn;

    INSERT INTO b_omv_oslo.virtuoso
    WITH cte AS (
        SELECT row_number()over()/25 as rn, t.body
        FROM tmp_zaak t),
         context as (
             SELECT context
             FROM b_omv_oslo.context)
    SELECT jsonb_build_object('@graph', jsonb_agg(cte.body), '@context', context.context) AS body
    FROM cte
    GROUP BY rn;

END;
$BODY$;
ALTER PROCEDURE b_omv_oslo.sp_virtuoso()
    OWNER TO datawarehouse_ddl;
