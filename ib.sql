CREATE DATABASE IF NOT EXISTS ib;

USE DATABASE ib;

CREATE TABLE IF NOT EXISTS AccountHolder(
    INTEGER id PRIMARY KEY,
    TEXT accountManagers,
    FOREIGN KEY (accountManagers) REFERENCES (Manager.id)
);

INSERT INTO AccountHolder VALUES(1);
INSERT INTO AccountHolder VALUES(2);
INSERT INTO AccountHolder VALUES(3);




CREATE TABLE IF NOT EXISTS Manager(
    INTEGER id PRIMARY KEY,
    INTEGER accountId,
    TEXT accountHolders,
    FOREIGN KEY(accountId) REFERENCES (Account.id),
    FOREIGN KEY(accountHolders) REFERENCES (AccountHolder.id)
);

CREATE TABLE IF NOT EXISTS Account(
    INTEGER id PRIMARY KEY,
    INTEGER balance
);
