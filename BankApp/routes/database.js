"use strict";

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

    data.sql = `SELECT id FROM AccountHolder WHERE pin = ? AND ssn = ? ;`;
    data.param = [req.params.pin, req.params.ssn];

    database.queryPromise(data.sql, data.param)
        .then(() => {
            res.redirect(`/user/${req.body.id}`);
        })
        .catch((err) => {
            throw err;
        });
});

router.get("/createaccount", (req, res) => {
    res.render("createaccount", {
        title: "login route | express",
        message: ""
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

    // res.render("log", {
    //     title: "Log route | express",
    //     message: "$CashMoney$ Internetbank"
    // });
});



router.get("/cashier", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `

    SELECT * FROM AccountLog;`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            if (result.length) {
                data.object = {
                    // SOME DATA
                };
            }
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

    SELECT * FROM a_product1

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

    data.title = "SOME TITLE";

    data.sql = `

    SELECT * FROM BankAccount


    ;`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
        .then((result) => {
            if (result.length) {
                data.object = {
                    ssn: result[0].ssn,
                    accountList: result[0].accountList,
                    city: result[0].city,
                    adress: result[0].adress,
                    name: result[0].name,

                };

            }
            res.render("user", data);
        })
        .catch((err) => {
            throw err;
        });
});

router.get("/swish", (req, res) => {
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `

    SELECT * FROM a_product1


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

router.get("/owners", (req, res) => {
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
                    text: result[0].text,
                };
            }
            res.render("owners", data);
        })
        .catch((err) => {
            throw err;
        });
});



router.post("/xxx", (req, res) => {
    var data = {};

    data.sql = `SELECT * FROM a_product1;`;
    console.log(req.body);
    data.param = ["PARAMETERS"];

    database.queryPromise(data.sql, data.param)
        .then(() => {
            res.redirect(`/owners/${req.body.id}`);
        })
        .catch((err) => {
            throw err;
        });
});


module.exports = router;
