"use strict";
// Hej
// på dig

// Hej

//med mig
const express = require("express");
const router = express.Router();
const database = require("../database");


router.get("/", (req, res) => {
    res.render("index", {
        title: "Index route | express",
        message: "$CashMoney$ Internetbank"
    });
});


router.get("/login", (req, res) => {
    res.render(`login`, {
        title: "Login",
        messsage: "$CashMoney$ Internetbank"

    });
});
router.post("/loginAUTH", (req, res) => {
    var data = {};
    data.sql = `CALL login(?, ?);`;
    data.param = [req.body.ssn, req.body.pin];
    database.queryPromise(data.sql, data.param)
        .then((result) => {
            let theResult = result.shift();
            data.object = {
                "id": theResult[0].id
            };
            console.log(data.object.id);
            res.redirect(`/user/${data.object.id}`);
            console.log("Passed redirect");
        })
        .catch((err) => {
            throw err;
        });
});

router.get("/loginCashier", (req, res) => {
    res.render(`loginCashier`, {
        title: "LoginCashier",
    });
});
router.post("/loginAUTHCashier", (req, res) => {
    var data = {};
    data.sql = `CALL loginCashier(?, ?);`;
    data.param = [req.body.id, req.body.pin];
    database.queryPromise(data.sql, data.param).then((result) => {
        let theResult = result.shift();
        data.object = {
            "id": theResult[0].id
        };
        res.redirect(`/cashier`);
    }).catch((err) => {
        throw err;
    });
});

router.post("/createAccount", (req, res) => {
    var data = {};

    data.sql = `SELECT * FROM AccountHolder
    WHERE id = ?;`;

    data.param = [req.body.newAccount, req.body.id];

    database.queryPromise(data.sql, data.param)
        .then(() => {
            res.redirect(`/user/${req.body.id}`);
        })
        .catch((err) => {
            throw err;
        });
});

router.get("/createaccount/:id", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";
    data.sql = `CALL createBankAccount(0,?);`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            let theResult = result.shift();
            data.resultset = theResult;
            console.log(data);
            res.render("createaccount", data);
        })
        .catch((err) => {
            throw err;
        });
});

router.post("/redirectUser", (req, res) => {
    var data = {};
    data.sql = `SELECT * FROM AccountHolder
    WHERE id = ?`;

    data.param = [req.body.accountId];

    res.redirect(`/user/${data.param}`);
});

router.get("/cashierCreateAccount", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    //data.sql = `CALL createBankAccount(0,"");`;


    res.render("cashierCreateAccount", data);
});

router.post("/redirectCashier", (req, res) => {
    var data = {};
    data.sql = `CALL createBankAccount(0,"");`;

    database.queryPromise(data.sql, data.param)
        .then(() => {
            res.redirect(`/cashier`);
        })
        .catch((err) => {
            throw err;
        });
});


router.post("/create", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `CALL createAccountHolder(?,?,?,?,?);`;

    data.param = [req.body.newPin, req.body.newName,
        req.body.newSsn, req.body.newAdress, req.body.newCity
    ];
    database.queryPromise(data.sql, data.param)
        .then(() => {
            res.redirect(`/createholder`);
        })
        .catch((err) => {
            throw err;
        });
});

router.get("/createholder", (req, res) => {
    var data = {};
    data.sql = `SELECT * FROM AccountHolder;`;

    database.queryPromise(data.sql)
        .then(() => {
            res.render("createholder", data);
        })
        .catch((err) => {
            throw err;
        });
});

router.post("/updateAccount", (req, res) => {
    var data = {};

    data.sql = `
    UPDATE BankAccount
    SET
    holderList = CONCAT(holderList, ',',?)
    WHERE id = ?;`;

    console.log(req.body);
    data.param = [req.body.newAccount, req.body.id];

    database.queryPromise(data.sql, data.param)
        .then(() => {
            res.redirect(`/owners/${req.body.id}`);
        })
        .catch((err) => {
            throw err;
        });
});

router.get("/owners/:id", (req, res) => {
    var data = {};
    data.sql = `CALL getName(?);`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            let theResult = result.shift();
            data.resultset = theResult;
            console.log(data);
            res.render("owner", data);
        })
        .catch((err) => {
            throw err;
        });
});

router.get("/log", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `SELECT * FROM AccountLog;`;

    database.queryPromise(data.sql)
        .then((result) => {
            data.resultset = result;
            res.render("log", data);
        })
        .catch((err) => {
            throw err;
        });
});



router.get("/cashier", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `
    SELECT * FROM BankAccount;`;

    database.queryPromise(data.sql)
        .then((result) => {
            data.resultset = result;
            res.render("cashier", data);
        })
        .catch((err) => {
            throw err;
        });
});



router.get("/createholder", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `
    SELECT * FROM AccountHolder;
    ;`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            if (result.length) {
                data.object = {
                    // SOME DATA
                };
            }
            res.render("createholder", data);
        })
        .catch((err) => {
            throw err;
        });
});
router.get("/user/:id", (req, res) => {
    var data = {};
    var data2 = {};
    data.title = "SOME TITLE";

    data.sql = `SELECT id, ssn, accountList, city, adress, name FROM AccountHolder WHERE id = ?;`;

    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            if (result.length) {
                data.object = {
                    id: result[0].id,
                    ssn: result[0].ssn,
                    accountList: result[0].accountList,
                    city: result[0].city,
                    adress: result[0].adress,
                    name: result[0].name,

                };
            }
            data2.sql = `SELECT id, balance, holderList FROM BankAccount WHERE holderList LIKE ` + `'%${req.params.id}%'` + `;`;
            database.queryPromise(data2.sql, data2.param)
                .then((result2) => {
                    if (result2.length) {
                        data.accounts = result2;
                    }

                    res.render("user", data);
                })
                .catch((err) => {
                    throw err;
                });

        })
        .catch((err) => {
            throw err;
        });
});



router.get("/swish", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `
    SELECT * FROM BankAccount
    ;`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            if (result.length) {
                data.object = {
                    localNumber: result[0].localNumber,
                    number: result[0].number,
                    id: result[0].id,
                    text: result[0].text
                };
            }
            res.render("swish", data);
        })
        .catch((err) => {
            throw err;
        });
});

router.post("/swishing", (req, res) => {
    var data = {};
    data.sql = `CALL swish(?, ?, ?, ?, ?);`;
    data.param = [req.body.fromId, req.body.pin, req.body.from, req.body.to, req.body.amount];
    console.log(data.param);
    database.queryPromise(data.sql, data.param)
        .then((result) => {
            console.log("Starting swish");
            res.redirect(`/swish`);
            console.log(result);
        })
        .catch((err) => {
            throw err;
        });
});

router.post("/owners", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `SELECT * FROM BankAccount;`;

    data.param = [req.body.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            if (result.length) {
                res.redirect(`/owners/${req.body.id}`);
            }
            res.render("owner", data);
        })
        .catch((err) => {
            throw err;
        });
});

router.get("/owners/:id", (req, res) => {
    var data = {};

    data.sql = `CALL getName(?);`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            let theResult = result.shift();
            data.resultset = theResult;
            res.render("owner", data);
        })
        .catch((err) => {
            throw err;
        });
});
 
router.post("/transferAUTH/", (req, res) => {
    var data = {};
    data.sql = `CALL moveMoney(?, ?, ?, ?)`;
    data.param = [req.body.id, req.body.from, req.body.to, req.body.ammount];
    database.queryPromise(data.sql, data.param)
        .then((result) => {
            console.log(result);
            var transferStatus = "Ammount: " + req.body.ammount + " sent to Account " + req.body.to;
            res.redirect(`/transfer/${req.body.id}`);
        })
        .catch((err) => {
            throw err;
        });
});
router.get("/transfer/:id", (req, res) => {
    var data = {};
    var transferStatus;
    data.sql = `SELECT id, balance, holderList FROM BankAccount WHERE holderList LIKE ` + `'%${req.params.id}%'` + `;`;
    data.param = [req.params.id];
    data.owner = req.params.id;
    database.queryPromise(data.sql, data.param)
        .then((result) => {
            if (transferStatus !== null) {
                data.aMessage = transferStatus;
            }
            data.accounts = result;
            console.log(data.aMessage);
            res.render("transfer", data);
        })
        .catch((err) => {
            throw err;
        });
});

module.exports = router;
