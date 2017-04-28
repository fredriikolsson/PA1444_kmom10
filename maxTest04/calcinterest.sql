-- Calculating interest
--
-- The calculation of interest is done on a daily basis. It is performed manually
-- by executing a stored procedure that calculates the interest for each account.
-- The procedure takes the following arguments; interestRate, dateOfCalculationDay.
--  The interest is calculated by interestRate * balance / 365.
--
-- The result shall be stored in a separate table with the values of the calculated
--  interest, date for calculation, and account number. The accumulated interest
--   for a specific account can be calculated by summing all entries, for the specific account, in this table.

-- >> CREATING DATABASE << --

DROP DATABASE myDB;

CREATE DATABASE myDB;
USE myDB;



-- >> CREATING TABLE BankAccount << --

DROP TABLE IF EXISTS BankAccount;
CREATE TABLE BankAccount(
    `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
    `balance` INTEGER
);

-- >> CREATING TABLE InterestTable << --

DROP TABLE IF EXISTS InterestTable;
CREATE TABLE InterestTable(
`id` INTEGER PRIMARY KEY AUTO_INCREMENT,
`timeStamp` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
`value` DECIMAL
);


-- >> PROCEDURE TO CALCULATE INTEREST << --
DELIMITER //

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
DELIMITER ;

-->> Accumulated Calculation << --


-- >> INSERTING VALUES ETC << --
INSERT INTO BankAccount(`balance`) VALUES(20000);
INSERT INTO BankAccount(`balance`) VALUES(25000);
INSERT INTO BankAccount(`balance`) VALUES(28000);

CALL calculateInterest(1.1);




SELECT * FROM BankAccount;
SELECT * FROM InterestTable;
