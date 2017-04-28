
/**
 * Listen on SIGINT, SIGTERM
 */
"use strict";

var shutDown = {};

shutDown.listenForKillCommand = () =>
{
    const path = require("path");
    const fs = require("fs");

    function controlledShutdown(signal)
    {
        console.warn(`Caught ${signal}. Removing pid-file and will then exit.`);
        fs.unlinkSync(path.join(__dirname, "pid"));
        process.exit();
    }

    // Handle WIN32 signals in a specific mode
    if (process.platform === "win32")
    {
        var rl = require("readline").createInterface(
        {
            input: process.stdin,
            output: process.stdout
        });

        rl.on("SIGINT", function ()
        {
            process.emit("SIGINT");
        });
    }


    // Add event handlers for signals
    process.on("SIGTERM", () => { controlledShutdown("SIGTERM"); });
    process.on("SIGINT", () => { controlledShutdown("SIGINT"); });
};

module.exports = shutDown;
