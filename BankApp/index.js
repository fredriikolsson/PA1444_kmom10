#!/usr/bin/env node
"use strict";

// Get the app
const app = require("./app");
const terminal = require("./terminal.js");
const database = require("./database.js");
const pid = require("./processID.js");
const port = require("./port.js");
const shutDown = require("./killServer.js");

// Check if LINUX_PORT is found otherwise set port to 1337
if (port.getPort() != -1)
{
    console.log(`LINUX_PORT is found and port is set to '${process.env.LINUX_PORT}'`);
    app.listen(port.getPort());
}
else
{
    console.log("LINUX_PORT is not found and port is set to 1337.");
    app.listen(1337);
}

//write pid to file
pid.writeToFile();

// Listen for shutdown
shutDown.listenForKillCommand();

//Get incoming terminal options and arguments
var optarg = terminal.checkOptionsArguments();

//initialize database
database.init(optarg);



console.log("Express is ready.");
