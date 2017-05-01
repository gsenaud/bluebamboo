# Cordova plugin for Star Printers

Author: Thomas Fétiveau, 2017

## General information

This plugin for Cordova supports the iOS platform only.

It has been tested with a Blue Bamboo® P200. You may encounter issues if using with other devices.

## Installation

`cordova plugin add <path-to-cordova-plugin-bluebamboo>`

**Before using the plugin on a iOS device, your device must be paired with your P200 peripheral. To do so, go to your iOS settings > Bluetooth settings and select the P200 device that should be listed there to pair with it.**

## Testing

You can test the plugin with the sample Cordova application that you can find under `/test/www` in this plugin directory.

## API

### Methods

* `bluebamboo.connect(successCb, errorCb)`

Connect to the first P200 found.

* `bluebamboo.disconnect(successCb, errorCb)`

* `bluebamboo.startICC(successCb, errorCb)`

Reads an IC Card. `successCb` takes a string as parameter containing the ICC data. 

* `bluebamboo.startMSR(successCb, errorCb)`

Reads an Magnetic Card. `successCb` takes a string as parameter containing the MSR data.

* `bluebamboo.startDisplay(lines, successCb, errorCb)`

`lines` must be an array of string (max 4) containing the text to display on the P200 screen.

* `bluebamboo.startEMV(successCb, errorCb)`

`successCb` take a string parameter containing the transaction data. EMV parameters must be set up on the P200 device to make this work.

* `bluebamboo.print(data, successCb, errorCb)`

`data` must be a array of print objects: `[{type: "text", value: "Bonjour,"}, {type: "text", value: "SHIFTEO !"}, ]`
