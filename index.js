#!/usr/bin/env node

"use strict";

var args = process.argv.slice(2);

const fs = require("fs");
var sql = fs.readFileSync("./allan1.sql", "utf8");
const path = require("path");
const database = require("./database.js");

// Get the app
const app = require("./app");

var data = {};
database.queryPromise(sql).then((result) => {
    data.resultset = result;
    result.render("database", data);
});

var remaining = [];
args.forEach((args) => {
    switch (args) {
        case "--host":
            console.log("Creating db with args from index.js");
            app.connectDatabase(args[1], args[3], args[5], args[7]);
            break;
        case "-v":
        case "--version":
            console.log("Version 1.0.0");
            break;
        default:
            remaining.push(args);
            break;
    }
});

// Start up server

//app.connectDatabase("", "", "", "");
console.log("Express is ready.");

// Start the server to listen on a port
if ('LINUX_PORT' in process.env) {
    console.log(`LINUX_PORT is set to '${process.env.LINUX_PORT}'`);
    app.listen(process.env.LINUX_PORT);
    console.log(`Simple server listen on port '${process.env.LINUX_PORT}'`);
} else {
    console.log("LINUX_PORT is not set.");
    app.listen(1337);
    console.log("Simple server listen on port 1337");
}

// Write pid to file
var pidFile = path.join(__dirname, "pid");
fs.writeFile(pidFile, process.pid, function(err) {
    if (err) {
        return console.log(err);
    }

    console.log("Wrote process id to file 'pid'");
});

console.log("This servers has pid " + process.pid);
