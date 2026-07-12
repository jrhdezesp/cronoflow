-- =======================================================
-- CronoFlow v2.0 - Tabla de Categorías
-- =======================================================

CREATE TABLE IF NOT EXISTS `categorias` (
  `catid`  BIGINT(8) NOT NULL AUTO_INCREMENT,
  `catnom` VARCHAR(45) NOT NULL,
  `catest` CHAR(3)  DEFAULT 'ACT',
  PRIMARY KEY (`catid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
