--
-- Create and use an own database for this example.
--
DROP DATABASE Allan;
CREATE DATABASE Allan;
USE Allan;



--
-- Allans products that he sells
--
DROP TABLE IF EXISTS a_product1;
CREATE TABLE a_product1 (
    `id` INTEGER PRIMARY KEY,
    `name` VARCHAR(20)
);

INSERT INTO a_product1
    VALUES
        (1, "Husqvarna"), (2, "Zündapp"), (3, "Puch Dakota"), (4, "Vespa");



--
-- Allans inventory, these products he has at home, ready to sell
--
DROP TABLE IF EXISTS a_inventory1;
CREATE TABLE a_inventory1 (
    `id` INTEGER PRIMARY KEY,
    `number` INTEGER
);

INSERT INTO a_inventory1
    VALUES
        (1, 5), (2, 2), (3, 3), (4, 0);



--
-- Allans central inventory, these products exists at the central inventory
-- and can be soled with some delivery time
--
DROP TABLE IF EXISTS a_inventory2;
CREATE TABLE a_inventory2 (
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `number` INTEGER
);

INSERT INTO a_inventory2
    VALUES
        (1, 4), (2, 0), (3, 2), (4, 5);

DROP FUNCTION IF EXISTS inventoryStatus;
DELIMITER //
CREATE FUNCTION inventoryStatus(LocalInventory INTEGER, CentralInventory INTEGER)
RETURNS VARCHAR(10)
    BEGIN
        IF (LocalInventory + CentralInventory) >= 5 THEN RETURN "Hälsosam";
        ELSE IF (LocalInventory + CentralInventory) >= 1 THEN RETURN "Beställ";
        ELSE IF (LocalInventory + CentralInventory) = 0 THEN RETURN "Slut!";
        END IF;
        END IF;
        RETURN "";
        END IF;
        END
//
DELIMITER ;

DROP PROCEDURE IF EXISTS updateInventory;
DELIMITER //
CREATE PROCEDURE updateInventory( whatID INTEGER, whatName VARCHAR(20), LocalInventory INTEGER, CentralInventory INTEGER)
BEGIN
	START TRANSACTION;

    UPDATE a_product1 SET name = whatName WHERE id = whatID;
    UPDATE a_inventory1 SET number = localInventory WHERE id = whatID;
    UPDATE a_inventory2 SET number = CentralInventory WHERE id = whatID;
    COMMIT;
END
//
DELIMITER ;

DROP PROCEDURE IF EXISTS moveFromLocalToCentralInventory;
DELIMITER //
CREATE PROCEDURE moveFromLocalToCentralInventory ( whatID INTEGER, nrOfItems INTEGER )
BEGIN
    DECLARE checkNrOfItems INTEGER;
    START TRANSACTION;
    SET checkNrOfItems = (SELECT number FROM a_inventory1 WHERE id = whatID );
    IF
        (checkNrOfItems - nrOfItems) <= 0 THEN ROLLBACK;
    ELSE
        UPDATE a_inventory1 SET number = (number - nrOfItems) WHERE (id = whatID);
        UPDATE a_inventory2 SET number = (number + nrOfItems) WHERE (id = whatID);
    END IF;
    COMMIT;
END
//
DELIMITER ;

DROP PROCEDURE IF EXISTS moveFromCentralToLocalInventory;
DELIMITER //
CREATE PROCEDURE moveFromCentralToLocalInventory ( whatID INTEGER, nrOfItems INTEGER )
BEGIN
    DECLARE checkNrOfItems INTEGER;
    START TRANSACTION;
    SET checkNrOfItems = (SELECT number FROM a_inventory2 WHERE id = whatID );
    IF
        (checkNrOfItems - nrOfItems) <= 0 THEN ROLLBACK;
    ELSE
        UPDATE a_inventory2 SET number = (number - nrOfItems) WHERE (id = whatID);
        UPDATE a_inventory1 SET number = (number + nrOfItems) WHERE (id = whatID);
    END IF;
    COMMIT;
END
//
DELIMITER ;



DROP TABLE IF EXISTS transferLog;
CREATE TABLE transferLog
(
    `totalNrOfTransfers` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `nrOfItemsTransfered` INTEGER,
    `itemsInStock` INTEGER,
    `id` INTEGER
);

DROP TRIGGER IF EXISTS updateLogForLocalInv;
CREATE TRIGGER updateLogForLocalInv
AFTER UPDATE ON a_inventory1
FOR EACH ROW INSERT INTO transferLog( `nrOfItemsTransfered`, `itemsInStock`, `id` )
        						      VALUES( (NEW.number - OLD.number), NEW.number, NEW.id );

DROP TRIGGER IF EXISTS updateLogForCentralInv;
CREATE TRIGGER updateLogForCentrallInv
AFTER UPDATE ON a_inventory2
FOR EACH ROW INSERT INTO transferLog( `nrOfItemsTransfered`, `itemsInStock`, `id` )
        						      VALUES( (NEW.number - OLD.number), NEW.number, NEW.id );
