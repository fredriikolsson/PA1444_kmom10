CREATE DATABASE IF NOT EXISTS ib;

USE ib;

DROP TABLE IF EXISTS AccountHolder;
DROP TABLE IF EXISTS BankAccount;
DROP TABLE IF EXISTS AccountLog;
DROP TABLE IF EXISTS Cashier;
DROP TABLE IF EXISTS InterestTable;

--
-- Cashier
--
CREATE TABLE Cashier(
    id INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    pin INT(4) NOT NULL
);
--
-- Ägareuppgifter
--
CREATE TABLE IF NOT EXISTS AccountHolder(
    id  INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    pin INTEGER(4) NOT NULL,
    name VARCHAR (30),
    ssn BIGINT UNIQUE,
    adress VARCHAR(50),
    city VARCHAR(50),
    accountList TEXT
    -- accountList = [2, 44, 9]
);

--
-- Kontouppgifter
--
CREATE TABLE IF NOT EXISTS BankAccount(
    id INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    balance INTEGER,
    holderList TEXT
);

--
-- Kontologg
--
CREATE TABLE IF NOT EXISTS AccountLog (
    id INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    timeWhen DATETIME DEFAULT CURRENT_TIMESTAMP,
    accountNumber INTEGER,
    balanceChanged INTEGER
 );
 
 CREATE TABLE InterestTable (
	interestId INT AUTO_INCREMENT PRIMARY KEY,
    value INT,
    dateFor DATETIME DEFAULT CURRENT_TIMESTAMP,
    accountNumber INT
 );

DROP TRIGGER IF EXISTS UpdateAccountLog;
DROP PROCEDURE IF EXISTS moveMoney;
DROP PROCEDURE IF EXISTS createAccountHolder;
DROP PROCEDURE IF EXISTS createBankAccount;
DROP PROCEDURE IF EXISTS calculateInterest;
DROP PROCEDURE IF EXISTS login;
DROP PROCEDURE IF EXISTS loginCashier;
DROP PROCEDURE IF EXISTS getName;
DROP PROCEDURE IF EXISTS getTheNames;
DROP PROCEDURE IF EXISTS filLDB;
DROP PROCEDURE IF EXISTS removeFromNFA;
DROP PROCEDURE IF EXISTS swish;
DROP FUNCTION IF EXISTS getNames;

DROP TABLE IF EXISTS namesFromAccount;

CREATE TABLE namesFromAccount(
	viewId INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(25),
	nameId INT
);

DELIMITER //

CREATE TRIGGER UpdateAccountLog
AFTER UPDATE ON BankAccount
FOR EACH ROW
BEGIN
	INSERT INTO AccountLog (accountNumber, balanceChanged)
    VALUES (OLD.id, NEW.balance - OLD.balance);
END //

CREATE PROCEDURE `moveMoney`(
	moverId INTEGER,
	fromAccount INTEGER,
    toAccount INTEGER,
    amount INTEGER
)
BEGIN

DECLARE checkBalance INTEGER;
DECLARE checkFromAccount INTEGER;
DECLARE checkToAccount INTEGER;
DECLARE spainMoney INTEGER;

DECLARE doesExists1 BOOLEAN;
DECLARE doesExists2 BOOLEAN;


	   

	START TRANSACTION;
    -- SET checkToAccount = (SELECT FIND_IN_SET(moverId, BankAccount.accountList) FROM BankAccount WHERE id = fromAccount);
	-- SET checkFromAccount = (SELECT FIND_IN_SET(moverId, BankAccount.accountList) FROM BankAccount WHERE id = toAccount);
    SET checkBalance = (SELECT balance FROM BankAccount WHERE id = fromAccount);
    SET spainMoney = amount * 0.03;
    SET doesExists1 = FALSE;
    SET doesExists2 = FALSE;
    SET @aHolderList = (SELECT accountList FROM AccountHolder WHERE id = moverId);
	SET @counter = 1;
    SET @accountExists = substring_index(substring_index(@aHolderList, ',', @counter), ',', -1);
    SET @lastId = 99999;

		WHILE @lastId != @accountExists AND doesExists1 = FALSE DO
			IF @accountExists = fromAccount THEN
            SET doesExists1 = TRUE;
            ELSE
			SET @lastId = @accountExists;
			SET @counter = @counter + 1;
			SET @accountExists = (SELECT substring_index(substring_index(@aHolderList, ',', @counter), ',', -1));
            END IF;
		END WHILE;
        
       	SET @counter = 1;
		SET @accountExists = substring_index(substring_index(@aHolderList, ',', @counter), ',', -1);
		SET @lastId = 99999;
 
        
		WHILE @lastId != @accountExists AND doesExists2 = FALSE DO
			IF @accountExists = toAccount THEN
            SET doesExists2 = TRUE;
            ELSE
			SET @lastId = @accountExists;
			SET @counter = @counter + 1;
			SET @accountExists = (SELECT substring_index(substring_index(@aHolderList, ',', @counter), ',', -1));
            END IF;
		END WHILE;
        
        IF doesExists1 = true AND doesExists2 = true THEN     

	
    -- IF checkFromAccount != 0 AND checkToAccount != 0 THEN
		IF checkBalance - amount < 0 THEN
		ROLLBACK;
		SELECT "To small balance";
		ELSE

		UPDATE BankAccount
		SET balance = balance + amount - spainMoney
		WHERE id = toAccount;

		UPDATE BankAccount
		SET balance = balance - amount
		WHERE id = fromAccount;

		UPDATE BankAccount
		SET balance = balance + spainMoney
		WHERE id = 1;

		COMMIT;

		END IF;
	 ELSE
     ROLLBACK;
     SELECT ("Account holder does not have access to one of the accounts");
     END IF;

END //

CREATE PROCEDURE createAccountHolder (
	newPin CHAR(4),
    newName VARCHAR (30),
    newSsn BIGINT,
    newAdress VARCHAR(50),
    newCity VARCHAR(50)
)
BEGIN
	SET @doesExists = (SELECT id FROM AccountHolder WHERE ssn = newSsn);
    SELECT @doesExists;
	IF @doesExists != NULL THEN
	SELECT ("Account holder already exists");
	ELSE
    INSERT INTO AccountHolder (name, ssn, adress, city, pin) VALUES(newName, newSsn, newAdress, newCity, newPin);
	END IF;
END //

CREATE PROCEDURE createBankAccount (
	accountBalance INTEGER,
    aHolderList TEXT
)
BEGIN

      DECLARE counter INTEGER;
      DECLARE lastId INTEGER;
      DECLARE currentId INTEGER;

	INSERT INTO BankAccount (balance, holderList) VALUES(accountBalance, aHolderList);
	-- Walk through the holderList, and for each ID, add this BankAccount ID to that AccountHolder accountsList
	-- USE WHILE AND SUBSTRING FUNCTIONS
	  SET counter = 1;
      SET currentId = substring_index(substring_index(aHolderList, ',', counter), ',', -1);
      SET lastId = 9999999;

      SELECT lastId, currentId;

	  WHILE lastId != currentId DO

      SELECT "Console.log för att testa värdena";
      SELECT currentId AS 'Current id', LAST_INSERT_ID() AS 'New id', (id = currentId) AS 'Är lika?' FROM AccountHolder;
      SELECT accountList FROM AccountHolder;
       SELECT "Test";
      UPDATE AccountHolder
		SET accountList = CONCAT(accountList, "," , LAST_INSERT_ID())
		WHERE id = currentId + 0;

 SELECT "Test";
		SET lastId = currentId;
		SET counter = counter + 1;
        SET currentId = (SELECT substring_index(substring_index(aHolderList, ',', counter), ',', -1));

	  END WHILE;

END //

CREATE PROCEDURE calculateInterest(
    `interestRate` DECIMAL
)

BEGIN
DECLARE accountValue INTEGER;
DECLARE interestValue INTEGER;
DECLARE nrOfElements INT DEFAULT 0;
DECLARE i INT DEFAULT 0;

START TRANSACTION;

SELECT COUNT(*) FROM BankAccount INTO nrOfElements;
SET i=1;
WHILE (i <= nrOfElements) DO
SELECT SUM(balance) into accountValue FROM BankAccount WHERE BankAccount.id = i;
SET interestValue = ((interestRate * accountValue) / 365);
SET @tempId = (SELECT BankAccount.id FROM BankAccount WHERE id = i);
INSERT INTO InterestTable(`value`, accountNumber) VALUES(interestValue, @tempId);
SET i = i + 1;

END WHILE;
COMMIT;
END //

-- CREATE PROCEDURE login(
--     theSsn INTEGER,
--     thePin CHAR(4)
-- )
-- BEGIN
--
-- DECLARE doesExists INTEGER;
--
-- SET doesExists = (CONCAT(`SELECT id FROM AccountHolder WHERE ssn = `,theSsn,` AND
-- pin = `,thepin,`;`));
--
-- IF doesExists = NULL THEN
-- SELECT "Does not exists";
-- Ele(`value`) VALUES(interestValue);
-- SET i = i + 1;
--
-- END WHILE;
-- COMMIT;
-- END //
--
-- CREATE PROCEDURE login(
--     theSsn INTEGER,
--     thePin CHAR(4)
-- )
-- BEGIN
--
-- DECLARE doesExists INTEGER;
--
-- SET doesExists = (CONCAT(`SELECT id FROM AccountHolder WHERE ssn = `,theSsn,` AND
-- pin = `,thepin,`;`));
--
-- IF doesExists = NULL THEN
-- SELECT "Does not exists";
-- le(`value`) VALUES(interestValue);
-- SET i = i + 1;
--
-- END WHILE;
-- COMMIT;
-- END //

CREATE PROCEDURE login(
    theSsn BIGINT,
    thePin INTEGER(4)
)
BEGIN

DECLARE doesExists INTEGER;

SET @anSsn = theSsn;
SET @aPin = thePin;
SET doesExists = (SELECT id FROM AccountHolder WHERE ssn = @anSsn AND
pin = @aPin);

IF doesExists = NULL THEN
SELECT "Does not exists";
ELSE
SELECT * FROM AccountHolder WHERE id = doesExists;
END IF;
END;
//

CREATE PROCEDURE loginCashier(
    theId INTEGER,
    thePin INT(4)
)
BEGIN

DECLARE doesExists INTEGER;

SET @anSsn = theId;
SET @aPin = thePin;
SET doesExists = (SELECT id FROM Cashier WHERE id = @anSsn AND
pin = @aPin);

IF doesExists = NULL THEN
SELECT "Does not exists";
ELSE
SELECT * FROM Cashier WHERE id = doesExists;
END IF;
END;
//

CREATE PROCEDURE fillDB()
BEGIN
    -- Sunny spain account --
    INSERT INTO BankAccount (id, balance, holderList) VALUES(1, 100000, 1);

    -- Insert all Users --
    INSERT INTO AccountHolder(name, ssn, adress, city, pin, accountList)
    VALUES
    ("DinaPengaÄrMinaPengar", 201705021456, "Nytt hus", "Nästan i Spanien", 1337, "1"),
    ("Marie Curie", 186711071337, "Radium road", "Warzawa", 1867, "2,12,13"),
    ("Max Karlson", 199612318456, "Annebovägen 2", "Karlskrona", 1111, "4"),
    ("Dennis Fransson", 199412158860, "Räddisogatan 93", "Skogsta", 8932,"9"),
    ("Anna Ullared", 196409085412, "Ullaredsstigen 54", "Ullared", 4321, "10,12"),
    ("Felicia Förödaren", 197402239999, "Mördarbo 43", "Hellabo", 1654, "5"),
    ("Viktor Tricksman", 200301016161, "Yllegatan 86", "Körskär", 6754, "8"),
    ("Inga-Britta Gunnarson", 183205311010, "Kyrkogårdsvägen 1", "Dödsbo", 9999, "12,3"),
    ("Greta Garbo", 190509181990, "Jungfrugatan 5", "Stockholm", 1999, "7,13,14"),
    ("Helena Von Nattuggla", 195405043434, "Bingebongevägen 19","Kitkatskogen", 4337, "6,14"),
    ("Balla Billy", 200001048982, "TuffaTågsrälsen 76", "CoolaKollektivet", 2604, "11,13,14");

    INSERT INTO BankAccount (balance, holderList)
    VALUES
    (1543, "2"),
    (12534, "8"),
    (134515, "3"),
    (65415, "6"),
    (6515, "10"),
    (8815, "9"),
    (515, "7"),
    (8315, "4"),
    (54152345, "5"),
    (96154325, "11"),
    (11154, "2,5,8"),
    (333, "2,9,11"),
    (15, "9,10,11");

END
//

--
-- CALL ON THIS EVERYTIME YOU CALL getName(accountId);
--
CREATE PROCEDURE removeFromNFA()
BEGIN
		TRUNCATE namesFromAccount;
END

//

CREATE PROCEDURE getTheNames(
    accountId INT
)
BEGIN
		
        DECLARE counter INT;
        DECLARE currentId INT;
        DECLARE lastId INT;
        DECLARE aHolderList TEXT;
		
        
        SET counter = 1;
		SET aHolderList = (SELECT holderList FROM BankAccount WHERE id = accountId);
        SET currentId = substring_index(substring_index(aHolderList, ',', counter), ',', -1);
        SET lastId = 9999999;


  	  WHILE lastId != currentId DO
        INSERT INTO namesFromAccount (name, nameId) VALUES((SELECT name FROM AccountHolder WHERE id = currentId), currentId);
  		SET lastId = currentId;
  		SET counter = counter + 1;
        SET currentId = (SELECT substring_index(substring_index(aHolderList, ',', counter), ',', -1));
  	  END WHILE;

      SELECT * FROM namesFromAccount;


END
//

CREATE PROCEDURE swish(
	userId BIGINT,
    userPin INT(4),
    fromAccount INT,
    toAccount INT,
    amount INT
)

BEGIN
-- DECLARE checkBalance INTEGER;
-- DECLARE checkFromAccount INTEGER;
-- DECLARE checkToAccount INTEGER;
DECLARE spainMoney INTEGER;
DECLARE doesExists BOOLEAN;

	START TRANSACTION;
    -- SET checkToAccount = (SELECT FIND_IN_SET(moverId, BankAccount.accountList) FROM BankAccount WHERE id = fromAccount);
	-- SET checkFromAccount = (SELECT FIND_IN_SET(moverId, BankAccount.accountList) FROM BankAccount WHERE id = toAccount);
    -- SET checkBalance = (SELECT balance FROM BankAccount WHERE id = fromAccount);
    SET doesExists = FALSE;
    SET spainMoney = amount * 0.02;
    SET @aHolderList = (SELECT accountList FROM AccountHolder WHERE id = userId);
	SET @counter = 1;
    SET @accountExists = substring_index(substring_index(@aHolderList, ',', @counter), ',', -1);
    SET @lastId = 99999;
    
    SET @correctPin = (SELECT pin FROM AccountHolder WHERE id = userId);
    
    IF userPin = @correctPin THEN 
		WHILE @lastId != @accountExists AND doesExists = FALSE DO
			IF @accountExists = fromAccount THEN
            SET doesExists = TRUE;
            ELSE
			SET @lastId = @accountExists;
			SET @counter = @counter + 1;
			SET @accountExists = (SELECT substring_index(substring_index(@aHolderList, ',', @counter), ',', -1));
            END IF;
		END WHILE;
        
        IF doesExists = true THEN        
		UPDATE BankAccount
		SET balance = balance + amount - spainMoney
		WHERE id = toAccount;

		UPDATE BankAccount
		SET balance = balance - amount
		WHERE id = fromAccount;

		UPDATE BankAccount
		SET balance = balance + spainMoney
		WHERE id = 1;
        
		COMMIT;
        
        ELSE
			ROLLBACK;
			SELECT ("Account holder does not have access to the account trying to SWISH from");
		END IF;
	ELSE 
		ROLLBACK;
        SELECT ("Wrong pin");
	END IF;
	-- END IF;
	-- ELSE
    -- ROLLBACK;
    -- SELECT ("Account holder does not have access to one of the accounts");
    -- END IF;
END;
// 

CREATE PROCEDURE getName(
	nameId INT
) 
BEGIN

CALL removeFromNFA();
CALL getTheNames(nameId);

END // 

-- CREATE PROCEDURE displayUserAccounts (
-- 	holderId INTEGER
-- )
-- BEGIN
-- 	SET @exists = false;
-- 	SET @counter = 1;
--     SET @anAccountList = (SELECT accountList FROM AccountHolder WHERE id = holderId);
--     SET @accountExists = substring_index(substring_index(@anAccountList, ',', @counter), ',', -1);
--     SET @lastId = 99999;
-- 		DROP TABLE IF EXISTS v;
--         CREATE TABLE v AS SELECT qty, price, qty*price AS value FROM t;
-- 		WHILE @lastId != @accountExists AND doesExists = FALSE DO
-- 			IF @accountExists = holderI THEN
--             SET doesExists = TRUE;
--             ELSE
-- 			SET @lastId = @accountExists;
-- 			SET @counter = @counter + 1;
-- 			SET @accountExists = (SELECT substring_index(substring_index(@aHolderList, ',', @counter), ',', -1));
--             END IF;
-- 		END WHILE;
-- 
-- 
-- SELECT id, balance, holderList FROM BankAccount 
-- LEFT OUTER JOIN interestTable.value ON interestTable.id LIKE ;
-- 
-- END //

-- CREATE Function getNames(
-- 	nameId INT
-- ) 
-- RETURNS VARCHAR(20)
-- BEGIN
-- 
-- CALL removeFromNFA();
-- CALL getTheNames(nameId);
-- RETURN (SELECT name FROM namesFromAccount WHERE id = 1);
-- 
-- END // 

DELIMITER ;


--
-- Create Sunny Spain account
--

-- SELECT * FROM AccountHolder;
-- CALL createBankAccount(10, "2,3,4");
-- SELECT * FROM BankAccount;
-- SELECT LAST_INSERT_ID();
-- SELECT * FROM AccountHolder;

-- CALL login(1337, "1111");

CALL fillDB();
CALL CalculateInterest(2);
CALL createAccountHolder(1111, "HejPåDig", 1997, "Där" , "Här");
INSERT INTO Cashier(id, pin) VALUES(1, 1111);
INSERT INTO Cashier(id, pin) VALUES(2, 2222);


