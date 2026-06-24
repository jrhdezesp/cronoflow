-- =======================================================
-- CronoFlow v2.0 - Tablas de Seguridad (RBAC)
-- =======================================================

CREATE TABLE IF NOT EXISTS `usuario` (
  `usercod`            BIGINT(10)   NOT NULL AUTO_INCREMENT,
  `useremail`          VARCHAR(80)  NOT NULL,
  `username`           VARCHAR(80)  DEFAULT NULL,
  `userpswd`           VARCHAR(128) DEFAULT NULL,
  `userfching`         DATETIME     DEFAULT NULL,
  `userpswdest`        CHAR(3)      DEFAULT NULL,
  `userpswdexp`        DATETIME     DEFAULT NULL,
  `userest`            CHAR(3)      DEFAULT NULL,
  `useractcod`         VARCHAR(128) DEFAULT NULL,
  `userpswdchg`        VARCHAR(128) DEFAULT NULL,
  `usertipo`           CHAR(3)      DEFAULT NULL COMMENT 'PRP=Propietario, ADM=Admin, AUD=Auditor, PBL=Público',
  `userfailedattempts` INT(11)      DEFAULT 0,
  `userblockedat`      DATETIME     DEFAULT NULL,
  PRIMARY KEY (`usercod`),
  UNIQUE KEY `useremail_UNIQUE` (`useremail`),
  KEY `usertipo` (`usertipo`, `useremail`, `usercod`, `userest`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `roles` (
  `rolescod` VARCHAR(15) NOT NULL,
  `rolesdsc` VARCHAR(45) DEFAULT NULL,
  `rolesest` CHAR(3)     DEFAULT NULL,
  PRIMARY KEY (`rolescod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `roles_usuarios` (
  `usercod`     BIGINT(10) NOT NULL,
  `rolescod`    VARCHAR(15) NOT NULL,
  `roleuserest` CHAR(3)     DEFAULT NULL,
  `roleuserfch` DATETIME    DEFAULT NULL,
  `roleuserexp` DATETIME    DEFAULT NULL,
  PRIMARY KEY (`usercod`, `rolescod`),
  KEY `rol_usuario_key_idx` (`rolescod`),
  CONSTRAINT `rol_usuario_key` FOREIGN KEY (`rolescod`) REFERENCES `roles` (`rolescod`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `usuario_rol_key` FOREIGN KEY (`usercod`) REFERENCES `usuario` (`usercod`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `funciones` (
  `fncod` VARCHAR(255) NOT NULL,
  `fndsc` VARCHAR(45)  DEFAULT NULL,
  `fnest` CHAR(3)      DEFAULT NULL,
  `fntyp` CHAR(3)      DEFAULT NULL,
  PRIMARY KEY (`fncod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `funciones_roles` (
  `rolescod` VARCHAR(15)  NOT NULL,
  `fncod`    VARCHAR(255) NOT NULL,
  `fnrolest` CHAR(3)      DEFAULT NULL,
  `fnexp`    DATETIME     DEFAULT NULL,
  PRIMARY KEY (`rolescod`, `fncod`),
  KEY `rol_funcion_key_idx` (`fncod`),
  CONSTRAINT `funcion_rol_key` FOREIGN KEY (`rolescod`) REFERENCES `roles` (`rolescod`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `rol_funcion_key` FOREIGN KEY (`fncod`) REFERENCES `funciones` (`fncod`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `bitacora` (
  `bitacoracod`  INT(11)      NOT NULL AUTO_INCREMENT,
  `bitacorafch`  DATETIME     DEFAULT NULL,
  `bitprograma`  VARCHAR(255) DEFAULT NULL,
  `bitdescripcion` VARCHAR(255) DEFAULT NULL,
  `bitobservacion` MEDIUMTEXT DEFAULT NULL,
  `bitTipo`      CHAR(3)      DEFAULT NULL,
  `bitusuario`   BIGINT(18)   DEFAULT NULL,
  PRIMARY KEY (`bitacoracod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
