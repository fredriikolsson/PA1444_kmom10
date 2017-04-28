"use strict";

const express = require("express");
const router = express.Router();
const database = require("../database");


router.get("/", (req, res) =>
{
    res.render("index",
    {
        title: "Index route | express",
        message: "$CashMoney$ Internetbank"
    });
});





router.get("/SOME ROUTE", (req, res) =>
{
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `SQL FOR SOMETHING;`;

    database.queryPromise(data.sql)
    .then((result) =>
    {
        data.resultset = result;
        res.render("SOME ROUTE", data);
    })
    .catch((err) =>
    {
        throw err;
    });
});



router.get("/SOME ROUTE", (req, res) =>
{
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `SQL FOR SOMETHING;`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
    .then((result) =>
    {
        if (result.length)
        {
            data.object =
            {
                // SOME DATA
            };
        }
        res.render("SOME ROUTE", data);
    })
    .catch((err) =>
    {
        throw err;
    });
});


router.get("/SOME ROUTE", (req, res) =>
{
    var data = {};

    data.title = "SOME TITLE";

    data.sql = `SQL FOR SOMETHING;`;
    data.param = [req.params.id];

    database.queryPromise(data.sql, data.param)
    .then((result) =>
    {
        if (result.length)
        {
            data.object =
            {
                // SOME DATA
            };
        }
        res.render("SOME ROUTE", data);
    })
    .catch((err) =>
    {
        throw err;
    });
});



router.post("/SOME EDITING ROUTE", (req, res) =>
{
    var data = {};

    data.sql = `CALL SOME PROCEDURE/FUNCTION`;
    console.log(req.body);
    data.param = ["PARAMETERS"];

    database.queryPromise(data.sql, data.param)
    .then(() =>
    {
        res.redirect(`/SOME EDITING ROUTE/${req.body.id}`);
    })
    .catch((err) =>
    {
        throw err;
    });
});


module.exports = router;
