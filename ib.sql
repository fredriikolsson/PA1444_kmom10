CREATE DATABASE IF NOT EXISTS ib;

USE ib;

CREATE TABLE IF NOT EXISTS AccountHolder(
    id  INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    accountManagers TEXT
);


CREATE TABLE IF NOT EXISTS Manager (
    id INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    accountId INTEGER,
    accountHolders TEXT

);

CREATE TABLE IF NOT EXISTS Account(
    id INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
    balance INTEGER
);

SELECT * FROM AccountHolder;

-- INSERT INTO Manager (id, accountId, accountHolders) VALUES(2 ,(SELECT id FROM Account WHERE id = 2), "1, 2");

SELECT * FROM Account;
SELECT * FROM Manager;


SELECT * FROM AccountHolder;

UPDATE AccountHolder
SET accountManagers = (SELECT id FROM Manager
WHERE  FIND_IN_SET(accountHolders, (SELECT id FROM AccountHolder)));

SELECT * FROM Manager;
SELECT * FROM AccountHolder;
