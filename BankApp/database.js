"use strict";
const database = {};
const mysql = require("mysql");
var connection;
database.init = (optarg) => {
    var args = optarg.args;

    console.log("Initializing with options/arguments:");
    console.log(optarg);


    connection = mysql.createConnection({
        host: args[0],
        user: args[1],
        password: args[2],
        database: args[3],
        multipleStatements: true
    });

    connection.connect(function(error) {
        if (error) {
            throw error;
        }
    });
    connection.query("Use " + args[3], function(error) {
        if (error) {
            throw error;
        }
    });

    console.log(`Connecting to host:${args[0]}, database:${args[3]}.`);

};

/**
 * Doing a MySQL query within a Promise.
 *
 * @param  string sql   SQL to be queried.
 * @param  Array  param Parameters to match placeholders
 *
 * @return object with result from query.
 */
database.queryPromise = (sql, param) => {
    return new Promise((resolve, reject) => {
        connection.query(sql, param, (err, res) => {
            if (err) {
                reject(err);
            }
            resolve(res);
        });
    });
};



module.exports = database;
