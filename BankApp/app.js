
/**
 * App for trying out database access from MySQL
 */
"use strict";

// Essentials
const express = require("express");
const path = require("path");
const bodyParser = require('body-parser');


// Load the routes
const database = require("./routes/database");

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
app.use("/", database);

// catch 404 and forward to error handler
app.use(function(req, res, next)
{
    var err = new Error("Not Found");
    err.status = 404;
    next(err);
});

// Export the app object for anyone wanting to use it
module.exports = app;
