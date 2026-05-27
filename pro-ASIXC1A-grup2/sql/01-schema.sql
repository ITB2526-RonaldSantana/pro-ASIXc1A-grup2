-- =====================================================
-- BASE DE DADES: InnovateTech
-- Script complet per a MySQL Workbench
-- Autor: Persona 4
-- Data: 19/05/2026
-- Descripció: Creació de totes les taules segons model E/R
--              amb PK, FK, NOT NULL, UNIQUE, CHECK i dades de prova
-- =====================================================

-- 1. Crear i seleccionar la base de dades
DROP DATABASE IF EXISTS InnovateTech;
CREATE DATABASE InnovateTech;
USE InnovateTech;

-- =====================================================
-- 2. CREACIÓ DE TAULES (ordre respectant FK)
-- =====================================================

-- 2.1 Taula DEPARTAMENT (sense FK)
CREATE TABLE DEPARTAMENT (
    codi INT NOT NULL AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL UNIQUE,   -- UNIQUE afegit
    telefon VARCHAR(20) NULL,
    PRIMARY KEY (codi)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.2 Taula EMPLEAT (FK cap a DEPARTAMENT)
CREATE TABLE EMPLEAT (
    dni VARCHAR(9) NOT NULL,
    nom VARCHAR(50) NOT NULL,
    cognoms VARCHAR(100) NOT NULL,
    adreça VARCHAR(255) NULL,
    telefon VARCHAR(20) NULL,
    codi_departament INT NOT NULL,
    PRIMARY KEY (dni),
    FOREIGN KEY (codi_departament) REFERENCES DEPARTAMENT(codi)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.3 Taula USUARI (FK cap a EMPLEAT, opcional)
CREATE TABLE USUARI (
    id_usuari INT NOT NULL AUTO_INCREMENT,
    nom_complet VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,   -- UNIQUE afegit
    extensio_identificador VARCHAR(20) NULL,
    estat ENUM('actiu','bloquejat') NOT NULL DEFAULT 'actiu',
    tipus ENUM('intern','extern') NOT NULL,
    dni_empleat VARCHAR(9) NULL,
    PRIMARY KEY (id_usuari),
    FOREIGN KEY (dni_empleat) REFERENCES EMPLEAT(dni)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.4 Taula ROL
CREATE TABLE ROL (
    nom_rol VARCHAR(20) NOT NULL,
    PRIMARY KEY (nom_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.5 Taula USUARI_ROL (associativa N:M)
CREATE TABLE USUARI_ROL (
    id_usuari INT NOT NULL,
    nom_rol VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_usuari, nom_rol),
    FOREIGN KEY (id_usuari) REFERENCES USUARI(id_usuari)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nom_rol) REFERENCES ROL(nom_rol)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.6 Taula GRUP_QUALITAT
CREATE TABLE GRUP_QUALITAT (
    id_grup INT NOT NULL AUTO_INCREMENT,
    nom_grup VARCHAR(30) NOT NULL,
    parametres TEXT NULL,
    PRIMARY KEY (id_grup)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.7 Taula TRUCADA (FK cap a USUARI i GRUP_QUALITAT) amb CHECK
CREATE TABLE TRUCADA (
    id_trucada INT NOT NULL AUTO_INCREMENT,
    usuari_originador INT NOT NULL,
    usuari_destinatari INT NOT NULL,
    data_inici DATETIME NOT NULL,
    data_fi DATETIME NULL,
    durada_total INT NULL COMMENT 'Durada en segons',
    id_grup_qualitat INT NOT NULL,
    puntuacio INT NULL,
    comentari TEXT NULL,
    PRIMARY KEY (id_trucada),
    FOREIGN KEY (usuari_originador) REFERENCES USUARI(id_usuari)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (usuari_destinatari) REFERENCES USUARI(id_usuari)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_grup_qualitat) REFERENCES GRUP_QUALITAT(id_grup)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_durada CHECK (durada_total IS NULL OR durada_total >= 0),
    CONSTRAINT chk_puntuacio CHECK (puntuacio IS NULL OR (puntuacio BETWEEN 1 AND 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.8 Taula VIDEO
CREATE TABLE VIDEO (
    id_video INT NOT NULL AUTO_INCREMENT,
    titol VARCHAR(200) NOT NULL,
    descripcio TEXT NULL,
    categoria VARCHAR(100) NULL,
    durada INT NULL COMMENT 'Durada en segons',
    data_publicacio DATE NULL,
    enllac_streaming VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_video)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.9 Taula MESURA_AMPLADA_BANDA (FK cap a USUARI) amb CHECK
CREATE TABLE MESURA_AMPLADA_BANDA (
    id_mesura INT NOT NULL AUTO_INCREMENT,
    data_hora DATETIME NOT NULL,
    usuari_equip_mesurat VARCHAR(100) NOT NULL,
    velocitat_baixada FLOAT NOT NULL COMMENT 'Mbps',
    velocitat_pujada FLOAT NOT NULL COMMENT 'Mbps',
    latencia FLOAT NOT NULL COMMENT 'ms',
    resultat ENUM('acceptable','no acceptable') NOT NULL,
    operari_id INT NOT NULL,
    notes TEXT NULL,
    PRIMARY KEY (id_mesura),
    FOREIGN KEY (operari_id) REFERENCES USUARI(id_usuari)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_velocitat_baixada CHECK (velocitat_baixada >= 0),
    CONSTRAINT chk_velocitat_pujada CHECK (velocitat_pujada >= 0),
    CONSTRAINT chk_latencia CHECK (latencia >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.10 Taula CONFIGURACIO_SERVIDOR
CREATE TABLE CONFIGURACIO_SERVIDOR (
    id_config INT NOT NULL AUTO_INCREMENT,
    parametre VARCHAR(50) NOT NULL,
    valor TEXT NOT NULL,
    PRIMARY KEY (id_config)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.11 Taula AVIS (FK cap a USUARI)
CREATE TABLE AVIS (
    id_avis INT NOT NULL AUTO_INCREMENT,
    usuari_id INT NOT NULL,
    taula_afectada VARCHAR(100) NOT NULL,
    operacio_intentada VARCHAR(50) NOT NULL,
    data_hora DATETIME NOT NULL,
    detall TEXT NULL,
    PRIMARY KEY (id_avis),
    FOREIGN KEY (usuari_id) REFERENCES USUARI(id_usuari)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.12 Taula CONTROL_BACKUP
CREATE TABLE CONTROL_BACKUP (
    id_backup INT NOT NULL AUTO_INCREMENT,
    data_hora DATETIME NOT NULL,
    taules_incloses TEXT NOT NULL,
    resultat VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_backup)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.13 Taula CONTRASENYES (historial de contrasenyes per usuari)
CREATE TABLE CONTRASENYES (
    id_contrasenya INT NOT NULL AUTO_INCREMENT,
    usuari_id INT NOT NULL,
    hash_contrasenya VARCHAR(255) NOT NULL,
    data_creacio DATETIME NOT NULL DEFAULT NOW(),
    activa TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_contrasenya),
    FOREIGN KEY (usuari_id) REFERENCES USUARI(id_usuari)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 3. INSERCIÓ DE DADES DE PROVA (significatives)
-- =====================================================

-- 3.1 Departaments
INSERT INTO DEPARTAMENT (nom, telefon) VALUES
('Vendes', '934123456'),
('Suport Tècnic', '934123457'),
('Administració', '934123458'),
('Logística', '934123459');

-- 3.2 Empleats
INSERT INTO EMPLEAT (dni, nom, cognoms, adreça, telefon, codi_departament) VALUES
('12345678A', 'Joan', 'Garcia Pujol', 'Carrer Major 1, Barcelona', '611111111', 1),
('23456789B', 'Maria', 'Lopez Fernandez', 'Avinguda Diagonal 2, Barcelona', '622222222', 2),
('34567890C', 'Carles', 'Martinez Roca', 'Plaça Catalunya 3, Barcelona', '633333333', 3),
('45678901D', 'Laura', 'Sanchez Vidal', 'Carrer Balmes 4, Barcelona', '644444444', 4);

-- 3.3 Usuaris (interns i externs)
INSERT INTO USUARI (nom_complet, email, extensio_identificador, estat, tipus, dni_empleat) VALUES
('Joan Garcia', 'joan.garcia@innovatech.com', '101', 'actiu', 'intern', '12345678A'),
('Maria Lopez', 'maria.lopez@innovatech.com', '102', 'actiu', 'intern', '23456789B'),
('Carles Martinez', 'carles.martinez@innovatech.com', '103', 'actiu', 'intern', '34567890C'),
('Laura Sanchez', 'laura.sanchez@innovatech.com', '104', 'actiu', 'intern', '45678901D'),
('Client Extern 1', 'client1@exemple.com', NULL, 'actiu', 'extern', NULL),
('Client Extern 2', 'client2@exemple.com', NULL, 'bloquejat', 'extern', NULL);

-- 3.4 Rols
INSERT INTO ROL (nom_rol) VALUES ('admin'), ('vendes'), ('administracio'), ('treballador');

-- 3.5 Assignació rols (cada usuari té un rol)
INSERT INTO USUARI_ROL (id_usuari, nom_rol) VALUES
(1, 'admin'),
(2, 'vendes'),
(3, 'administracio'),
(4, 'treballador'),
(5, 'vendes'),
(6, 'treballador');

-- 3.6 Grups de qualitat
INSERT INTO GRUP_QUALITAT (nom_grup, parametres) VALUES
('Alta', '{"video":"1080p","audio":"stereo","bitrate":"2Mbps"}'),
('Mitja', '{"video":"720p","audio":"mono","bitrate":"1Mbps"}'),
('Baixa', '{"video":"480p","audio":"mono","bitrate":"500Kbps"}');

-- 3.7 Trucades
INSERT INTO TRUCADA (usuari_originador, usuari_destinatari, data_inici, data_fi, durada_total, id_grup_qualitat, puntuacio, comentari) VALUES
(1, 2, '2026-05-19 10:00:00', '2026-05-19 10:05:30', 330, 1, 5, 'Trucada excel·lent'),
(2, 3, '2026-05-19 11:00:00', '2026-05-19 11:03:00', 180, 2, 4, 'Bona qualitat'),
(5, 1, '2026-05-19 12:00:00', '2026-05-19 12:10:00', 600, 3, NULL, NULL);

-- 3.8 Vídeos
INSERT INTO VIDEO (titol, descripcio, categoria, durada, data_publicacio, enllac_streaming) VALUES
('Introducció a InnovateTech', 'Vídeo corporatiu de presentació', 'Corporatiu', 120, '2026-05-01', 'http://23.23.53.151/videos/videoplayback.mp4'),
('Tutorial de videotrucades', 'Com fer servir el sistema de videoconferència', 'Tutorial', 300, '2026-05-10', 'http://23.23.53.151/videos/videoplayback.mp4');

-- 3.9 Mesures d’amplada de banda
INSERT INTO MESURA_AMPLADA_BANDA (data_hora, usuari_equip_mesurat, velocitat_baixada, velocitat_pujada, latencia, resultat, operari_id, notes) VALUES
('2026-05-19 09:00:00', 'Servidor Principal', 95.5, 45.2, 12.3, 'acceptable', 1, 'Connexió estable'),
('2026-05-19 10:00:00', 'Client Extern 1', 25.0, 8.5, 45.0, 'no acceptable', 2, 'Baixa amplada de banda');

-- 3.10 Configuració servidor
INSERT INTO CONFIGURACIO_SERVIDOR (parametre, valor) VALUES
('port', '443'),
('protocol', 'HTTPS+WebRTC'),
('max_concurrent_calls', '100'),
('video_quality_default', 'mitja');

-- 3.11 Avisos d’exemple
INSERT INTO AVIS (usuari_id, taula_afectada, operacio_intentada, data_hora, detall) VALUES
(4, 'NOMINES', 'UPDATE', NOW(), 'Usuari treballador intenta modificar nòmines');

-- 3.12 Control backups
INSERT INTO CONTROL_BACKUP (data_hora, taules_incloses, resultat) VALUES
(NOW(), 'EMPLEAT, USUARI, TRUCADA', 'èxit');

-- 3.13 Contrasenyes inicials de prova (text pla — el login accepta text pla i hash bcrypt)
INSERT INTO CONTRASENYES (usuari_id, hash_contrasenya, data_creacio, activa) VALUES
(1, 'pirineus', NOW(), 1),
(2, 'pirineus', NOW(), 1),
(3, 'pirineus', NOW(), 1),
(4, 'pirineus', NOW(), 1),
(5, 'pirineus', NOW(), 1),
(6, 'pirineus', NOW(), 1);

-- =====================================================
-- FI DEL SCRIPT
-- =====================================================