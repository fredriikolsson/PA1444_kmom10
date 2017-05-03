CREATE DATABASE IF NOT EXISTS ib;

USE ib;

--
-- Ägareuppgifter
--
CREATE TABLE IF NOT EXISTS AccountHolder(
    id  INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    pin CHAR(4) NOT NULL,
    name VARCHAR (30),
    ssn INTEGER,
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

DROP TRIGGER IF EXISTS UpdateAccountLog;
DROP PROCEDURE IF EXISTS moveMoney;
DROP PROCEDURE IF EXISTS createAccountHolder;
DROP PROCEDURE IF EXISTS createBankAccount;
DROP PROCEDURE IF EXISTS login;

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

	START TRANSACTION;
    -- SET checkToAccount = (SELECT FIND_IN_SET(moverId, BankAccount.accountList) FROM BankAccount WHERE id = fromAccount);
	-- SET checkFromAccount = (SELECT FIND_IN_SET(moverId, BankAccount.accountList) FROM BankAccount WHERE id = toAccount);
    SET checkBalance = (SELECT balance FROM BankAccount WHERE id = fromAccount);
    SET spainMoney = amount * 0.03;

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
	-- ELSE
    -- ROLLBACK;
    -- SELECT ("Account holder does not have access to one of the accounts");
    -- END IF;

END //

CREATE PROCEDURE createAccountHolder (
	newPin CHAR(4),
    newName VARCHAR (30),
    newSsn INTEGER,
    newAdress VARCHAR(50),
    newCity VARCHAR(50)
)
BEGIN

	IF (SELECT id FROM AccountHolder WHERE ssn = newSsn) = NULL THEN
	INSERT INTO AccountHolder (name, ssn, adress, city, pin) VALUES(newName, newSsn, newAdres, newCity, newPin);
	ELSE
	SELECT ("Account holder already exists");
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
INSERT INTO InterestTable(`value`) VALUES(interestValue);
SET i = i + 1;

END WHILE;
COMMIT;
END //

DROP PROCEDURE IF EXISTS login //
CREATE PROCEDURE login(
    theSsn INTEGER,
    thePin CHAR(4)
)
BEGIN

DECLARE doesExists INTEGER;

SET doesExists = (SELECT id FROM AccountHolder WHERE ssn = theSsn AND
pin = thepin);

IF doesExists = NULL THEN
SELECT "Does not exists";
ELSE
SELECT doesExists;
END IF;
END;
//
DELIMITER ;


--
-- Create Sunny Spain account
--


CALL createBankAccount(10, "2,3,4");

INSERT INTO AccountHolder(pin, name, ssn, adress, city, accountList) 
VALUES ("1111", "Anders", 1337, "GednGatan 12", "ÖLLAND", "2,3");

CALL login(1337, "1111");


SELECT * FROM BankAccount;
INSERT INTO BankAccount(balance, holderList) VALUES (12000, "1,2");

SELECT balance, FIND_IN_SET(1, holderList) AS list, holderList FROM BankAccount, AccountHolder;
SELECT balance, holderList AS list FROM BankAccount, AccountHolder WHERE holderList LIKE '%1%';
SELECT balance, holderList  FROM BankAccount WHERE holderList LIKE '%1%';
