"use strict";

const path = require("path");
const fs = require("fs");
var pid = {};
// Write pid to file
pid.writeToFile = () => {
    var pidFile = path.join(__dirname, "pid");
    fs.writeFile(pidFile, process.pid, function(err) {
        if (err) {
            return console.log(err);
        }

        console.log("Wrote process id to file 'pid'");
    });

};

module.exports = pid;
