"use strict";
const VERSION = "1.0.0";
const path = require("path");



// Module to export
var terminal = {};


var helptext = () =>
{
    var scriptName = path.basename(process.argv[1]);

    console.log(`Connect to a database: ${scriptName} [hostname] [username] [password] [database]
Replace the [] with your info

Options:
 -h, --help       Display help text.
 -v, --version    Display the version.
 --prompt string  Use string as prompt.
`);
};


var unknownOption = (option) =>
{
    console.log(`Unknown option: ${option}
Use --help to get an overview of the commands.`);
};

var version = () =>
{
    console.log(VERSION);
};




// Check incoming options.

terminal.checkOptionsArguments = () =>
{
    var args = process.argv.slice(2);
    var opts = {};
    var remaining = [];

    args.forEach((arg, index, array) =>
    {
        switch (arg) {
            case "-h":
            case "--help":
                helptext();
                process.exit(0);
                break;

            case "-v":
            case "--version":
                version();
                process.exit(0);
                break;

            case "--prompt":
                opts.prompt = array[index + 1];
                delete array[index + 1];
                break;

            default:
                if (arg.startsWith("-")) {
                    unknownOption(arg);
                    process.exit(1);
                }

                remaining.push(arg);
                break;
        }
    });

    return {
        opts: opts,
        args: remaining
    };
};



// Export module
module.exports = terminal;
