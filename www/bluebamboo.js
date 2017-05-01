// © 2017 Thomas Fétiveau. All rights reserved.

/* global cordova, module */
"use strict";

module.exports = {

    connect: function (success, failure) {

        cordova.exec(success, failure, 'BlueBamboo', 'connect', []);
    },

    disconnect: function (success, failure) {

        cordova.exec(success, failure, 'BlueBamboo', 'disconnect', []);
    },

    startICC: function (success, failure) {

        cordova.exec(success, failure, 'BlueBamboo', 'startICC', []);
    },

    startMSR: function (success, failure) {

        cordova.exec(success, failure, 'BlueBamboo', 'startMSR', []);
    },

    startDisplay: function (lines, success, failure) {

        cordova.exec(success, failure, 'BlueBamboo', 'startDisplay', lines);
    },

    // clearDisplay: function (success, failure) {

    //     cordova.exec(success, failure, 'BlueBamboo', 'clearDisplay', []);
    // },

    startEMV: function (amount, success, failure) {

        cordova.exec(success, failure, 'BlueBamboo', 'startEMV', [amount]);
    },

    print: function (data, success, failure) {

        cordova.exec(success, failure, 'BlueBamboo', 'print', [data]);
    }
}