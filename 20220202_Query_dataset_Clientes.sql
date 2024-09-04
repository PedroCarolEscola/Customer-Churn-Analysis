WITH PERS AS(
SELECT
COD_PERSONA_CLIMAPRO_I,
/*CCAA*/
CASE WHEN DESC_PROVINCIA IN ('ALMERIA','CADIZ','CORDOBA','GRANADA','HUELVA','JAEN','MALAGA','SEVILLA') THEN 1 ELSE 0
END FLAG_ANDALUCIA,
CASE WHEN DESC_PROVINCIA IN ('HUESCA','TERUEL','ZARAGOZA') THEN 1 ELSE 0
END FLAG_ARAGON,
CASE WHEN DESC_PROVINCIA IN ('ASTURIAS') THEN 1 ELSE 0
END FLAG_ASTURIAS,
CASE WHEN DESC_PROVINCIA IN ('ILLES BALEARS') THEN 1 ELSE 0
END FLAG_ILLES_BALEARS,
CASE WHEN DESC_PROVINCIA IN ('LAS PALMAS','SANTA CRUZ DE TENERIFE') THEN 1 ELSE 0
END FLAG_CANARIAS,
CASE WHEN DESC_PROVINCIA IN ('CANTABRIA') THEN 1 ELSE 0
END FLAG_CANTABRIA,
CASE WHEN DESC_PROVINCIA IN ('AVILA','BURGOS','LEON','PALENCIA','SALAMANCA','SEGOVIA','SORIA','VALLADOLID','ZAMORA') THEN 1 ELSE 0
END FLAG_CASTILLA_LEON,
CASE WHEN DESC_PROVINCIA IN ('ALBACETE','CIUDAD REAL','CUENCA','GUADALAJARA','TOLEDO') THEN 1 ELSE 0
END FLAG_CASTILLA_LAMANCHA,
CASE WHEN DESC_PROVINCIA IN ('BARCELONA','GIRONA','LLEIDA','TARRAGONA') THEN 1 ELSE 0
END FLAG_CATALUNYA,
CASE WHEN DESC_PROVINCIA IN ('ALICANTE','CASTELLO','VALENCIA') THEN 1 ELSE 0
END FLAG_VALENCIA,
CASE WHEN DESC_PROVINCIA IN ('BADAJOZ','CACERES','A CORUÑA') THEN 1 ELSE 0
END FLAG_EXTREMADURA,
CASE WHEN DESC_PROVINCIA IN ('A CORUÑA','LUGO','OURENSE','PONTEVEDRA') THEN 1 ELSE 0
END FLAG_GALICIA,
CASE WHEN DESC_PROVINCIA IN ('MADRID') THEN 1 ELSE 0
END FLAG_MADRID,
CASE WHEN DESC_PROVINCIA IN ('MURCIA') THEN 1 ELSE 0
END FLAG_MURCIA,
CASE WHEN DESC_PROVINCIA IN ('NAVARRA') THEN 1 ELSE 0
END FLAG_NAVARRA,
CASE WHEN DESC_PROVINCIA IN ('ALAVA','BIZKAIA','GIPUZKOA') THEN 1 ELSE 0
END FLAG_PAIS_VASCO,
CASE WHEN DESC_PROVINCIA IN ('LA RIOJA') THEN 1 ELSE 0
END FLAG_LA_RIOJA,
CASE WHEN DESC_PROVINCIA IN ('CEUTA','MELILLA') THEN 1 ELSE 0
END FLAG_CEUTA_MELILLA,

/*HOMBRE,MUJER,EMPRESA*/
CASE WHEN DESC_SEXO = 'HOMBRE'
THEN 1 ELSE 0
END FLAG_HOMBRE,
CASE WHEN DESC_SEXO = 'MUJER'
THEN 1 ELSE 0
END FLAG_MUJER,
CASE WHEN DESC_SEXO = 'EMPRESA'
THEN 1 ELSE 0
END FLAG_EMPRESA,
/*FISICA,JURIDICA*/
/*
CASE WHEN DESC_TIPO_PERSONA = 'JURIDICA'
THEN 1 ELSE 0
END FLAG_JURIDICA,*/
CASE WHEN DESC_TIPO_PERSONA = 'FISICA'
THEN 1 ELSE 0
END FLAG_PERSONA_FISICA

FROM CLIMAPROODS.DIM_PERSONAS_IMP PERS
WHERE FLAG_CLIENTE_INACTIVO IS NULL
AND FLAG_ES_LC = 1),

PATR AS(
SELECT
COD_PERSONA_CLIMAPRO_I,
EDAD,
FLAG_AFECTADO_EMI
FROM CLIMAPROODS.DIM_PERSONAS_ATR PATR
),

PM AS(
SELECT
COD_PERSONA_CLIMAPRO_I,
FLAG_CLIENTE_REGISTRADO,
FLAG_AUTONOMO,
FLAG_CLIENTE,
FLAG_EXCLIENTE,
FLAG_PROSPECT_MENOR_6MESES,
FLAG_LEAD_MENOR_6MESES,
FLAG_MULTIVEHICULO,
FLAG_NEGOCIACION_RED,
FLAG_OFERTA_IMA,
NUM_VEHICULOS_CONDUCTOR,
NUM_VEHICULOS_PROPIETARIO,
FLAG_CLIENTE_INSATISFECHO
FROM CLIMAPROODS.DIM_PERSONAS_MARCA_IMP PM
WHERE COD_MARCA = '36L'),

RELS AS (
SELECT
COD_PERSONA_CLIMAPRO_I,
COD_VEHICULO_CLIMAPRO,
FECHA_BAJA_CONS,
FLAG_RELACION_ACTIVA,
FECHA_ALTA_CONS,
FLAG_ES_VO,
FLAG_UNIVERSO_CONTACTABLE,
COD_FINANCIACION,/*0= No ha contratado financiación,1= Financiación vigente, 2= Financiación vigente pero en 6 meses o menos vence, 3= Financiación no vigente*/
/*CLASIFICACION DESC_TIPO_CLIENTE*/
CASE WHEN DESC_TIPO_CLIENTE IN ('Autónomos','Otros autónomos') THEN 1 ELSE 0
END FLAG_CLIENTE_AUTONOMO,
CASE WHEN DESC_TIPO_CLIENTE IN ('Actividades de Ocio','Actividades relacionadas con la construcción','Administración Pública','Agricultura y Ganadería','Alimentación y bebidas','Ambulancia','Carpinteria y Ferretería','Carrozado','Comercio','Educación','Fabricación y Estructuras','Fresh','Inmobiliaria','Instalaciones eléctricas','Mantenimiento y Reparación','Mensajeros','Objetos del Hogar','RaC','Sanidad','Taxi','Textil','Transporte personas','Transportista') THEN 1 ELSE 0
END FLAG_CLIENTE_LABORAL,
CASE WHEN DESC_TIPO_CLIENTE IN ('Automoción','Particular VN','Particular VO DMS','Particular VO DMS sin transferencia','Particular VO IMA DWA','Particular VO IMA NO DWA') THEN 1 ELSE 0
END FLAG_CLIENTE_PARTICULAR,
CASE WHEN DESC_TIPO_CLIENTE IN ('Indefinido','No identificado (código campaña nuevo)','No Particular VO DMS','No Particular VO DMS sin transferencia','No Particular VO IMA DWA','No Particular VO IMA NO DWA','Pymes Renting','Resto','Transporte adaptado') THEN 1 ELSE 0
END FLAG_CLIENTE_OTROS
FROM CLIMAPROODS.DIM_RELACIONES_IMP RELS
WHERE RELS.FLAG_REGISTRO_INACTIVO <> 1
/*SOLO RELACION 1 = PROPIETARIO*/
AND RELS.COD_TIPO_RELACION IN (1)
--AND RELS.FLAG_RELACION_ACTIVA = 1
/*AND (RELS.FECHA_BAJA_CONS IS NULL OR EXTRACT(YEAR FROM RELS.FECHA_BAJA_CONS) > '2015')
AND  EXTRACT(YEAR FROM RELS.FECHA_ALTA_CONS) = '2015'*/
),

PEDS AS(
SELECT
COD_VEHICULO_CLIMAPRO,
ANYOS_DESDE_ENTREGA,
FLAG_FLOTA,
/*CLASIFICACIÓN DESC_TIPO_VENTA_VN*/

CASE WHEN DESC_TIPO_VENTA_VN IN ('COLECTIVOS') THEN 1 ELSE 0
END FLAG_VENTA_VN_COLECTIVO,
CASE WHEN DESC_TIPO_VENTA_VN IN ('EMPLEADOS','EMPLEADO RED') THEN 1 ELSE 0
END FLAG_VENTA_VN_EMPLEADO,
CASE WHEN DESC_TIPO_VENTA_VN IN ('FLOTA EMPRESA (1 A 4 UNIDADES)','FLOTA EMPRESA (5 O MAS UNIDADES)','GRANDES FLOTAS','FLOTAS DE EMPRESA TABLA 2B') THEN 1 ELSE 0
END FLAG_VENTA_VN_FLOTA,
CASE WHEN DESC_TIPO_VENTA_VN IN ('') OR DESC_TIPO_VENTA_VN IS NULL  THEN 1 ELSE 0
END FLAG_VENTA_VN_NA,
CASE WHEN DESC_TIPO_VENTA_VN IN ('COCHES DEMOSTRACION','ACCION TACTICA, ESTRATEGICA, FAMILIA NUMEROSA Y ONG','RAC (5 O MAS UNIDADES)','ORGANISMOS OFICIALES','VEHICULO DE ASISTENCIA CONCESION','RAC DIRECTO SIN BUYBACK','ACCIONES ESPECIALES LIQUIDACION STOCK') THEN 1 ELSE 0
END FLAG_VENTA_VN_OTROS,
CASE WHEN DESC_TIPO_VENTA_VN IN ('PERSONA NORMAL','CLIENTE PARTICULAR') THEN 1 ELSE 0
END FLAG_VENTA_VN_PERSONA,
CASE WHEN DESC_TIPO_VENTA_VN IN ('EMPRESA RENTING','RENTACAR','RENTING (1 A 4 UNIDADES)','RENTACAR LARGO PLAZO SIN BUYBACK','RENTING (5 O MAS UNIDADES)','LEASE PLAN RENTING FLEXIBLE') THEN 1 ELSE 0
END FLAG_VENTA_VN_RENTING,
CASE WHEN DESC_TIPO_VENTA_VN IN ('TAXI') THEN 1 ELSE 0
END FLAG_VENTA_VN_TAXI,
CASE WHEN DESC_TIPO_VENTA_VN IN ('SINIESTROS VENTA VO') THEN 1 ELSE 0
END FLAG_VENTA_VN_VO,

CASE WHEN COD_TIPO_PEDIDO = 'VN' THEN 1 ELSE 0
END FLAG_PEDIDO_VN
/*CASE WHEN COD_TIPO_PEDIDO = 'VO' THEN 1 ELSE 0
END FLAG_PEDIDO_VO,*/
FROM CLIMAPROODS.DIM_PEDIDOS PEDS
WHERE COD_MARCA = '36L'
AND COD_ESTADO_SLI = 70),

VEHS AS(
SELECT
COD_VEHICULO_CLIMAPRO,
FECHA_ULT_REPARACION,
FLAG_FINANCIADO,

CASE
WHEN COD_GRUP_MOD_1_TAX IN (1528) THEN 1
WHEN COD_GRUP_MOD_1_TAX IN (660,958)THEN 2
WHEN COD_GRUP_MOD_1_TAX IN (658,1058) THEN 3
WHEN COD_GRUP_MOD_1_TAX IN (662,1673,659) THEN 4
WHEN COD_GRUP_MOD_1_TAX IN (653,1611) THEN 5
WHEN COD_GRUP_MOD_1_TAX IN (940) THEN 6
WHEN COD_GRUP_MOD_1_TAX IN (1077,663,661) THEN 7
WHEN COD_GRUP_MOD_1_TAX IN (25,895,378,1160,562) THEN 8
END COD_MODELO,

CASE WHEN COD_GRUP_MOD_1_TAX IN (1528) THEN 1 ELSE 0
END FLAG_MODELO_1,
CASE WHEN COD_GRUP_MOD_1_TAX IN (660,958) THEN 1 ELSE 0
END FLAG_MODELO_2,
CASE WHEN COD_GRUP_MOD_1_TAX IN (658,1058) THEN 1 ELSE 0
END FLAG_MODELO_3,
CASE WHEN COD_GRUP_MOD_1_TAX IN (662,1673,659) THEN 1 ELSE 0
END FLAG_MODELO_4,
CASE WHEN COD_GRUP_MOD_1_TAX IN (653,1611) THEN 1 ELSE 0
END FLAG_MODELO_5,
CASE WHEN COD_GRUP_MOD_1_TAX IN (940) THEN 1 ELSE 0
END FLAG_MODELO_6,
CASE WHEN COD_GRUP_MOD_1_TAX IN (1077,663,661) THEN 1 ELSE 0
END FLAG_MODELO_7,
CASE WHEN COD_GRUP_MOD_1_TAX IN (25,895,378,1160,562) THEN 1 ELSE 0
END FLAG_MODELO_8,


CASE WHEN DESC_TIPO_COMBUSTIBLE = 'DIESEL'
THEN 1 ELSE 0
END FLAG_DIESEL,
CASE WHEN DESC_TIPO_COMBUSTIBLE = 'GASOLINA'
THEN 1 ELSE 0
END FLAG_GASOLINA,
CASE WHEN DESC_TIPO_COMBUSTIBLE = 'GASOLINA/GAS'
THEN 1 ELSE 0
END FLAG_GASOLINA_GAS,

PESO_VEHICULO_SLI,
FECHA_MATRICULACION,
KILOMETRAJE,
NUM_OPCIONALES_SLI
FROM CLIMAPROODS.DIM_VEHICULOS VEHS
WHERE VEHS.COD_MARCA = '36L'),

VATR AS(
SELECT
COD_VEHICULO_CLIMAPRO,
/*CLASIFICACION LIFE COMMERCE*/
CASE WHEN FLAG_LIFE = 1 THEN 1
WHEN FLAG_COMMERCE = 1 THEN 0
WHEN UPPER(DESC_GRUPO_MODELO) IN ('GRAND CALIFORNIA','CALIFORNIA','CALIFORNIA  ','CARAVELLE  ','CARAVELLE') THEN 1
ELSE 0
END FLAG_LIFE,
NUM_ORS_ULTIMO_ANYO,
MESES_DESDE_MATRICULACION,
POTENCIA_CV,
NUM_ORS_MANT_ULTIMO_ANYO,
FECHA_ULTIMA_OR_MANT,
FLAG_3500KG,
FECHA_ALTA_LONGDRIVE,
FECHA_ULTIMA_OR,
KM_ESTIMADO
FROM CLIMAPROODS.DIM_VEHICULOS_ATR VATR)

SELECT *

FROM VEHS VEHS

INNER JOIN RELS RELS
ON VEHS.COD_VEHICULO_CLIMAPRO = RELS.COD_VEHICULO_CLIMAPRO

INNER JOIN PERS PERS
ON RELS.COD_PERSONA_CLIMAPRO_I = PERS.COD_PERSONA_CLIMAPRO_I

INNER JOIN PATR PATR
ON PATR.COD_PERSONA_CLIMAPRO_I = PERS.COD_PERSONA_CLIMAPRO_I
--18.135
INNER JOIN VATR VATR
ON VATR.COD_VEHICULO_CLIMAPRO = VEHS.COD_VEHICULO_CLIMAPRO

INNER JOIN PM PM
ON PM.COD_PERSONA_CLIMAPRO_I = PERS.COD_PERSONA_CLIMAPRO_I

INNER JOIN PEDS PEDS
ON PEDS.COD_VEHICULO_CLIMAPRO = VEHS.COD_VEHICULO_CLIMAPRO
