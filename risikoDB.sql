-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema risikoDB
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `risikoDB` ;

-- -----------------------------------------------------
-- Schema risikoDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `risikoDB` ;
USE `risikoDB` ;

-- -----------------------------------------------------
-- Table `risikoDB`.`Utenti`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`Utenti` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`Utenti` (
  `Username` VARCHAR(32) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  `Ruolo` ENUM('moderatore', 'giocatore') NOT NULL,
  PRIMARY KEY (`Username`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `risikoDB`.`Giocatore`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`Giocatore` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`Giocatore` (
  `GamerTag` VARCHAR(32) NOT NULL,
  `NumCarriDisponibili` INT NULL,
  `TempoUltimaAzione` TIMESTAMP NULL,
  PRIMARY KEY (`GamerTag`),
  CONSTRAINT `GamerTag_Giocatore`
    FOREIGN KEY (`GamerTag`)
    REFERENCES `risikoDB`.`Utenti` (`Username`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `risikoDB`.`StanzaDiGioco`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`StanzaDiGioco` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`StanzaDiGioco` (
  `NomeStanza` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`NomeStanza`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `risikoDB`.`Partita`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`Partita` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`Partita` (
  `CodicePartita` INT NOT NULL AUTO_INCREMENT,
  `Stanza` VARCHAR(45) NOT NULL,
  `StatoPartita` ENUM('wait', 'exec', 'end') NOT NULL DEFAULT 'wait',
  `CountdownClock` TIME NULL,
  `Vincitore` VARCHAR(32) NULL,
  PRIMARY KEY (`CodicePartita`),
  CONSTRAINT `Vincitore_Partita`
    FOREIGN KEY (`Vincitore`)
    REFERENCES `risikoDB`.`Giocatore` (`GamerTag`)
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
  CONSTRAINT `Stanza_Partita`
    FOREIGN KEY (`Stanza`)
    REFERENCES `risikoDB`.`StanzaDiGioco` (`NomeStanza`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `VINCITORE_PARTITA_idx` ON `risikoDB`.`Partita` (`Vincitore` ASC) VISIBLE;

CREATE INDEX `Stanza_Partita_idx` ON `risikoDB`.`Partita` (`Stanza` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `risikoDB`.`Territorio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`Territorio` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`Territorio` (
  `NomeTerritorio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`NomeTerritorio`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `risikoDB`.`IstanzaDiTerritorio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`IstanzaDiTerritorio` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`IstanzaDiTerritorio` (
  `Territorio` VARCHAR(45) NOT NULL,
  `Partita` INT NOT NULL,
  `Proprietario` VARCHAR(32) NOT NULL,
  `NumCarriPosizionati` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`Territorio`, `Partita`),
  CONSTRAINT `Territorio_IstanzaDiTerritorio`
    FOREIGN KEY (`Territorio`)
    REFERENCES `risikoDB`.`Territorio` (`NomeTerritorio`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `Partita_IstanzaDiTerritorio`
    FOREIGN KEY (`Partita`)
    REFERENCES `risikoDB`.`Partita` (`CodicePartita`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `Proprietario_IstanzaDiTerritorio`
    FOREIGN KEY (`Proprietario`)
    REFERENCES `risikoDB`.`Giocatore` (`GamerTag`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `Partita_IstanzaDiTerritorio_idx` ON `risikoDB`.`IstanzaDiTerritorio` (`Partita` ASC) VISIBLE;

CREATE INDEX `Proprietario_IstanzaDiTerritorio_idx` ON `risikoDB`.`IstanzaDiTerritorio` (`Proprietario` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `risikoDB`.`Partecipa`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`Partecipa` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`Partecipa` (
  `Giocatore` VARCHAR(32) NOT NULL,
  `Partita` INT NOT NULL,
  `NumTurno` INT NOT NULL,
  PRIMARY KEY (`Giocatore`, `Partita`),
  CONSTRAINT `Giocatore_Partecipa`
    FOREIGN KEY (`Giocatore`)
    REFERENCES `risikoDB`.`Giocatore` (`GamerTag`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `Partita_Partecipa`
    FOREIGN KEY (`Partita`)
    REFERENCES `risikoDB`.`Partita` (`CodicePartita`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `Partita_Partecipa_idx` ON `risikoDB`.`Partecipa` (`Partita` ASC) INVISIBLE;

CREATE UNIQUE INDEX `Partita_NumTurno_uq` ON `risikoDB`.`Partecipa` (`Partita` ASC, `NumTurno` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `risikoDB`.`Adiacente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`Adiacente` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`Adiacente` (
  `Territorio1` VARCHAR(45) NOT NULL,
  `Territorio2` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Territorio1`, `Territorio2`),
  CONSTRAINT `Territorio_Adiacente_1`
    FOREIGN KEY (`Territorio1`)
    REFERENCES `risikoDB`.`Territorio` (`NomeTerritorio`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `Territorio_Adiacente_2`
    FOREIGN KEY (`Territorio2`)
    REFERENCES `risikoDB`.`Territorio` (`NomeTerritorio`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `Territorio_Adiacente_2_idx` ON `risikoDB`.`Adiacente` (`Territorio2` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `risikoDB`.`Turno`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `risikoDB`.`Turno` ;

CREATE TABLE IF NOT EXISTS `risikoDB`.`Turno` (
  `idTurno` INT NOT NULL AUTO_INCREMENT,
  `Partita` INT NOT NULL,
  `Giocatore` VARCHAR(32) NOT NULL,
  `StatoTurno` ENUM('noaction', 'action', 'end') NOT NULL DEFAULT 'noaction',
  `Timer` TIME NULL,
  PRIMARY KEY (`idTurno`, `Partita`, `Giocatore`),
  CONSTRAINT `Partita_Turno`
    FOREIGN KEY (`Partita`)
    REFERENCES `risikoDB`.`Partita` (`CodicePartita`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Giocatore_Turno`
    FOREIGN KEY (`Giocatore`)
    REFERENCES `risikoDB`.`Giocatore` (`GamerTag`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `Partita_Turno_idx` ON `risikoDB`.`Turno` (`Partita` ASC) VISIBLE;

CREATE INDEX `Giocatore_Turno_idx` ON `risikoDB`.`Turno` (`Giocatore` ASC) VISIBLE;

USE `risikoDB` ;

-- -----------------------------------------------------
-- procedure registra_nuovo_giocatore
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`registra_nuovo_giocatore`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `registra_nuovo_giocatore` (
IN var_gamerTag VARCHAR(32),
IN var_password VARCHAR(45))
BEGIN
	declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION ;
		INSERT INTO `Utenti` (`Username`, `Password`, `Ruolo`)
			VALUES(var_gamerTag, SHA1(var_password), 'giocatore') ;
	
		INSERT INTO `Giocatore` (`GamerTag`,`NumCarriDisponibili`,`TempoUltimaAzione`)
			VALUES (var_gamerTag, NULL, NULL) ;
    COMMIT ;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure crea_nuova_stanza
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`crea_nuova_stanza`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `crea_nuova_stanza` (
IN var_nome_stanza VARCHAR(45))
BEGIN

	declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED ;
    START TRANSACTION ;
		INSERT INTO `StanzaDiGioco` (`NomeStanza`)
			VALUES(var_nome_stanza) ;
            
		INSERT INTO `Partita` (`Stanza`)  -- creo fin da subito la prima partita contenuta in tale stanza (lo stato di default è 'wait')
			VALUES(var_nome_stanza) ;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_partecipante
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`aggiungi_partecipante`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `aggiungi_partecipante` (
IN var_gamerTag VARCHAR(32),
IN var_nomeStanza VARCHAR(45),
OUT var_codicePartita INT)
BEGIN
	declare var_numPartecipanti INT;

	declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION ;
		-- controllo se il giocatore è già in un'altra partita
		IF controlla_giocatore_in_partita(var_gamerTag) > 0 THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Giocatore già in altra partita! impossibile partecipare.';
		END IF;
		
		-- ricavo il codice della partita che è in quella stanza
		SELECT `CodicePartita` FROM `Partita`
		WHERE `StatoPartita` <> 'end' 
		AND `Partita`.`Stanza`= var_nomeStanza
		INTO var_codicePartita;
		
		-- controllo se la stanza è stata trovata
		IF var_codicePartita IS NULL THEN
			SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Stanza non disponibile! Riprovare o consultare la lista delle stanze disponibili';
		END IF;
        
        -- controllo se la partita è già iniziata
		IF stato_partita(var_codicePartita) <> 'wait' THEN
			SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Partita già iniziata! impossibile partecipare.';
		END IF;
        
        SET var_numPartecipanti = conta_partecipanti(var_codicePartita);
		
		-- assegno il numero di turno nell'ordine di arrivo e inserisco la partecipazione 
		INSERT INTO `Partecipa` (`Giocatore`,`Partita`,`NumTurno`)
			VALUES (var_gamerTag, var_codicePartita, var_numPartecipanti + 1);
            
		IF var_numPartecipanti + 1 = 3 THEN
			UPDATE `Partita` 
			SET `CountdownClock`= current_time()                             -- segna il tempo corrente per il countdown
			WHERE `CodicePartita` = var_codicePartita;
		END IF;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`login`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `login`(
	IN var_username VARCHAR(32), 
	IN var_password VARCHAR(45), 
    OUT var_ruolo INT) 
BEGIN
	declare var_enumRuolo ENUM('moderatore','giocatore') ;
    
	SELECT `Ruolo` FROM `Utenti`
    WHERE `Username` = var_username AND `Password` = SHA1(var_password)
    INTO var_enumRuolo ;
    
    IF var_enumRuolo = 'moderatore' THEN
		SET var_ruolo = 0 ;
	ELSEIF var_enumRuolo = 'giocatore' THEN
		SET var_ruolo = 1 ;
	ELSE
		SET var_ruolo = 2 ; 
	END IF ;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function conta_partecipanti
-- -----------------------------------------------------

USE `risikoDB`;
DROP function IF EXISTS `risikoDB`.`conta_partecipanti`;

DELIMITER $$
USE `risikoDB`$$
CREATE FUNCTION `conta_partecipanti` (var_codicePartita INT) RETURNS INT READS SQL DATA
BEGIN
	declare var_numPartecipanti INT;
    
    SELECT COUNT(*) FROM `Partecipa` 
    WHERE `Partecipa`.`Partita` = var_codicePartita
    INTO var_numPartecipanti;
    
    RETURN var_numPartecipanti;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure vedi_storico_partite
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`vedi_storico_partite`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `vedi_storico_partite` (
IN var_gamerTag VARCHAR(32))
BEGIN
	declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION ;
		SELECT `Stanza`, `CodicePartita`, `Vincitore` FROM `Partita` 
		JOIN `Partecipa` ON `Partecipa`.`Partita` = `Partita`.`CodicePartita`
		WHERE `Partecipa`.`Giocatore` = var_gamerTag AND `Partita`.`StatoPartita` = 'end';
		
		CALL reset_tempo_ultima_azione(var_gamerTag);
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure rimuovi_partecipante
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`rimuovi_partecipante`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `rimuovi_partecipante` (
IN var_gamerTag VARCHAR(32))
BEGIN
    declare var_codicePartita INT;
    declare var_lastPlayer VARCHAR(32);
    declare var_numPartecipanti INT;
    declare var_statoPartita ENUM('wait','exec','end');
    
    declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; 
    START TRANSACTION ;
		SET var_codicePartita = recupera_partita(var_gamerTag);
        SET var_statoPartita = stato_partita(var_codicePartita);
        
        IF var_statoPartita <> 'end' THEN
			IF var_statoPartita = 'exec' THEN
				CALL controlla_proprietario_turno(var_gamerTag, var_codicePartita);
				CALL cambio_turno(var_codicePartita, var_gamerTag);
			END IF;
		
			DELETE FROM `Partecipa` WHERE  `Giocatore` = var_gamerTag AND `Partita`= var_codicePartita; 
			
			SET var_numPartecipanti = conta_partecipanti(var_codicePartita);
            
            IF var_numPartecipanti < 3 AND var_statoPartita = 'wait' THEN
				UPDATE `Partita` 
				SET `CountdownClock` = NULL 										-- ripristino il timer di countdown
				WHERE `Partita`.`CodicePartita` = var_codicePartita;
			END IF;
			
			IF var_statoPartita = 'exec' AND var_numPartecipanti = 1 THEN -- termino partita e decreto vincitore nel caso di ultimo giocatore rimasto in partita
				SELECT `Giocatore` FROM `Partecipa`
				WHERE `Partecipa`.`Partita` = var_codicePartita
				INTO var_lastPlayer;
			
				UPDATE `Partita` SET `Vincitore` = var_lastPlayer, `StatoPartita` = 'end'
				WHERE `Partita`.`CodicePartita` = var_codicePartita;
			END IF;
			
			CALL riassegna_turni(var_codicePartita, var_gamerTag); -- si occuperà di redistribuire anche i territori in caso la partita era in corso
			CALL reset_tempo_ultima_azione(var_gamerTag);
        END IF;
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure gioca_partita
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`gioca_partita`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `gioca_partita` (
IN var_codicePartita INT)
BEGIN
    declare var_nomeTerritorio VARCHAR(45);
    declare var_numPartecipanti INT;
    declare var_carriArmatiDisp INT;
    declare var_gamerTag VARCHAR(32);
    declare var_whileIndex INT;
    
	SELECT conta_partecipanti(var_codicePartita) INTO var_numPartecipanti;
    
	IF var_numPartecipanti = 3 THEN SET var_carriArmatiDisp = 35;
	ELSEIF var_numPartecipanti = 4 THEN SET var_carriArmatiDisp = 30; 
	ELSEIF var_numPartecipanti = 5 THEN SET var_carriArmatiDisp = 25; 
	ELSE SET var_carriArmatiDisp = 20;
	END IF;
    
    -- imposto il numero di carri armati disponibili ai giocatori
	UPDATE `Giocatore` SET `NumCarriDisponibili` = var_carriArmatiDisp
	WHERE `GamerTag` IN (SELECT `Giocatore`	FROM `Partecipa` 
						WHERE `Partita` = var_codicePartita);
    
	-- creo e distribuisco le istanze dei territori casualmente
	SET var_whileIndex = 42;
	WHILE var_whileIndex > 0 DO
		-- seleziono casualmente un nome di territorio per cui l'istanza non è già stata creata
		SELECT `NomeTerritorio` FROM `Territorio`
		WHERE `NomeTerritorio` NOT IN (SELECT `Territorio` FROM `IstanzaDiTerritorio` 
										WHERE `Partita` = var_codicePartita)
		ORDER BY RAND() LIMIT 1
		INTO var_nomeTerritorio;
		-- assegnazione a carosello tra i partecipanti
		SELECT `Giocatore` FROM `Partecipa` 
		WHERE `Partita` = var_codicePartita
		AND `NumTurno` = (ABS(var_whileIndex-42) % var_numPartecipanti) + 1
		INTO var_gamerTag;
		-- creo l'istanza e la assegno al giocatore selezionato
		INSERT INTO `IstanzaDiTerritorio` (`Territorio`, `Partita`, `Proprietario`)
		VALUES (var_nomeTerritorio, var_codicePartita, var_gamerTag) ;
		-- di default viene impostato il numero di carri armati sul territorio ad 1
		SET var_whileIndex = var_whileIndex - 1;
	END WHILE;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure report_moderatori
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`report_moderatori`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `report_moderatori` ()
BEGIN
	declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al client
    end;
    
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    SET TRANSACTION READ ONLY;
    START TRANSACTION;
    
    -- quante stanze hanno attualmente partite in corso 
    SELECT COUNT(*) AS `StanzeAttive` FROM `StanzaDiGioco` 
    JOIN `Partita` ON `Partita`.`Stanza` = `StanzaDiGioco`.`NomeStanza`
    WHERE `StatoPartita` = 'exec'; 
    
    -- quanti sono i giocatori in ciascuna di queste partite (esiste solo una partecipazione per un giocatore in quella partita dati i vincoli di chiave)
    SELECT `Stanza`,`CodicePartita`,COUNT(*) AS `Partecipanti` FROM `Partita`
    JOIN `Partecipa` ON `Partita`.`CodicePartita` = `Partecipa`.`Partita`
    WHERE `StatoPartita` = 'exec'
    GROUP BY `CodicePartita`;
    
    -- quanti sono i giocatori che hanno effettuato almeno un'azione negli ultimi 15 minuti 
    -- che non sono all'interno di alcuna stanza di gioco.
    SELECT COUNT(*) AS `GiocatoriAttivi` FROM `Giocatore`
    WHERE `TempoUltimaAzione` >= current_timestamp() - INTERVAL 15 MINUTE
    AND controlla_giocatore_in_partita(`Giocatore`.`GamerTag`) = 0;  
    
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inizia_turno
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`inizia_turno`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `inizia_turno` (
IN var_gamerTag VARCHAR(32),
IN var_codicePartita INT)
BEGIN
    INSERT INTO `Turno` (`Partita`,`Giocatore`,`Timer`) 
    VALUES (var_codicePartita,var_gamerTag,current_time());
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function controlla_giocatore_in_partita
-- -----------------------------------------------------

USE `risikoDB`;
DROP function IF EXISTS `risikoDB`.`controlla_giocatore_in_partita`;

DELIMITER $$
USE `risikoDB`$$
CREATE FUNCTION `controlla_giocatore_in_partita`(var_gamertag VARCHAR(32)) RETURNS INT READS SQL DATA
BEGIN
	declare var_partecipazioni INT;
    
    SELECT COUNT(*) FROM `Partecipa` 
    JOIN `Partita` ON `Partecipa`.`Partita` = `Partita`.`CodicePartita`
    WHERE `Partecipa`.`Giocatore` = var_gamerTag AND `Partita`.`StatoPartita` <> 'end'
    INTO var_partecipazioni;
    
    RETURN var_partecipazioni;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure vedi_stato_di_gioco
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`vedi_stato_di_gioco`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `vedi_stato_di_gioco` (
IN var_gamerTag VARCHAR(32))
BEGIN
    declare var_codicePartita INT;
    
    declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET TRANSACTION READ ONLY;
    START TRANSACTION ;
		SET var_codicePartita = recupera_partita(var_gamerTag);
		CALL controlli_prima_di_azione(var_gamerTag, var_codicePartita);
		
		-- TERRITORIO / PROPRIETARIO / ARMATE DISPIEGATE
		SELECT `Territorio`, `Proprietario`, `NumCarriPosizionati` FROM `IstanzaDiTerritorio`
		WHERE `Partita` = var_codicePartita ;
		
		-- GIOCATORE PARTECIPANTE / CARRI DISPONIBILI
		SELECT `GamerTag` AS `Giocatore`,`NumCarriDisponibili` AS `Carri disponibili` FROM `Giocatore`
		JOIN `Partecipa` ON `Partecipa`.`Giocatore` = `Giocatore`.`GamerTag`
		WHERE `Partita` = var_codicePartita;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure riassegna_turni
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`riassegna_turni`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `riassegna_turni` (
IN var_codicePartita INT, 
IN var_giocatoreUscito VARCHAR(32))
BEGIN
	declare done int default false;
    
    declare var_gamerTag VARCHAR(32);
    declare var_nomeTerrDaRiass VARCHAR(45);
    declare var_numTerrDaRiass INT;
    declare var_numPartecipanti INT;
    declare var_i INT;
    
    declare cur_gioc cursor for
    select `Giocatore` from `Partecipa`
    where `Partita` = var_codicePartita
    order by `NumTurno` asc ;
    
    declare continue handler for not found set done = true;
    
    SET var_i = 1;
    
    OPEN cur_gioc;
    update_loop: LOOP
		FETCH cur_gioc INTO var_gamerTag;
		IF done THEN
			LEAVE update_loop;
		END IF;
        UPDATE `Partecipa` SET `NumTurno` = var_i 
        WHERE `Giocatore`= var_gamerTag AND `Partita` = var_codicePartita;
        SET var_i = var_i + 1 ;
    END LOOP;
    CLOSE cur_gioc;
    
    SET var_numPartecipanti = conta_partecipanti(var_codicePartita);
    
    -- GESTIONE CASO PARTITA IN CORSO 
    IF stato_partita(var_codicePartita) = 'exec' THEN -- redistribuzione territori di chi ha abbandonato nel caso di partita in corso
		SET var_i = 0;
        
		SELECT COUNT(*) FROM `IstanzaDiTerritorio`
		WHERE `Partita` = var_codicePartita 
		AND `Proprietario` = var_giocatoreUscito
		INTO var_numTerrDaRiass;

		WHILE var_numTerrDaRiass > 0 DO
			-- seleziono casualmente un nome di territorio tra quelli rimasti di proprietà del giocatore uscito
			SELECT `Territorio` FROM `IstanzaDiTerritorio` 
			WHERE `Partita` = var_codicePartita
			AND `Proprietario` = var_giocatoreUscito
			ORDER BY RAND() LIMIT 1
			INTO var_nomeTerrDaRiass;
			 -- assegnazione a carosello tra i partecipanti
			SELECT `Giocatore` FROM `Partecipa` 
			WHERE `Partita` = var_codicePartita
			AND `NumTurno` = (var_i % var_numPartecipanti) + 1
			INTO var_gamerTag;
			-- aggiorno l'istanza e la assegno al giocatore selezionato e reimposto il numero di carri a 1 per non creare disparità tra le assegnazioni
			UPDATE `IstanzaDiTerritorio` SET `Proprietario` = var_gamerTag, `NumCarriPosizionati` = 1 
            WHERE `Partita` = var_codicePartita AND `Territorio` = var_nomeTerrDaRiass; 
			SET var_i = var_i + 1;
			SET var_numTerrDaRiass = var_numTerrDaRiass - 1;
		END WHILE;	
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function stato_partita
-- -----------------------------------------------------

USE `risikoDB`;
DROP function IF EXISTS `risikoDB`.`stato_partita`;

DELIMITER $$
USE `risikoDB`$$
CREATE FUNCTION `risikoDB`.`stato_partita` (var_codicePartita INT) RETURNS ENUM('wait','exec','end') READS SQL DATA
BEGIN
    declare var_statoPartita ENUM('wait','exec','end');
    
	SELECT `StatoPartita` FROM `Partita`
    WHERE `CodicePartita` = var_codicePartita
    INTO var_statoPartita;
    
    RETURN var_statoPartita;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure cambio_turno
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`cambio_turno`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `cambio_turno` (
IN var_codicePartita INT,
IN var_giocatorePrecedente VARCHAR(32))
BEGIN
	declare var_numPartecipanti INT;
    declare var_numTurnoPrecedente INT;
    declare var_idTurnoPrecedente INT;
    declare var_statoTurnoPrecedente ENUM('noaction','action','end');
    declare var_giocatoreSuccessivo VARCHAR(32);
    declare var_numTurnoSuccessivo INT;
    
	SET var_numPartecipanti = conta_partecipanti(var_codicePartita);
    
	-- mi ricavo il numero di turno del giocatore precedente
	SELECT `NumTurno` FROM `Partecipa`
	WHERE `Partita` = var_codicePartita AND `Giocatore` = var_giocatorePrecedente
	INTO var_numTurnoPrecedente;
	
	SET var_numTurnoSuccessivo = (var_numTurnoPrecedente % var_numPartecipanti) + 1;
    
	-- seleziono il gamerTag del prossimo giocatore
	SELECT `Giocatore` FROM `Partecipa`
	WHERE `Partita` = var_codicePartita 
	AND `NumTurno` = var_numTurnoSuccessivo
	INTO var_giocatoreSuccessivo;
	
	SELECT `idTurno`,`StatoTurno` FROM `Turno` 
	WHERE `Partita` = var_codicePartita AND `Giocatore` = var_giocatorePrecedente
	ORDER BY `idTurno` DESC LIMIT 1
	INTO var_idTurnoPrecedente, var_statoTurnoPrecedente;
	
	IF var_statoTurnoPrecedente = 'action' THEN
		CALL assegna_carriArmati_a_giocatore(var_giocatorePrecedente);
	END IF;
	
	UPDATE `Turno` SET `StatoTurno` = 'end' 
    WHERE `idTurno` = var_idTurnoPrecedente;
	
	CALL inizia_turno(var_giocatoreSuccessivo, var_codicePartita);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure reset_tempo_ultima_azione
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`reset_tempo_ultima_azione`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `reset_tempo_ultima_azione` (
IN var_gamerTag VARCHAR(32))
BEGIN
	UPDATE `Giocatore` 
    SET `TempoUltimaAzione` = current_timestamp() 
    WHERE `Giocatore`.`GamerTag` = var_gamerTag;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure assegna_carriArmati_a_giocatore
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`assegna_carriArmati_a_giocatore`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `assegna_carriArmati_a_giocatore` (
IN var_gamerTag VARCHAR(32))
BEGIN
	declare var_codicePartita INT;
    declare var_numCarriDaAss INT;
   
	declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION ;
		SET var_codicePartita = recupera_partita(var_gamerTag);
		
		SET var_numCarriDaAss = CEILING((calcola_possedimenti(var_gamerTag, var_codicePartita))/3); -- numero di territori posseduti diviso 3 arrotondato per eccesso
		
		UPDATE `Giocatore` SET `NumCarriDisponibili` = `NumCarriDisponibili` + var_numCarriDaAss
		WHERE `GamerTag` = var_gamerTag; 
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function recupera_partita
-- -----------------------------------------------------

USE `risikoDB`;
DROP function IF EXISTS `risikoDB`.`recupera_partita`;

DELIMITER $$
USE `risikoDB`$$
CREATE FUNCTION `recupera_partita` (var_gamerTag VARCHAR(32)) RETURNS INT READS SQL DATA
BEGIN
	declare var_codicePartita INT;
    
    SELECT `CodicePartita` FROM `Partita` 
    JOIN `Partecipa` ON `Partecipa`.`Partita` = `Partita`.`CodicePartita`
    WHERE `Partecipa`.`Giocatore` = var_gamerTag
    ORDER BY `CodicePartita` DESC LIMIT 1
    INTO var_codicePartita;
    
    RETURN var_codicePartita;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure risultato_lancio_dadi
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`risultato_lancio_dadi`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `risultato_lancio_dadi` (
IN var_numDadiAtt INT, 
IN var_numDadiDif INT, 
OUT var_numCarriPersiAtt INT, 
OUT var_numCarriPersiDif INT)
BEGIN
	
	declare var_vald1Att INT DEFAULT NULL;
    declare var_vald2Att INT DEFAULT NULL;
    declare var_vald3Att INT DEFAULT NULL;
    declare var_vald1Dif INT DEFAULT NULL;
    declare var_vald2Dif INT DEFAULT NULL;
    declare var_vald3Dif INT DEFAULT NULL;
    declare var_vald1Tmp INT DEFAULT NULL;
    declare var_vald2Tmp INT DEFAULT NULL;
    declare var_vald3Tmp INT DEFAULT NULL;
    
    declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    START TRANSACTION ;
		IF var_numDadiAtt = 1 THEN
			SET var_vald1Att = FLOOR(RAND()*(6)) + 1;
		ELSEIF var_numDadiAtt = 2 THEN
			SET var_vald1Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald2Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald1Att = GREATEST(var_vald1Tmp, var_vald2Tmp);
			SET var_vald2Att = LEAST(var_vald1Tmp, var_vald2Tmp);
		ELSE
			SET var_vald1Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald2Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald3Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald1Att = GREATEST(var_vald1Tmp, var_vald2Tmp, var_vald3Tmp);
			SET var_vald3Att = LEAST(var_vald1Tmp, var_vald2Tmp, var_vald3Tmp);
			SET var_vald2Att = var_vald1Tmp + var_vald2Tmp + var_vald3Tmp - var_vald1Att - var_vald3Att;
		END IF;
		
		IF var_numDadiDif = 1 THEN
			SET var_vald1Dif = FLOOR(RAND()*(6)) + 1;
		ELSEIF var_numDadiDif = 2 THEN
			SET var_vald1Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald2Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald1Dif = GREATEST(var_vald1Tmp, var_vald2Tmp);
			SET var_vald2Dif = LEAST(var_vald1Tmp, var_vald2Tmp);
		ELSE
			SET var_vald1Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald2Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald3Tmp = FLOOR(RAND()*(6)) + 1;
			SET var_vald1Dif = GREATEST(var_vald1Tmp, var_vald2Tmp, var_vald3Tmp);
			SET var_vald3Dif = LEAST(var_vald1Tmp, var_vald2Tmp, var_vald3Tmp);
			SET var_vald2Dif = var_vald1Tmp + var_vald2Tmp + var_vald3Tmp - var_vald1Att - var_vald3Att;
		END IF;
		
		SET var_numCarriPersiAtt = 0;
		SET var_numCarriPersiDif = 0;
		IF ((var_vald1Att IS NOT NULL) AND (var_vald1Dif IS NOT NULL)) THEN
			IF var_vald1Att > var_vald1Dif THEN 
				SET var_numCarriPersiDif = 1;
			ELSE 
				SET var_numCarriPersiAtt = 1;
			END IF;
		END IF;
		IF ((var_vald2Att IS NOT NULL) AND (var_vald2Dif IS NOT NULL)) THEN
			IF var_vald2Att > var_vald2Dif THEN 
				SET var_numCarriPersiDif = var_numCarriPersiDif + 1;
			ELSE 
				SET var_numCarriPersiAtt = var_numCarriPersiAtt + 1;
			END IF;
		END IF;
		IF ((var_vald3Att IS NOT NULL) AND (var_vald3Dif IS NOT NULL)) THEN
			IF var_vald3Att > var_vald3Dif THEN 
				SET var_numCarriPersiDif = var_numCarriPersiDif + 1;
			ELSE 
				SET var_numCarriPersiAtt = var_numCarriPersiAtt + 1;
			END IF;
		END IF;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure posiziona_carriArmati_su_territorio
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`posiziona_carriArmati_su_territorio`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `posiziona_carriArmati_su_territorio` (
IN var_gamerTag VARCHAR(32),
IN var_numCarriDaPosiz INT,
IN var_nomeTerr VARCHAR(45))
BEGIN
    declare var_codicePartita INT;
    declare var_giocatoreCheck VARCHAR(32);
    declare var_numCarriCheck INT;

	SET var_codicePartita = recupera_partita(var_gamerTag);
	CALL controlli_prima_di_azione(var_gamerTag, var_codicePartita);
    CALL controllo_esistenza_territorio(var_nomeTerr);
    
	-- controllo proprietà del territorio
	SELECT `Proprietario` FROM `IstanzaDiTerritorio`
	WHERE `Partita` = var_codicePartita AND `Territorio` = var_nomeTerr
	INTO var_giocatoreCheck;
	
	IF var_gamerTag <> var_giocatoreCheck THEN
		SIGNAL SQLSTATE '45014' SET MESSAGE_TEXT = 'Il territorio selezionato non è di proprietà del giocatore! Posizionamento carri armati non disponibile.';
	END IF;
	
	-- controllo disponibilità dei carri armati indicati
	SELECT `NumCarriDisponibili` FROM `Giocatore`
	WHERE `GamerTag` = var_gamerTag
	INTO var_numCarriCheck;
	
	IF var_numCarriDaPosiz > var_numCarriCheck THEN
		SIGNAL SQLSTATE '45015' SET MESSAGE_TEXT = 'Carri armati disponibili inferiori a quelli selezionati! Posizionamento carri armati non disponibile.';
	END IF;
	
	UPDATE `IstanzaDiTerritorio` SET `NumCarriPosizionati` = `NumCarriPosizionati` + var_numCarriDaPosiz
	WHERE `Partita` = var_codicePartita AND `Territorio` = var_nomeTerr;
	
	UPDATE `Giocatore` SET `NumCarriDisponibili` = `NumCarriDisponibili` - var_numCarriDaPosiz
	WHERE `GamerTag` = var_gamerTag;
    
    CALL segna_ultimo_turno_azione(var_gamerTag, var_codicePartita);
	
	CALL cambio_turno(var_codicePartita, var_gamerTag);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure sposta_carriArmati_tra_territori
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`sposta_carriArmati_tra_territori`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `sposta_carriArmati_tra_territori` (
IN var_gamerTag VARCHAR(32),
IN var_numCarriDaSpost INT,
IN var_terrPartenza VARCHAR(45),
IN var_terrArrivo VARCHAR(45))
BEGIN
	declare var_codicePartita INT;
    declare var_flag INT;
    declare var_numCarriPosizionati INT;
    
	SET var_codicePartita = recupera_partita(var_gamerTag);
	CALL controlli_prima_di_azione(var_gamerTag, var_codicePartita);
	CALL controllo_esistenza_territorio(var_terrPartenza);
	CALL controllo_esistenza_territorio(var_terrArrivo);
	
	-- controllo che il giocatore sia proprietario di entrambi i territori
	SELECT COUNT(*) FROM `IstanzaDiTerritorio`
	WHERE `Partita` = var_codicePartita AND `Proprietario` = var_gamerTag 
	AND (`Territorio` = var_terrPartenza OR `Territorio` = var_terrArrivo)
	INTO var_flag;
	
	IF var_flag <> 2 THEN
		SIGNAL SQLSTATE '45018' SET MESSAGE_TEXT = 'Si possono spostare carri armati solo tra territori che siano entrambi di proprietà del giocatore! Spostamento non disponibile.';
	END IF;
	
	-- controllo che i territori siano adiacenti
	SELECT COUNT(*) FROM `Adiacente`
	WHERE (`Territorio1` = var_terrPartenza AND `Territorio2` = var_terrArrivo) OR (`Territorio1` = var_terrArrivo AND `Territorio2` = var_terrPartenza)
	INTO var_flag;
	
	IF var_flag <> 1 THEN
		SIGNAL SQLSTATE '45019' SET MESSAGE_TEXT = 'Non è possibile spostare carri armati in un territorio non adiacente! Spostamento non disponibile.';
	END IF;
	
	-- controllo se è stato inserito un numero valido di territori da spostare
	SELECT `NumCarriPosizionati` FROM `IstanzaDiTerritorio`
	WHERE `Partita` = var_codicePartita AND `Territorio` = var_terrPartenza
	INTO var_numCarriPosizionati;
	
	IF var_numCarriDaSpost > var_numCarriPosizionati - 1 THEN
		SIGNAL SQLSTATE '45020' SET MESSAGE_TEXT = 'Non è possibile spostare più del numero di carri armati presenti nel territorio di partenza -1 : Spostamento non disponibile.';
	END IF;
	
	UPDATE `IstanzaDiTerritorio` SET `NumCarriPosizionati` = `NumCarriPosizionati` - var_numCarriDaSpost 
	WHERE `Partita` = var_codicePartita AND `Territorio` = var_terrPartenza;
	
	UPDATE `IstanzaDiTerritorio` SET `NumCarriPosizionati` = `NumCarriPosizionati` + var_numCarriDaSpost 
	WHERE `Partita` = var_codicePartita AND `Territorio` = var_terrArrivo;
	
	CALL segna_ultimo_turno_azione(var_gamerTag, var_codicePartita);
	
	CALL cambio_turno(var_codicePartita, var_gamerTag);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure attacca_territorio
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`attacca_territorio`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `attacca_territorio` (
IN var_giocatoreAtt VARCHAR(32),
IN var_numCarriAtt INT,
IN var_terrAtt VARCHAR(45),
IN var_terrDif VARCHAR(45),
OUT var_numCPersiAtt INT,
OUT var_numCPersiDif INT,
OUT var_conquistato INT,
OUT var_vittoriaPartita INT)
BEGIN
	declare var_codicePartita INT;
    declare var_flag INT;
    declare var_numCarriCheck INT;
    declare var_statoPartita ENUM('wait','exec','end');
    declare var_numCarriDif INT;
    declare var_numDadiAtt INT;
    declare var_numDadiDif INT;
	declare var_numCarriPersiAtt INT DEFAULT 0; 
	declare var_numCarriPersiDif INT DEFAULT 0;
    SET var_numCPersiAtt = 0;
    SET var_numCPersiDif = 0;
    SET var_conquistato = 0;
    SET var_vittoriaPartita = 0;

	SET var_codicePartita = recupera_partita(var_giocatoreAtt);
	CALL controlli_prima_di_azione(var_giocatoreAtt, var_codicePartita);
    CALL controllo_esistenza_territorio(var_terrAtt);
    CALL controllo_esistenza_territorio(var_terrDif);
	
	-- controllo che lo stato di attacco sia di proprietà del giocatore attaccante e che quello di difesa non lo sia
	SELECT COUNT(*) FROM `IstanzaDiTerritorio`
	WHERE `Partita` = var_codicePartita AND `Proprietario` = var_giocatoreAtt AND `Territorio` = var_terrAtt
	INTO var_flag;
	
	IF var_flag <> 1 THEN
		SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'Il territorio da cui parte l\'attacco non è di proprietà dell\'attaccante: Attacco non disponibile.';
	END IF;
	
	SELECT COUNT(*) FROM `IstanzaDiTerritorio`
	WHERE `Partita` = var_codicePartita AND `Proprietario` = var_giocatoreAtt AND `Territorio` = var_terrDif
	INTO var_flag;
	
	IF var_flag <> 0 THEN
		SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'Non è possibile attaccare territori di proprietà dell\'attaccante: Attacco non disponibile.';
	END IF;
	
	-- controllo che il numero di carri dichiarati sia presente (con scarto di un carro armato che deve rimanere per forza nel territorio)
	IF var_numCarriAtt > 3 OR var_numCarriAtt < 1 THEN
		SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'Non è possibile attaccare con un numero di carri armati che non sia compreso tra 1(verrà lanciato 1 dado) e 3(verranno lanciati tutti e 3 i dadi)';
	END IF;
	
	SELECT `NumCarriPosizionati` FROM `IstanzaDiTerritorio`
	WHERE `Partita` = var_codicePartita AND `Proprietario` = var_giocatoreAtt AND `Territorio` = var_terrAtt
	INTO var_numCarriCheck;
	
	IF var_numCarriAtt >= var_numCarriCheck THEN
		SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'Sul territorio deve essere presente almeno un carro armato in più di quelli schierati in attacco: Attacco non disponibile.';
	END IF;

	-- controllo adiacenza territori
	SELECT COUNT(*) FROM `Adiacente`
	WHERE (`Territorio1` = var_terrAtt AND `Territorio2` = var_terrDif) OR (`Territorio1` = var_terrDif AND `Territorio2` = var_terrAtt)
	INTO var_flag;
	
	IF var_flag <> 1 THEN
		SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = 'Non è possibile attaccare un territorio non adiacente: Attacco non disponibile.';
	END IF;
	
	-- calcolo numero dadi disponibili per attacco e difesa ed eseguo il lancio dei dadi
	SET var_numDadiAtt = var_numCarriAtt;
	
	SELECT `NumCarriPosizionati` FROM `IstanzaDiTerritorio`
	WHERE `Partita` = var_codicePartita AND `Territorio` = var_terrDif
	INTO var_numCarriCheck; -- numero di carri presenti sul territorio del giocatore che si difende
	
    -- in un contesto reale il difensore dovrebbe dichiarare con quanti carri si vuole difendere
    -- per semplicità in questo caso qual'ora ne disponga si difende con lo stesso numero di dadi dell'attaccante
    -- altrimenti si calcola il numero massimo di dadi possibile sulla base dei carri disponibili
	IF var_numCarriCheck >= var_numCarriAtt THEN 
		SET var_numDadiDif =  var_numDadiAtt; 			
	ELSE 
		SET var_numDadiDif = var_numCarriCheck;
	END IF;
	
	CALL risultato_lancio_dadi(var_numDadiAtt,var_numDadiDif,var_numCarriPersiAtt,var_numCarriPersiDif);
    SET var_numCPersiAtt = var_numCarriPersiAtt;
    SET var_numCPersiDif = var_numCarriPersiDif;
	
	IF var_numCarriPersiAtt <> 0 THEN
		UPDATE `IstanzaDiTerritorio` SET `NumCarriPosizionati` = `NumCarriPosizionati` - var_numCarriPersiAtt 
		WHERE `Partita` = var_codicePartita AND `Proprietario` = var_giocatoreAtt AND `Territorio` = var_terrAtt; 
	END IF;
	
	IF var_numCarriPersiDif <> 0 THEN
		UPDATE `IstanzaDiTerritorio` SET `NumCarriPosizionati` = `NumCarriPosizionati` - var_numCarriPersiDif
		WHERE `Partita` = var_codicePartita AND `Territorio` = var_terrDif;
		
		SELECT `NumCarriPosizionati` FROM `IstanzaDiTerritorio` 
		WHERE `Partita` = var_codicePartita AND `Territorio` = var_terrDif
		INTO var_numCarriCheck;
		
		IF var_numCarriCheck = 0 THEN
			UPDATE `IstanzaDiTerritorio` SET `NumCarriPosizionati` = `NumCarriPosizionati` - (var_numCarriAtt - var_numCarriPersiAtt) -- tolgo anche il resto dei carri schierati per riposizionarli sul nuovo territorio 
			WHERE `Partita` = var_codicePartita AND `Proprietario` = var_giocatoreAtt AND `Territorio` = var_terrAtt; 
			
			UPDATE `IstanzaDiTerritorio` SET `Proprietario` = var_giocatoreAtt, `NumCarriPosizionati` = var_numCarriAtt - var_numCarriPersiAtt 
			WHERE `Partita` = var_codicePartita AND `Territorio` = var_terrDif;
            
            SET var_conquistato = 1;
		END IF;
		
        -- se l'attaccante ha tutti i territori diventa il vincitore
		IF calcola_possedimenti(var_giocatoreAtt, var_codicePartita) = 42 THEN
			UPDATE `Partita` SET `Vincitore` = var_giocatoreAtt, `StatoPartita` = 'end' 
			WHERE `CodicePartita` = var_codicePartita;
            
            SET var_vittoriaPartita = 1;
		END IF;
	END IF;
	
	CALL segna_ultimo_turno_azione(var_giocatoreAtt, var_codicePartita);
	
	CALL cambio_turno(var_codicePartita, var_giocatoreAtt);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function calcola_possedimenti
-- -----------------------------------------------------

USE `risikoDB`;
DROP function IF EXISTS `risikoDB`.`calcola_possedimenti`;

DELIMITER $$
USE `risikoDB`$$
CREATE FUNCTION `calcola_possedimenti` (var_gamerTag VARCHAR(32),var_codicePartita INT) RETURNS INT READS SQL DATA
BEGIN
	declare var_numPossedimenti INT;
    
    SELECT COUNT(*) FROM `IstanzaDiTerritorio`
    WHERE `Partita` = var_codicePartita AND `Proprietario` = var_gamerTag
    INTO var_numPossedimenti;
    
    RETURN var_numPossedimenti;
    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure controlla_proprietario_turno
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`controlla_proprietario_turno`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `controlla_proprietario_turno` (
IN var_gamerTag VARCHAR(32),
IN var_codicePartita INT)
BEGIN
	declare var_gamerCheck VARCHAR(32);
    
	SELECT `Giocatore` FROM `Turno`
    WHERE `Partita` = var_codicePartita
    AND `Turno`.`StatoTurno` <> 'end'
    INTO var_gamerCheck;
    
    IF var_gamerTag <> var_gamerCheck THEN
		SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = 'Non è il turno del giocatore! Azione non disponibile.';
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ottieni_lista_stanze_disponibili
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`ottieni_lista_stanze_disponibili`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `ottieni_lista_stanze_disponibili` ()
BEGIN
	declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET TRANSACTION READ ONLY;
    START TRANSACTION;
		SELECT `NomeStanza`,`CodicePartita`,COUNT(`Giocatore`) AS `Partecipanti` FROM `StanzaDiGioco`
		JOIN `Partita` ON `Partita`.`Stanza` = `StanzaDiGioco`.`NomeStanza`
        LEFT JOIN `Partecipa` ON `Partita`.`CodicePartita` = `Partecipa`.`Partita`
        WHERE `StatoPartita` = 'wait'
        GROUP BY `CodicePartita`
        HAVING COUNT(`Giocatore`) < 6;
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure registra_nuovo_moderatore
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`registra_nuovo_moderatore`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `registra_nuovo_moderatore` (
IN var_username VARCHAR(32),
IN var_password VARCHAR(45))
BEGIN
	INSERT INTO `Utenti` (`Username`, `Password`, `Ruolo`)
		VALUES(var_username, SHA1(var_password), 'moderatore') ;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure controlli_prima_di_azione
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`controlli_prima_di_azione`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `controlli_prima_di_azione` (
IN var_gamerTag VARCHAR(32),
IN var_codicePartita INT)
BEGIN
	declare var_statoPartita ENUM('wait','exec','end');
    
    SET var_statoPartita = stato_partita(var_codicePartita);
    
    IF var_statoPartita <> 'exec' THEN
		IF var_statoPartita = 'wait' THEN
			SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = 'La partita non è ancora iniziata: Azione non disponibile';
		ELSE 
			SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = 'La partita è terminata.';
		END IF;
	END IF;
    
    CALL controlla_proprietario_turno(var_gamerTag, var_codicePartita);
    
    IF calcola_possedimenti(var_gamerTag, var_codicePartita) = 0 THEN
        SIGNAL SQLSTATE '45012' SET MESSAGE_TEXT = 'Non hai più possedimenti, attendi che un altro giocatore abbandoni o che la partita finisca';
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure segna_ultimo_turno_azione
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`segna_ultimo_turno_azione`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `segna_ultimo_turno_azione`(
IN var_gamerTag VARCHAR(32),
IN var_codicePartita INT)
BEGIN
	declare var_ultimoTurnoGiocatore INT;

	SELECT max(`idTurno`) FROM `Turno`
	WHERE `Partita` = var_codicePartita 
	AND `Giocatore` = var_gamerTag 
	INTO var_ultimoTurnoGiocatore;
	
	UPDATE `Turno` SET `StatoTurno` = 'action' 
	WHERE `idTurno` = var_ultimoTurnoGiocatore;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure salta_turno
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`salta_turno`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `salta_turno` (
IN var_gamerTag VARCHAR(32))
BEGIN
	declare var_codicePartita INT;
    declare var_statoPartita ENUM('wait','exec','end');
    
	SET var_codicePartita = recupera_partita(var_gamerTag);
    SET var_statoPartita = stato_partita(var_codicePartita);
    
    IF var_statoPartita <> 'exec' THEN
		IF var_statoPartita = 'wait' THEN
			SIGNAL SQLSTATE '45016' SET MESSAGE_TEXT = 'La partita non è ancora iniziata: Azione non disponibile';
		ELSE 
			SIGNAL SQLSTATE '45017' SET MESSAGE_TEXT = 'La partita è terminata.';
		END IF;
	END IF;
    
    CALL controlla_proprietario_turno(var_gamerTag, var_codicePartita);
    
    CALL cambio_turno(var_codicePartita, var_gamerTag);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure mostra_adiacenze_territorio
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`mostra_adiacenze_territorio`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `mostra_adiacenze_territorio` (
IN var_nomeTerritorio VARCHAR(45))
BEGIN
	declare exit handler for sqlexception 
    begin
        rollback; ## annullo la transazione
        resignal; ## segnalo al chiamante
    end;
    
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    START TRANSACTION ;
		
        CALL controllo_esistenza_territorio(var_nomeTerritorio);
        
		SELECT `Territorio1` AS `Territori Adiacenti` FROM `Adiacente` 
		WHERE `Territorio2` = var_nomeTerritorio
		UNION 
		SELECT `Territorio2` FROM `Adiacente` 
		WHERE `Territorio1` = var_nomeTerritorio;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure controllo_esistenza_territorio
-- -----------------------------------------------------

USE `risikoDB`;
DROP procedure IF EXISTS `risikoDB`.`controllo_esistenza_territorio`;

DELIMITER $$
USE `risikoDB`$$
CREATE PROCEDURE `controllo_esistenza_territorio` (
IN var_terr VARCHAR(45))
BEGIN
	IF var_terr NOT IN (SELECT `NomeTerritorio` FROM `Territorio`) THEN
			SIGNAL SQLSTATE '45013' SET MESSAGE_TEXT = 'Non esiste alcun territorio con questo nome.';
		END IF;
END$$

DELIMITER ;
USE `risikoDB`;

DELIMITER $$

USE `risikoDB`$$
DROP TRIGGER IF EXISTS `risikoDB`.`Check_PartitaIniziata` $$
USE `risikoDB`$$
CREATE DEFINER = CURRENT_USER TRIGGER `risikoDB`.`Check_PartitaIniziata` AFTER UPDATE ON `Partita` FOR EACH ROW
BEGIN
	declare var_primoGiocatore VARCHAR(32);
    
	IF NEW.`StatoPartita` = 'exec' THEN 
		CALL gioca_partita(OLD.`CodicePartita`);
        
		SELECT  `Giocatore` FROM  `Partecipa`
        WHERE `Partita` = OLD.`CodicePartita`
        AND `NumTurno` = 1
        INTO var_primoGiocatore;
        
        CALL inizia_turno(var_primoGiocatore, OLD.`CodicePartita`);
        
	END IF;
END$$


USE `risikoDB`$$
DROP TRIGGER IF EXISTS `risikoDB`.`Check_numeroTurnoValido` $$
USE `risikoDB`$$
CREATE DEFINER = CURRENT_USER TRIGGER `risikoDB`.`Check_numeroTurnoValido` BEFORE INSERT ON `Partecipa` FOR EACH ROW
BEGIN
	-- controllo se è già stato raggiunto il numero massimo di giocatori e se il numero di turno rispetta la regola aziendale
    IF NEW.`NumTurno` > 6 OR NEW.`NumTurno` < 1 THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il Giocatore non può essere ammesso.';
    END IF;
END$$


DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS login;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'login' IDENTIFIED BY 'Login@000';

GRANT EXECUTE ON procedure `risikoDB`.`login` TO 'login';
GRANT EXECUTE ON procedure `risikoDB`.`registra_nuovo_giocatore` TO 'login';
SET SQL_MODE = '';
DROP USER IF EXISTS moderatore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'moderatore' IDENTIFIED BY 'Moderatore@000';

GRANT EXECUTE ON procedure `risikoDB`.`report_moderatori` TO 'moderatore';
GRANT EXECUTE ON procedure `risikoDB`.`crea_nuova_stanza` TO 'moderatore';
GRANT EXECUTE ON procedure `risikoDB`.`registra_nuovo_moderatore` TO 'moderatore';
SET SQL_MODE = '';
DROP USER IF EXISTS giocatore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'giocatore' IDENTIFIED BY 'Giocatore@000';

GRANT EXECUTE ON procedure `risikoDB`.`aggiungi_partecipante` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`attacca_territorio` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`ottieni_lista_stanze_disponibili` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`posiziona_carriArmati_su_territorio` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`rimuovi_partecipante` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`sposta_carriArmati_tra_territori` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`vedi_stato_di_gioco` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`vedi_storico_partite` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`salta_turno` TO 'giocatore';
GRANT EXECUTE ON procedure `risikoDB`.`mostra_adiacenze_territorio` TO 'giocatore';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `risikoDB`.`Utenti`
-- -----------------------------------------------------
START TRANSACTION;
USE `risikoDB`;
INSERT INTO `risikoDB`.`Utenti` (`Username`, `Password`, `Ruolo`) VALUES ('Moderatore', '88fc268ab1dee02107c47cc0353ddf881c1a85d8', 'moderatore');
INSERT INTO `risikoDB`.`Utenti` (`Username`, `Password`, `Ruolo`) VALUES ('EdoMan000', '9025171ebffa5cbb4ce816a02e257aaa6a80e2e1', 'giocatore');
INSERT INTO `risikoDB`.`Utenti` (`Username`, `Password`, `Ruolo`) VALUES ('EdoMan001', '9025171ebffa5cbb4ce816a02e257aaa6a80e2e1', 'giocatore');
INSERT INTO `risikoDB`.`Utenti` (`Username`, `Password`, `Ruolo`) VALUES ('EdoMan002', '9025171ebffa5cbb4ce816a02e257aaa6a80e2e1', 'giocatore');
INSERT INTO `risikoDB`.`Utenti` (`Username`, `Password`, `Ruolo`) VALUES ('EdoMan003', '9025171ebffa5cbb4ce816a02e257aaa6a80e2e1', 'giocatore');

COMMIT;


-- -----------------------------------------------------
-- Data for table `risikoDB`.`Giocatore`
-- -----------------------------------------------------
START TRANSACTION;
USE `risikoDB`;
INSERT INTO `risikoDB`.`Giocatore` (`GamerTag`, `NumCarriDisponibili`, `TempoUltimaAzione`) VALUES ('EdoMan000', NULL, NULL);
INSERT INTO `risikoDB`.`Giocatore` (`GamerTag`, `NumCarriDisponibili`, `TempoUltimaAzione`) VALUES ('EdoMan001', NULL, NULL);
INSERT INTO `risikoDB`.`Giocatore` (`GamerTag`, `NumCarriDisponibili`, `TempoUltimaAzione`) VALUES ('EdoMan002', NULL, NULL);
INSERT INTO `risikoDB`.`Giocatore` (`GamerTag`, `NumCarriDisponibili`, `TempoUltimaAzione`) VALUES ('EdoMan003', NULL, NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `risikoDB`.`StanzaDiGioco`
-- -----------------------------------------------------
START TRANSACTION;
USE `risikoDB`;
INSERT INTO `risikoDB`.`StanzaDiGioco` (`NomeStanza`) VALUES ('StanzaDiProva1');
INSERT INTO `risikoDB`.`StanzaDiGioco` (`NomeStanza`) VALUES ('StanzaDiProva2');

COMMIT;


-- -----------------------------------------------------
-- Data for table `risikoDB`.`Partita`
-- -----------------------------------------------------
START TRANSACTION;
USE `risikoDB`;
INSERT INTO `risikoDB`.`Partita` (`CodicePartita`, `Stanza`, `StatoPartita`, `CountdownClock`, `Vincitore`) VALUES (1, 'StanzaDiProva1', 'wait', NULL, NULL);
INSERT INTO `risikoDB`.`Partita` (`CodicePartita`, `Stanza`, `StatoPartita`, `CountdownClock`, `Vincitore`) VALUES (2, 'StanzaDiProva2', 'wait', NULL, NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `risikoDB`.`Territorio`
-- -----------------------------------------------------
START TRANSACTION;
USE `risikoDB`;
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('ALASKA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('ALBERTA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('AMERICA CENTRALE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('STATI UNITI ORIENTALI');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('STATI UNITI OCCIDENTALI');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('GROENLANDIA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('TERRITORI DEL NORD OVEST');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('ONTARIO');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('QUEBEC');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('ARGENTINA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('BRASILE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('PERU');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('VENEZUELA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('GRAN BRETAGNA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('ISLANDA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('EUROPA SETTENTRIONALE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('EUROPA MERIDIONALE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('EUROPA OCCIDENTALE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('SCANDINAVIA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('UCRAINA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('CONGO');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('EGITTO');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('MADAGASCAR');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('AFRICA DEL NORD');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('AFRICA ORIENTALE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('AFRICA DEL SUD');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('AFGHANISTAN');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('INDIA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('CITA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('CINA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('GIAPPONE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('KAMCHATKA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('MEDIO ORIENTE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('MONGOLIA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('SIAM');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('SIBERIA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('URALI');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('JACUZIA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('INDONESIA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('NUOVA GUINEA');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('AUSTRALIA OCCIDENTALE');
INSERT INTO `risikoDB`.`Territorio` (`NomeTerritorio`) VALUES ('AUSTRALIA ORIENTALE');

COMMIT;


-- -----------------------------------------------------
-- Data for table `risikoDB`.`Adiacente`
-- -----------------------------------------------------
START TRANSACTION;
USE `risikoDB`;
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ARGENTINA', 'PERU');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ARGENTINA', 'BRASILE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('PERU', 'BRASILE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('PERU', 'VENEZUELA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('BRASILE', 'VENEZUELA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('BRASILE', 'AFRICA DEL NORD');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('VENEZUELA', 'AMERICA CENTRALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AMERICA CENTRALE', 'STATI UNITI OCCIDENTALI');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AMERICA CENTRALE', 'STATI UNITI ORIENTALI');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('STATI UNITI OCCIDENTALI', 'STATI UNITI ORIENTALI');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('STATI UNITI OCCIDENTALI', 'ALBERTA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('STATI UNITI OCCIDENTALI', 'ONTARIO');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('STATI UNITI ORIENTALI', 'ONTARIO');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('STATI UNITI ORIENTALI', 'QUEBEC');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ALBERTA', 'ONTARIO');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ALBERTA', 'TERRITORI DEL NORD OVEST');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ALBERTA', 'ALASKA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ONTARIO', 'QUEBEC');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ONTARIO', 'TERRITORI DEL NORD OVEST');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ONTARIO', 'GROENLANDIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('QUEBEC', 'GROENLANDIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('TERRITORI DEL NORD OVEST', 'ALASKA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('TERRITORI DEL NORD OVEST', 'GROENLANDIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ALASKA', 'KAMCHATKA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('GROENLANDIA', 'ISLANDA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ISLANDA', 'SCANDINAVIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('ISLANDA', 'GRAN BRETAGNA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('SCANDINAVIA', 'UCRAINA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('SCANDINAVIA', 'GRAN BRETAGNA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('SCANDINAVIA', 'EUROPA SETTENTRIONALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('GRAN BRETAGNA', 'EUROPA SETTENTRIONALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('GRAN BRETAGNA', 'EUROPA OCCIDENTALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('UCRAINA', 'EUROPA SETTENTRIONALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('UCRAINA', 'EUROPA MERIDIONALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('UCRAINA', 'AFGHANISTAN');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('UCRAINA', 'URALI');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('UCRAINA', 'MEDIO ORIENTE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('EUROPA SETTENTRIONALE', 'EUROPA OCCIDENTALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('EUROPA SETTENTRIONALE', 'EUROPA MERIDIONALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('EUROPA OCCIDENTALE', 'EUROPA MERIDIONALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('EUROPA OCCIDENTALE', 'AFRICA DEL NORD');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('EUROPA MERIDIONALE', 'EGITTO');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('EUROPA MERIDIONALE', 'MEDIO ORIENTE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('EUROPA MERIDIONALE', 'AFRICA DEL NORD');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('MEDIO ORIENTE', 'CINA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('MEDIO ORIENTE', 'EGITTO');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('MEDIO ORIENTE', 'INDIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('MEDIO ORIENTE', 'AFGHANISTAN');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AFGHANISTAN', 'URALI');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AFGHANISTAN', 'CINA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('URALI', 'CINA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('URALI', 'SIBERIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AFRICA DEL NORD', 'EGITTO');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AFRICA DEL NORD', 'CONGO');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AFRICA DEL NORD', 'AFRICA ORIENTALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('EGITTO', 'AFRICA ORIENTALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('CINA', 'INDIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('CINA', 'MONGOLIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('CINA', 'SIBERIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('CINA', 'SIAM');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('INDIA', 'SIAM');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('SIBERIA', 'MONGOLIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('SIBERIA', 'CITA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('SIBERIA', 'JACUZIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('CONGO', 'AFRICA ORIENTALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('CONGO', 'AFRICA DEL SUD');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AFRICA ORIENTALE', 'AFRICA DEL SUD');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AFRICA ORIENTALE', 'MADAGASCAR');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AFRICA DEL SUD', 'MADAGASCAR');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('MONGOLIA', 'CITA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('MONGOLIA', 'GIAPPONE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('MONGOLIA', 'KAMCHATKA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('KAMCHATKA', 'GIAPPONE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('KAMCHATKA', 'CITA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('SIAM', 'INDONESIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('CITA', 'JACUZIA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('INDONESIA', 'NUOVA GUINEA');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('INDONESIA', 'AUSTRALIA OCCIDENTALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('NUOVA GUINEA', 'AUSTRALIA OCCIDENTALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('NUOVA GUINEA', 'AUSTRALIA ORIENTALE');
INSERT INTO `risikoDB`.`Adiacente` (`Territorio1`, `Territorio2`) VALUES ('AUSTRALIA OCCIDENTALE', 'AUSTRALIA ORIENTALE');

COMMIT;

-- begin attached script 'implementazione_timer'
set global event_scheduler = ON;
DELIMITER //
CREATE EVENT IF NOT EXISTS `risikoDB`.`timer_inizio_partita` 
ON SCHEDULE EVERY 2 SECOND STARTS CURRENT_TIME ON COMPLETION PRESERVE 
COMMENT 'implementazione countdown inizio partita'
DO
BEGIN
	UPDATE `Partita` SET `StatoPartita` = 'exec' 
	WHERE `CountdownClock` < current_time() - INTERVAL 2 MINUTE -- sono passati 2 minuti
	AND `StatoPartita` = 'wait'; -- la partita era in stato di attesa
END//

DELIMITER //
CREATE EVENT IF NOT EXISTS `risikoDB`.`timer_cambio_turno` 
ON SCHEDULE EVERY 10 SECOND STARTS CURRENT_TIME ON COMPLETION PRESERVE 
COMMENT 'implementazione timer cambio turno'
DO
BEGIN
	declare var_gamerTag VARCHAR(32);
    declare var_codicePartita INT;
    declare var_statoTurno ENUM('noaction','action','end');
    
    SELECT `Partita`,`Giocatore`,`StatoTurno` FROM `Turno`
    WHERE `Timer` < current_time() - INTERVAL 3 MINUTE -- sono passati 3 minuti
    AND  `StatoTurno` <> 'end' -- il turno è attualmente in corso
    INTO var_codicePartita, var_gamerTag, var_statoTurno;
    
    IF var_statoTurno = 'noaction' THEN
		CALL cambio_turno(var_codicePartita, var_gamerTag);
	END IF;
    
END//

DELIMITER //
CREATE EVENT IF NOT EXISTS `risikoDB`.`riavvio_partita_automatico` 
ON SCHEDULE EVERY 30 SECOND STARTS CURRENT_TIME ON COMPLETION PRESERVE 
COMMENT 'implementazione riavvio partita in automatico'
DO
BEGIN
	declare done int default false;
    
	declare var_stato ENUM('wait','exec','end');
    declare var_stanza VARCHAR(45);
    
    declare cur_partite cursor for
    SELECT `StatoPartita`,`Stanza` 
	FROM `Partita` AS `P1`
	WHERE `CodicePartita` = (SELECT max(`CodicePartita`) 
						FROM `Partita` AS `P2` 
                        WHERE `P2`.`Stanza` = `P1`.`Stanza`);
    
    OPEN cur_partite;
    restart_loop: LOOP
		FETCH cur_partite INTO var_stato,var_stanza;
        IF var_stato = 'end' THEN 
			INSERT INTO `Partita` (`Stanza`) -- ricrea una nuova partita in quella stanza
			VALUES(var_stanza) ;
		END IF;
    END LOOP;
    CLOSE cur_partite;
END//
-- end attached script 'implementazione_timer'
