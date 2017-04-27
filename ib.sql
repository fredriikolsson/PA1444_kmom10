CREATE DATABASE IF NOT EXISTS ib;

USE ib;

--
-- Ägareuppgifter
--
CREATE TABLE IF NOT EXISTS AccountHolder(
    id  INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    accountList TEXT
    -- accountList = [2, 44, 9]
);

--
-- Kontouppgifter
--
CREATE TABLE IF NOT EXISTS BankAccount(
    id INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    balance INTEGER
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

DELIMITER //

CREATE TRIGGER UpdateAccountLog
AFTER UPDATE ON BankAccount
FOR EACH ROW
BEGIN
	INSERT INTO UpdateAccountLog (accountNumber, balanceChanged) 
    VALUES (OLD.id, NEW.balance - OLD.balance);
END //

CREATE PROCEDURE `moveMoney`(
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
    -- SET checkToAccount = (SELECT accountList FROM AccountHolder WHERE FIND_IN_SET(toAccount, accountList) != 0);
	-- SET checkFromAccount = (SELECT accountList FROM AccountHolder WHERE FIND_IN_SET(fromAccount, accountList) != 0);
    SET checkBalance = (SELECT balance FROM BankAccount WHERE id = fromAccount);
    SET spainMoney = amount * 0.03;
    
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

END //

DELIMITER ;

-- UPDATE AccountHolder	
-- SET accountList = "2, 34, 3, 23, 54"
-- WHERE id = 1;


--
-- Create Sunny Spain account
--

INSERT IGNORE INTO BankAccounts VALUES(1, 0);

SELECT FIND_IN_SET(2, accountList) FROM AccountHolder ;