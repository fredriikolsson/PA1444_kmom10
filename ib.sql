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

DELIMITER //

CREATE TRIGGER UpdateAccountLog
AFTER UPDATE ON BankAccount
FOR EACH ROW
BEGIN
	INSERT INTO UpdateAccountLog (accountNumber, balanceChanged) 
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
    SET checkToAccount = (SELECT FIND_IN_SET(moverId, accountList) FROM BankAccount WHERE id = fromAccount);
	SET checkFromAccount = (SELECT FIND_IN_SET(moverId, accountList) FROM BankAccount WHERE id = toAccount);
    SET checkBalance = (SELECT balance FROM BankAccount WHERE id = fromAccount);
    SET spainMoney = amount * 0.03;
    
    IF checkFromAccount != 0 AND checkToAccount != 0 THEN
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

	INSERT INTO BankAccount (balance, holderList) VALUES(accountBalance, aHolderList);
	-- Walk through the holderList, and for each ID, add this BankAccount ID to that AccountHolder accountsList
	-- USE WHILE AND SUBSTRING FUNCTIONS 
	
END //

DELIMITER ;

--
-- Create Sunny Spain account
--

-- INSERT IGNORE INTO BankAccounts VALUES(1, 0);

SELECT FIND_IN_SET(2, accountList) FROM AccountHolder ;