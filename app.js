'use strict';

// Essentials
const express = require("express");
const path = require("path");
const bodyParser = require('body-parser');

const app = express();


// view engine setup without minification of HTML
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "pug");
app.locals.pretty = true;

// Parsing application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: true }));

// Mount static resources
app.use(express.static(path.join(__dirname, "public")));

// Load all routes on their mountpoint

// app.use("/", index);
// app.use("/db", database);


// database.connectionPromise(host, user, pass, db).then((value) => {})
//     console.log("Connected to DB with arguments ");
// };

// catch 404 and forward to error handler
app.use(function(req, res, next) {
    var err = new Error("Not Found");
    err.status = 404;
    next(err);
});

module.exports = app;
