-- View: b_omv_oslo.vw_activiteit

-- DROP VIEW b_omv_oslo.vw_activiteit;

CREATE OR REPLACE VIEW b_omv_oslo.vw_activiteit
AS
SELECT 'https://data.omv.vlaanderen.be/id/activiteit/voorwerp_'::text || v."Voorwerp ID" AS id,
       json_build_array('https://data.omv.vlaanderen.be/id/concept/juridische_categorie/stedenbouwkundig_code/'::text || lower(replace(replace(replace(replace(v."Stedenbouwkundigtype Code", ' '::text, ''::text), '>'::text, '+'::text), '\s'::text, '_'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/verkavelingtype_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."Verkavelingtype Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/functie_tobe_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(vf."Functie TOBE Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/functie_tobe_cascade/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(vf."Functie TOBE Cascade", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/handeling_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(vh."Handeling Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)))::jsonb AS juridische_kwalificatie,
       NULL::text AS beschrijving,
       json_build_array('https://data.omv.vlaanderen.be/id/activiteit/handeling_'::text || vh."Voorwerp ID", 'https://data.omv.vlaanderen.be/id/activiteit/functie_'::text || vf."Voorwerp ID")::jsonb AS reverse_is_deel_van,
       json_build_array('https://data.omv.vlaanderen.be/id/activiteit/voorwerp_'::text || v."MidVoorwerp ID")::jsonb AS is_deel_van,
       'https://data.omv.vlaanderen.be/id/ruimtelijke_eenheid/voorwerp_'::text || vl."Voorwerp ID" AS locatie,
       NULL::text AS betrokkene,
       NULL::text AS tijdsbestek
FROM g_radar.vw_voorwerp v
         LEFT JOIN g_radar.vw_voorwerp_ligging vl ON vl."Voorwerp ID" = v."Voorwerp ID"
         LEFT JOIN g_radar.vw_functie vf ON vf."Voorwerp ID" = v."Voorwerp ID"
         LEFT JOIN g_radar.vw_handeling vh ON vh."Voorwerp ID" = v."Voorwerp ID"
WHERE v."Voorwerp Level" = 'SubVoorwerp'::text
UNION ALL
SELECT 'https://data.omv.vlaanderen.be/id/activiteit/voorwerp_'::text || v."Voorwerp ID" AS id,
       json_build_array('https://data.omv.vlaanderen.be/id/concept/juridische_categorie/stedenbouwkundigtype_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."Stedenbouwkundigtype Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/vegetatiewijzigingtype_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."Vegetatiewijzigingtype Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/kleinhandelsactiviteittype_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."Kleinhandelsactiviteittype Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/verkavelingtype_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."Verkavelingtype Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/terreinobjecttype_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."Terreinobjecttype Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/iioa_klasse/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."IIOA Klasse", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)),
                        CASE
                            WHEN v."GPBV Vlag" = 1 THEN 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/gbpv_vlag'::text
                            ELSE NULL::text
                            END, 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/functie_tobe_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(vf."Functie TOBE Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/functie_tobe_cascade/'::text || replace(replace(replace(vf."Functie TOBE Cascade", ' '::text, ''::text), '['::text, ''::text), ']'::text, ''::text), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/handeling_code/'::text || vh."Handeling Code")::jsonb AS juridische_kwalificatie,
       NULL::text AS beschrijving,
       NULL::jsonb AS reverse_is_deel_van,
       json_build_array('https://data.omv.vlaanderen.be/id/activiteit/voorwerp_'::text || v."TopVoorwerp ID")::jsonb AS is_deel_van,
       'https://data.omv.vlaanderen.be/id/ruimtelijke_eenheid/voorwerp_'::text || vl."Voorwerp ID" AS locatie,
       NULL::text AS betrokkene,
       NULL::text AS tijdsbestek
FROM g_radar.vw_voorwerp v
         LEFT JOIN g_radar.vw_voorwerp_ligging vl ON vl."Voorwerp ID" = v."Voorwerp ID"
         LEFT JOIN g_radar.vw_functie vf ON vf."Voorwerp ID" = v."Voorwerp ID"
         LEFT JOIN g_radar.vw_handeling vh ON vh."Voorwerp ID" = v."Voorwerp ID"
WHERE v."Voorwerp Level" = 'MidVoorwerp'::text
UNION ALL
SELECT 'https://data.omv.vlaanderen.be/id/activiteit/voorwerp_'::text || v."Voorwerp ID" AS id,
       json_build_array('https://data.omv.vlaanderen.be/id/concept/juridische_categorie/voorwerptype_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."TopVoorwerptype Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/iioa_klasse/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(v."IIOA Klasse", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)),
                        CASE
                            WHEN v."GPBV Vlag" = 1 THEN 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/gbpv_vlag'::text
                            ELSE NULL::text
                            END, 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/handeling_code/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(vh."Handeling Code", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/actuele_rubriek/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(r."Actuele Rubriek", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)), 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/actuele_rubriek_klasse/'::text || lower(regexp_replace(regexp_replace(regexp_replace(regexp_replace(r."Actuele Rubriek Klasse", ' - '::text, '+'::text, 'g'::text), ' > '::text, '+'::text, 'g'::text), '\s'::text, '_'::text, 'g'::text), '[\[\]]'::text, ''::text, 'g'::text)))::jsonb AS juridische_kwalificatie,
       NULL::text AS beschrijving,
       NULL::jsonb AS reverse_is_deel_van,
       json_build_array('https://data.omv.vlaanderen.be/id/activiteit/piv_'::text || pi."Project Inhoud ID")::jsonb AS is_deel_van,
       'https://data.omv.vlaanderen.be/id/ruimtelijke_eenheid/voorwerp_'::text || vl."Voorwerp ID" AS locatie,
       NULL::text AS betrokkene,
       NULL::text AS tijdsbestek
FROM g_radar.vw_voorwerp v
         LEFT JOIN g_radar.vw_project_inhoud pi ON pi."Project Inhoud ID" = v."Project Inhoud ID"
         LEFT JOIN g_radar.vw_voorwerp_ligging vl ON vl."Voorwerp ID" = v."Voorwerp ID"
         LEFT JOIN g_radar.vw_handeling vh ON vh."Voorwerp ID" = v."Voorwerp ID"
         LEFT JOIN g_radar.vw_rubriek r ON r."TopVoorwerp ID" = v."Voorwerp ID"
WHERE v."Voorwerp Level" = 'TopVoorwerp'::text AND r."Voorwerp vd Vraag Aard Code" <> 'NIET_LANGER'::text
UNION ALL
SELECT 'https://data.omv.vlaanderen.be/id/activiteit/piv_'::text || pi."Project Inhoud ID" AS id,
       json_build_array('https://data.omv.vlaanderen.be/id/concept/juridische_categorie/project'::text,
                        CASE
                            WHEN pii."Project Inhoud Vlaamse Lijst Vlag" = 1 THEN 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/project_inhoud_vlaamse_lijst_vlag'::text
                            ELSE NULL::text
                            END,
                        CASE
                            WHEN pii."Project Inhoud Provinciale Lijst Vlag" = 1 THEN 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/project_inhoud_provinciale_lijst_vlag'::text
                            ELSE NULL::text
                            END,
                        CASE
                            WHEN pii."Project Inhoud MER Vlag" = 1 THEN 'https://data.omv.vlaanderen.be/id/concept/juridische_categorie/project_inhoud_mer_vlag'::text
                            ELSE NULL::text
                            END)::jsonb AS juridische_kwalificatie,
       NULL::text AS beschrijving,
       NULL::jsonb AS reverse_is_deel_van,
       NULL::jsonb AS is_deel_van,
       'https://data.omv.vlaanderen.be/id/ruimtelijke_eenheid/project_'::text || pi."Project ID" AS locatie,
       NULL::text AS betrokkene,
       NULL::text AS tijdsbestek
FROM g_radar.vw_project_inhoud pi
         LEFT JOIN g_radar.vw_project_inhoud_info pii ON pii."Project Inhoud ID" = pi."Project Inhoud ID"
         LEFT JOIN g_radar.vw_voorwerp v ON v."Project Inhoud ID" = pi."Project Inhoud ID";

ALTER TABLE b_omv_oslo.vw_activiteit
    OWNER TO datawarehouse_ddl;

GRANT ALL ON TABLE b_omv_oslo.vw_activiteit TO datawarehouse_ddl;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE b_omv_oslo.vw_activiteit TO datawarehouse_dml;
GRANT SELECT ON TABLE b_omv_oslo.vw_activiteit TO datawarehouse_ro;

