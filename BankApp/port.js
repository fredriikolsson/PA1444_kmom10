"use strict";
var port = {};
port.getPort = () =>
{
    if ('LINUX_PORT' in process.env)
    {
        return `${process.env.LINUX_PORT}`;
    }
    else
    {
        return -1;
    }
};

module.exports = port;
