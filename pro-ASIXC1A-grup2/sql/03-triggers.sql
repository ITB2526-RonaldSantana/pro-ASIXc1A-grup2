-- =====================================================
-- TRIGGERS: InnovateTech
-- =====================================================

USE InnovateTech;

DELIMITER $$

-- Impedeix que un usuari bloquejat pugui fer trucades.
-- S'activa abans de qualsevol INSERT a TRUCADA i llança
-- l'error 1644 si l'originador té estat = 'bloquejat'.
CREATE TRIGGER check_usuari_bloquejat
BEFORE INSERT ON TRUCADA
FOR EACH ROW
BEGIN
    DECLARE estat_usuari VARCHAR(20);
    SELECT estat INTO estat_usuari
    FROM USUARI
    WHERE id_usuari = NEW.usuari_originador;
    IF estat_usuari = 'bloquejat' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuari bloquejat. No pot fer trucades.';
    END IF;
END$$

-- Bloqueja automàticament un usuari si acumula 5 o més
-- intents d'accés no autoritzat en els últims 10 minuts.
CREATE TRIGGER trg_bloqueig_automatic
AFTER INSERT ON AVIS
FOR EACH ROW
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt
    FROM AVIS
    WHERE usuari_id = NEW.usuari_id
      AND data_hora >= NOW() - INTERVAL 10 MINUTE;
    IF cnt >= 5 THEN
        UPDATE USUARI SET estat = 'bloquejat'
        WHERE id_usuari = NEW.usuari_id AND estat = 'actiu';
    END IF;
END$$

DELIMITER ;
