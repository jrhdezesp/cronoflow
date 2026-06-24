-- =======================================================
-- CronoFlow v2.0 - Parche de Seguridad (Migración)
-- Corrige funciones/funciones_roles agregando FK
-- =======================================================
-- NOTA: Este script es solo para migración desde la
-- versión anterior.

ALTER TABLE `bitacora`
  CHANGE `bitprograma` `bitprograma` VARCHAR(255)
  CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;
