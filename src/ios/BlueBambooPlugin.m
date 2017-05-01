//
//  BlueBambooPlugin.m
//  Blue Bamboo Cordova Plugin
//
//  © 2017 Thomas Fétiveau, All rights reserved.

#import "BlueBambooPlugin.h"
#import <Cordova/CDVPlugin.h>

#import <ExternalAccessory/ExternalAccessory.h>
#import "P200DemoSessionController.h"
#import "EmvResult.h"
#import "Global.h"
#import "StringUtil.h"
#import "P200Commands.h"

#define DISPLAY_MODE 1
#define ICC_MODE 2
#define MSR_MODE 3
#define EMV_MODE 4
#define PRINT_MODE 5

@implementation BlueBambooPlugin

Byte iccCmd[] = {0x00,0xa4,0x04,0x00};
Byte iccFrameCmd[] = {0x55,0x66,0x77,0x88,0x4e};
Byte displayFrameCmd[]={0x55,0x66,0x77,0x88,0x4f};


- (void)pluginInitialize {

    NSLog(@"Blue Bamboo Plugin");
    NSLog(@"© 2017 Thomas Fétiveau");

    [super pluginInitialize];

    _isConnected = NO;
}


#pragma mark - Cordova Plugin Methods


- (void) disconnect:(CDVInvokedUrlCommand*)command {

    NSLog(@"-- disconnect --");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:P200DemoSessionDataReceivedNotification object:nil];
    
    [_sessionController closeSession];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void) connect:(CDVInvokedUrlCommand*)command {

    NSLog(@"-- connect --");

    _connectCallbackId = command.callbackId;

    _sessionController = [P200DemoSessionController sharedController]; // init the External Accessory Session

    // register the notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceived:) name:P200DemoSessionDataReceivedNotification object:nil];

    // get supported external accessory protocols
    _supportedExternalAccessoryProtocols = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedExternalAccessoryProtocols"];

    [self _autoConnectDevice];

    _mode = 0;
}

- (void)startDisplay:(CDVInvokedUrlCommand*)command {

    NSLog(@"-- startDisplay --");

    [self _clean];

    _mode = DISPLAY_MODE;

    if (command.arguments.count > 0) {

        NSMutableString *displayStr = [NSMutableString stringWithFormat:@"%c",TAG_DISPLAY_ALIGH_CENTER];

        if (command.arguments.count > 1) {

            [displayStr appendString:[NSString stringWithFormat:@"%@\n", [command argumentAtIndex:0]]];

            [displayStr appendString:[NSString stringWithFormat:@"%c",TAG_DISPLAY_ALIGH_CENTER]];
            
            if (command.arguments.count > 2) {

                [displayStr appendString:[NSString stringWithFormat:@"%@\n", [command argumentAtIndex:1]]];

                [displayStr appendString:[NSString stringWithFormat:@"%c",TAG_DISPLAY_ALIGH_CENTER]];

                if (command.arguments.count > 3) {

                    [displayStr appendString:[NSString stringWithFormat:@"%@\n", [command argumentAtIndex:2]]];

                    [displayStr appendString:[NSString stringWithFormat:@"%c",TAG_DISPLAY_ALIGH_CENTER]];
                    [displayStr appendString:[command argumentAtIndex:3]];
                }
                else {

                    [displayStr appendString:[NSString stringWithFormat:@"%@", [command argumentAtIndex:2]]];
                }
            }
            else {

                [displayStr appendString:[NSString stringWithFormat:@"%@", [command argumentAtIndex:1]]];
            }
        }
        else {
            
            [displayStr appendString:[NSString stringWithFormat:@"%@", [command argumentAtIndex:0]]];
        }
        [self _sendDisplayCommand:displayStr];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else {

        NSString *error = [NSString stringWithFormat:@"No text provided to display"];
        NSLog(error);

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)clearDisplay:(CDVInvokedUrlCommand*)command {

    NSLog(@"-- clearDisplay --");

    // TODO
}

- (void)startICC:(CDVInvokedUrlCommand*)command {

    NSLog(@"-- startICC --");

    [self _clean];

    _mode = ICC_MODE;

    _iccCallbackId = command.callbackId;

    // _sessionController = [P200DemoSessionController sharedController];

    aidArray = [NSMutableArray arrayWithObjects:
                @"A0 00 00 00 03 00 00",
                @"A0000000031010",
                @"a0 00 00 00 03 20 10",
                @"a0 00 00 00 03 30 10",
                @"a0 00 00 00 03 40 10",
                @"a0 00 00 00 03 50 10",
                @"a0 00 00 00 04 10 10",
                @"a0 00 00 00 04 20 10",
                @"a0 00 00 00 04 30 10",
                @"A0 00 00 00 65 10 10",
                @"A000000065101000",
                @"a0 00 00 00 25",
                @"A000000065101000",
                nil ];
    
    sendAidThread = [[NSThread alloc]initWithTarget:self selector:@selector(sendICCCmd) object:(nil)];
    readSuccessfully = NO;
    closeRes = NO;

    // _iccState = STATE_ICC_TURN_ON;
    _iccState = STATE_ICC_CMD1;

    [self _writeICCData];
}

- (void)startMSR:(CDVInvokedUrlCommand*)command {

    NSLog(@"-- startMSR --");

    [self _clean];

    _mode = MSR_MODE;

    _msrCallbackId = command.callbackId;

    // _sessionController = [P200DemoSessionController sharedController];

    // _msrState = STATE_MSR_DISPLAY;
    _msrState = STATE_MSR_COMMAND;

    [self _writeMSRData];
}

- (void)startEMV:(CDVInvokedUrlCommand*)command {

    NSLog(@"-- startEMV --");

    [self _clean];

    CDVPluginResult *pluginResult = nil;
    NSString *error = nil;

    _mode = EMV_MODE;

    _emvCallbackId = command.callbackId;

    if (command.arguments.count > 0) {

        // _emvState = STATE_EMV_INIT;

        // _amount = [command.arguments objectAtIndex:0];
        _amount = [[command argumentAtIndex:0] floatValue] * 100;

        if (_amount <= 0) {
            
            error = [NSString stringWithFormat:@"Incorrect amount value"];
            NSLog(error);

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        else {

            NSLog(@"Start EMV workflow with amount %d",_amount);

            _emvState = STATE_EMV_AUTHORIZE;

            [self _writeEMVData];
        }
    }
    else {

        error = [NSString stringWithFormat:@"No amount provided for EMV transaction"];
        NSLog(error);

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)print:(CDVInvokedUrlCommand*)command {

    NSLog(@"-- print --");

    [self _clean];

    CDVPluginResult *pluginResult = nil;
    NSString *error = nil;

    _mode = PRINT_MODE;

    if (command.arguments.count > 0) {

        NSArray *pdata = [command.arguments objectAtIndex:0];

        if (pdata != nil) {

            NSString * _printContent = @"";

            for (int i = 0; i < pdata.count; i++) {
        
                NSMutableDictionary *prntDataLine = [pdata objectAtIndex:i];

                NSLog(@"prntDataLine type: %@", prntDataLine[@"type"]);

                if ([prntDataLine[@"type"] isEqualToString:@"text"]) {

                    NSLog(@"text line: %@", prntDataLine[@"value"]);

                    _printContent = [_printContent stringByAppendingString:[NSString stringWithFormat:@"%@\n",prntDataLine[@"value"]]];
                }
                else {

                    NSLog(@"print item type not supported: %@", prntDataLine[@"type"]);
                }
            }

            // [self _sendCommand:_printContent withType:FRAME_TOF_PRINT];
            [self _sendPrintTextCommand:_printContent];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
    }

    error = [NSString stringWithFormat:@"No data provided for printing"];
    NSLog(error);

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


#pragma internals - notification observers

/** general **/

- (void)_accessoryDidConnect:(NSNotification *)notification {
    // get the new connected accessory
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    [_accessoryList addObject:connectedAccessory];
    if (!_isConnected) {
        
        if ([[connectedAccessory protocolStrings] containsObject:defaultProtocolString]) { //if find the accessory(p200) record it
            _selectedAccessory = connectedAccessory;
            [self _connect];
        }
    }
    NSLog(@"_accessoryDidConnect");
}

- (void)_accessoryDidDisconnect:(NSNotification *)notification {
    
    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    int disconnectedAccessoryIndex = 0;
    
    for (EAAccessory *accessory in _accessoryList) {

        if ([disconnectedAccessory connectionID] == [accessory connectionID]) {
            break;
        }
        disconnectedAccessoryIndex++;
    }
    
    if (disconnectedAccessoryIndex < [_accessoryList count]) {

        [_accessoryList removeObjectAtIndex:disconnectedAccessoryIndex];

    }
    else {
        if (IS_LOG_MODE) {
            NSLog(@"could not find disconnected accessory in accessory list");
        }
    }
    [self _disconnect];
    NSLog(@"_accessoryDidDisconnect");
}

- (void)_sessionDataReceived:(NSNotification *)notification {

    NSLog(@"_sessionDataReceived and mode is %d", _mode);

    _sessionController = (P200DemoSessionController *)[notification object];
    uint64_t bytesAvailable = 0;
    
    while ((bytesAvailable = [_sessionController readBytesAvailable]) > 0) {
        NSData *data = [_sessionController readData:bytesAvailable];
        if (data) {
            _totalBytesRead += bytesAvailable;

            if (_mode == ICC_MODE) {
            
                [self _processICCData:data];
            }
            else if (_mode == MSR_MODE) {

                [self _processMSRData:data];
            }
            else if (_mode == EMV_MODE) {

                [self _processEMVData:data];
            }
        }
    }
    NSLog(@"Bytes Received from Session: %llu", _totalBytesRead);
}



#pragma internals

- (void)_clean {

    _totalBytesRead = 0;
}

// get connected accessories supported the application protocols list
- (NSMutableArray *)_getConnectedAccessories:(NSArray *) protocolStrings {
    
    // get all the connected accessories
    NSMutableArray *connectedAccessories = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    NSLog(@"connectedAccessories.count %lu", (unsigned long)connectedAccessories.count);
    NSLog(@"protocolStrings.count %lu", (unsigned long)protocolStrings.count);
    
    // remove the accessories not supportting the application protocols
    if (protocolStrings && protocolStrings.count > 0) {  
        
        for (EAAccessory *accessory in connectedAccessories) { // get the accessories of the certain protocol
            BOOL comparedWithTheProtocol = NO;
            for (NSString *accessoryProtocolString in accessory.protocolStrings) {
                for (NSString *protocolString in protocolStrings) {
                    
                    NSLog(@"accessoryProtocolString %@", accessoryProtocolString);
                    NSLog(@"protocolString %@", protocolString);
                    
                    if ([accessoryProtocolString isEqual:protocolString]) {
                        comparedWithTheProtocol = YES;
                    }
                }
            }
            if (!comparedWithTheProtocol) {
                [connectedAccessories removeObject:accessory];
            }
        }
    }
    
    NSLog(@"After connectedAccessories.count %lu", (unsigned long)connectedAccessories.count);

    return connectedAccessories;
}

// connect to the device automatically
- (void)_autoConnectDevice {
    
    _accessoryList = [self _getConnectedAccessories:_supportedExternalAccessoryProtocols];
    
    if (_accessoryList.count >= 1) {

        EAAccessory *accessory = [_accessoryList objectAtIndex:0];
        _selectedAccessory = accessory;
        [self _connect];
    }
    // if (_accessoryList.count > 1) { // we could display a popin to choose when more than one device
}

// open the external accessory session
- (void)_connect {

    CDVPluginResult *pluginResult = nil;
    
    if (_selectedAccessory) {

        [_sessionController setupControllerForAccessory:_selectedAccessory
                                     withProtocolString:defaultProtocolString];

        [_sessionController openSession];

        _isConnected = YES;

        NSLog([NSString stringWithFormat:@"connected to %@", _selectedAccessory.name]); // TODO manage success cb


        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    else {
        NSString *error = [NSString stringWithFormat:@"P200 is not Connected."];
        NSLog(error);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    }
    [pluginResult setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:_connectCallbackId];
}

// close the external accessory session
- (void)_disconnect {

    [_sessionController closeSession];
    _selectedAccessory = nil;
    _isConnected = NO;

    NSString *error = [NSString stringWithFormat:@"P200 is not Connected."];
    NSLog(error);
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    [pluginResult setKeepCallbackAsBool:YES];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_connectCallbackId];
}


#pragma - Print internals

-(void)_sendPrintTextCommand:(NSString*)contentStr {
    
    NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t buf[data.length+9];
    
    buf[0] = 0X55;
    buf[1] = 0x66;
    buf[2] = 0x77;
    buf[3] = 0x88;
    buf[4] = 0x44;
    NSLog(@"text = %@",contentStr);
    NSLog(@"buf = %s,length = %lu",buf,(unsigned long)data.length);
    memcpy(buf+5, [data bytes], data.length);
    
    buf[data.length+5]=0x0A;
    buf[data.length+6]=0x0A;
    buf[data.length+7]=0x0A;
    buf[data.length+8]=0x0A;
    
    NSLog(@"_sendPrintTextCommand: %@", [[Global getInstance] getHexString:buf start:0 end:sizeof(buf)]);
    
    [_sessionController writeData:[NSData dataWithBytes:buf length:sizeof(buf)]];
}




#pragma - EMV internals


- (void) _processEMVData:(NSData *)data {

    CDVPluginResult *pluginResult = nil;
    NSString *error = nil;

    Byte *buf = (Byte *)[data bytes];
    NSInteger len = data.length;
    
    NSLog(@"EMV data received: %@", [[Global getInstance] getHexString:buf start:0 end:len]);

    if (![P200Commands checkResponseBuf:buf withLength:len]) {

        error = [NSString stringWithFormat:@"Response data error"];
        NSLog(error);

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_emvCallbackId];

        return;
    }
    if (len >= 5 && buf[4] == FRAME_TOF_EMV) {

        NSString *message = @"";
        NSString *emvResultString = @"";

        for (int i = 5; i < len; i++) {

            emvResultString = [emvResultString stringByAppendingFormat:@"%c",buf[i]];
            message=[message stringByAppendingFormat:@"%02X ",buf[i]];
        }
        
        NSLog(@"%@", message);
        NSLog(@"%@", emvResultString);
        if ([emvResultString characterAtIndex:0] == 'C') {

            if([emvResultString isEqualToString:@"Command=Notify&Status=01"] || [emvResultString isEqualToString:@"Command=Notify&Status=02"]) {

                NSLog(@"Please Input the PIN!");
                NSLog(@"Please Enter PIN on P200");
                _emvState = STATE_EMV_ENTER_PASSWORD;
                // [self _writeEMVData];
            }
        }
        else if ([emvResultString characterAtIndex:0] == '<') {
            
            EmvResult *emvResult = [[EmvResult alloc]initWithSring:emvResultString];
            
            if ([emvResult.status isEqualToString:@"success"]) {

                NSString *result = emvResult.result;

                switch (_emvState) {
                        
                    case STATE_EMV_INIT: {
                        _emvState = STATE_EMV_GET_TERMINAL_ID;
                        [self _writeEMVData];;
                        break;
                    }
                        
                    case STATE_EMV_GET_TERMINAL_ID: {
                        _terminalId = result;
                        _emvState = STATE_EMV_GET_MERCHANT_ID;
                        [self _writeEMVData];;
                        break;
                    }
                        
                    case STATE_EMV_GET_MERCHANT_ID: {
                        _merchantId = result;
                        NSLog(@"Please Enter Amount!");
                        break;
                    }
                        
                    case STATE_EMV_SET_PIN_ENTER_MODE:
                    case STATE_EMV_UPDATE_PARAM: {
                        _emvState = STATE_EMV_INIT;
                        [self _writeEMVData];;
                        break;
                    }
                    
                    case STATE_EMV_ENTER_PASSWORD:
                    case STATE_EMV_AUTHORIZE: {
                        
                        NSLog(@"Processing.... Please Wait!");

                        NSLog(@"emvResult.result %@", emvResult.result);
                        NSLog(@"emvResult.status %@", emvResult.status);
                        NSLog(@"emvResult.amount %@", emvResult.amount);
                        NSLog(@"emvResult.transType %@", emvResult.transType);
                        
                        NSString *amountTemp = [NSString stringWithFormat:@"%d", [emvResult.amount intValue]];
                        _amount = [amountTemp intValue];
                        NSInteger amountLen = amountTemp.length;
                        _amountStr = @"";
                        _amountStr = [_amountStr stringByAppendingString:[amountTemp substringToIndex:amountLen-2]];
                        _amountStr = [_amountStr stringByAppendingString:@"."];
                        _amountStr = [_amountStr stringByAppendingString:[amountTemp substringFromIndex:amountLen-2]];
                        NSLog(_amountStr);
                        _pan = emvResult.pan;
                        
                        if([result isEqualToString:@"Online"]) {
                            
                            _emvState = STATE_EMV_AUTHORIZE_ONLINE;
                            [self _writeEMVData];;
                        }
                        else if([result isEqualToString:@"Offline"]) {
                            
                            _emvState = STATE_EMV_COMFIRMATION;
                            [self _writeEMVData];;
                        }
                        break;
                    }
                    
                    case STATE_EMV_AUTHORIZE_ONLINE: {

                        _emvState = STATE_EMV_COMFIRMATION;
                        [self _writeEMVData];;
                        break;
                    }
                    
                    case STATE_EMV_COMFIRMATION: {
                        NSLog(@"FINISHED");

                        NSString *transactionResult = @"Transaction Success";
                        transactionResult = [transactionResult stringByAppendingString:@"\n\nMerchant ID: "];
                        transactionResult = [transactionResult stringByAppendingString:_merchantId];
                        transactionResult = [transactionResult stringByAppendingString:@"\nTerminal ID: "];
                        transactionResult = [transactionResult stringByAppendingString:_terminalId];
                        transactionResult = [transactionResult stringByAppendingString:@"\nCard PAN: "];
                        transactionResult = [transactionResult stringByAppendingString:_pan];
                        transactionResult = [transactionResult stringByAppendingString:@"\nTransaction Type: SALE\nTransaction Amount: "];
                        transactionResult = [transactionResult stringByAppendingString:_amountStr];
                        
                        NSLog(transactionResult);

                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:transactionResult];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:_emvCallbackId];
                        break;
                    }
                        
                    default: {
                        break;
                    }
                }
            }
            else {

                NSString * errorCodeString = emvResult.result;
                
                NSString * error = [NSString stringWithFormat:@"%@", [self getErrorString:errorCodeString]];
                NSLog(error);
                
                int errorCode = [errorCodeString intValue];
                
                switch (errorCode) {
                    
                    case 7:
                        _emvState = STATE_EMV_UPDATE_PARAM;
                        [self _writeEMVData];
                        return;
                    
                    case 8:
                        error = @"Please Set Parameter On P200";
                        NSLog(error);
                        break;
                    
                    case 13:
                        _emvState = STATE_EMV_SET_PIN_ENTER_MODE;
                        [self _writeEMVData];
                        return;
                    
                    default:
                        break;
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:_emvCallbackId];
            }
        }
    }
}

// send data to P200 terminal
- (void)_writeEMVData {
    
    NSString *amountWithoutPoint = [NSString stringWithFormat:@"%ld", (long)_amount];
    
    switch (_emvState) {
            
        case STATE_EMV_INIT:
            [self _initializeTransactionCommand];
            break;

        case STATE_EMV_GET_TERMINAL_ID:
            [self _getTeminalIdCommand];
            break;

        case STATE_EMV_GET_MERCHANT_ID:
            [self _getMerchantIdCommand];
            break;

        case STATE_EMV_UPDATE_PARAM:
            [self _updateEmvParamCommand];
            break;

        case STATE_EMV_SET_PIN_ENTER_MODE:
            [self _setPinEntryModeCommand];
            break;
        
        case STATE_EMV_AUTHORIZE:
            NSLog(@"%@", amountWithoutPoint);
            [self _authorizeCommand:amountWithoutPoint];
            
            NSLog(@"Please Insert Card"); // TODO CDV CB ?
            break;
        
        case STATE_EMV_AUTHORIZE_ONLINE:
            [self _authorizeOnlineCommand:amountWithoutPoint andTerminalId:_terminalId];
            break;
        
        case STATE_EMV_COMFIRMATION:
            [self _confirmationCommand:_terminalId];
            break;
        
        // case STATE_EMV_PRINT_RECEIPT:
        //     [self _sendCommand:_printContent withType:FRAME_TOF_PRINT];
        //     break;

        // case STATE_EMV_ENTER_PASSWORD:
        //     [self sendACK];
        //     break;

        default:
            break;
    }
}

- (void)_getTeminalIdCommand {

    NSString *getTeminalIdString=@"Command=GetTerminalID";
    NSLog(@"The EMV Command is %@", getTeminalIdString);
    [self _sendCommand:getTeminalIdString withType:FRAME_TOF_EMV];
}

- (void)_getMerchantIdCommand {

    NSString *getMerchantIdString=@"Command=GetMerchantID";    
    _emvState = STATE_EMV_GET_MERCHANT_ID;
    NSLog(@"The EMV Command is %@", getMerchantIdString);
    [self _sendCommand:getMerchantIdString withType:FRAME_TOF_EMV];
}

- (void)_initializeTransactionCommand {
    
    NSString *initializeTransactionString=@"Command=InitializeTransaction";
    _emvState = STATE_EMV_INIT;
    
    NSLog(@"The EMV Command is %@", initializeTransactionString);
    [self _sendCommand:initializeTransactionString withType:FRAME_TOF_EMV];
}

- (void)_updateEmvParamCommand {
    
    NSString *updateEmvParamString=@"Command=UpdateEmvParam&TerminalType=22&Capability=e0b0c8&AdditionalCapability=F000F0E001&TransCurrencyExp=00&ReferCurrencyExp=00&ReferCurrencyCode=0840&CountryCode=0840&TransCurrencyCode=0840&ForceOnline=1&SurportPSESel=1";
    _emvState = STATE_EMV_UPDATE_PARAM;
    
    NSLog(@"The EMV Command is %@", updateEmvParamString);
    [self _sendCommand:updateEmvParamString withType:FRAME_TOF_EMV];
}

- (void)_setPinEntryModeCommand {
    
    NSString *setPinEntryModeString=@"Command=SetPinEntryMode&Mode=1&Slot=1&MinLength=2&MaxLength=12&Timeout=40";
    _emvState = STATE_EMV_SET_PIN_ENTER_MODE;
    
    NSLog(@"The EMV Command is %@", setPinEntryModeString);
    [self _sendCommand:setPinEntryModeString withType:FRAME_TOF_EMV];
}

- (void)_authorizeCommand:(NSString *) amountString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSString *dateString=[formatter stringFromDate: [NSDate date]];
    NSLog(@"%@", dateString);
    [formatter setDateFormat:@"HHmmss"];
    NSString *timeString=[formatter stringFromDate: [NSDate date]];
    NSLog(@"%@", timeString);
    NSString *authorizeString = @"Command=Authorize&Amount=";
    authorizeString = [authorizeString stringByAppendingString:amountString];
    authorizeString = [authorizeString stringByAppendingString:@"&AmountOther=0&TransactionType=Sale&ProcessingCode=000000&TransactionDate="];
    authorizeString = [authorizeString stringByAppendingString:dateString];
    authorizeString = [authorizeString stringByAppendingString:@"&TransactionTime="];
    authorizeString = [authorizeString stringByAppendingString:timeString];
    
    _emvState = STATE_EMV_AUTHORIZE;
    
    NSLog(@"The EMV Command is %@", authorizeString);
    [self _sendCommand:authorizeString withType:FRAME_TOF_EMV];
}

- (void)_authorizeOnlineCommand:(NSString *)amountString andTerminalId:(NSString *)terminalId {
    
    NSString *authorizeOnlineString=@"Command=AuthorizeOnline&AuthorizedAmount=";
    authorizeOnlineString = [authorizeOnlineString stringByAppendingString:amountString];
    authorizeOnlineString = [authorizeOnlineString stringByAppendingString:@"&AuthorizationCode=300009&ResponseCode=00&TerminalID="];
    authorizeOnlineString = [authorizeOnlineString stringByAppendingString:terminalId];;
    _emvState = STATE_EMV_AUTHORIZE_ONLINE;
    NSLog(@"The EMV Command is %@", authorizeOnlineString);
    [self _sendCommand:authorizeOnlineString withType:FRAME_TOF_EMV];
}


- (void)_confirmationCommand:(NSString *)terminalId {
    
    NSString *confirmationString=@"Command=Confirmation&TerminalID=";
    confirmationString = [confirmationString stringByAppendingString:terminalId];
    _emvState = STATE_EMV_COMFIRMATION;
    
    NSLog(@"The EMV Command is %@", confirmationString);
    [self _sendCommand:confirmationString withType:FRAME_TOF_EMV];
}

- (void)_sendACK {
    
    [self _sendCommand:@"" withType:FRAME_ACK];
}


- (void)_sendCommand:(NSString *)commandString withType:(Byte)frameType {
    
    const char *commandChars = [commandString UTF8String];
    uint8_t buf[5+[commandString length]];
    buf[0] = 0X55;
    buf[1] = 0x66;
    buf[2] = 0x77;
    buf[3] = 0x88;
    buf[4] = frameType;
    memcpy(&buf[5],commandChars,[commandString length]);
    
    [_sessionController writeData:[NSData dataWithBytes:buf length:sizeof(buf)]];
}

-(NSString *) getErrorString:(NSString *)errorCode {
    
    NSString *errorString = [[NSString alloc] initWithFormat: @"%@ %@", NSLocalizedString(@"EMV Transaction Failed. Error Code: ", nul), errorCode];
    return errorString;
}



#pragma - MSR internals


// send data to P200 terminal
- (void)_writeMSRData {
    
    switch (_msrState) {

        case STATE_MSR_DISPLAY: {
            // standby
            break;
        }
        case STATE_MSR_COMMAND: { // start the P200 to wait for swiping card
            [self _sendUnencryptedCommand];
            break;
        }
        case STATE_MSR_ENCRYPTED_COMMAND:{
            [self _sendEncryptedCommand];
            break;
        }
        default:
            break;
    }
}

- (void)_processMSRData:(NSData *)data {

    CDVPluginResult *pluginResult = nil;
    NSString *error = nil;
    
    Byte *buf = (Byte *)[data bytes];
    NSInteger len = data.length;
    
    NSLog(@"_sessionDataReceived: %@", [[Global getInstance] getHexString:buf start:0 end:len]);
    
    if (![P200Commands checkResponseBuf:buf withLength:len]) {
        
        error = @"Error: Response data error";
        NSLog(error);

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_msrCallbackId];
        return;
    }
    if (len >= 5) {

        // NSLog(@"_msrState = %ld",(long)_msrState);
        
        switch (_msrState) {
        
            case STATE_MSR_DISPLAY: {
                if (buf[4] == FRAME_TOF_DISPLAY) {
                    _msrState = STATE_MSR_COMMAND;
                    [self _writeMSRData];
                    NSLog(@"Please Swipe Card");
                } else {
                    // [_startButton setHidden:NO];
                }
                break;
            }

            case STATE_MSR_ENCRYPTED_COMMAND:
            case STATE_MSR_COMMAND: {
                
                if (buf[4] == FRAME_TOF_MSR_BACK) {
                    
                    if(buf[5] == 0x01){
                        _msrState = STATE_MSR_ENCRYPTED_COMMAND;
                        [self _writeMSRData];
                        return;
                    }
                    if (len > 6) {
                        
                        NSLog(@"Read Card Success"); // TODO CDV CB ?
                    }
                    else {
                        
                        error = @"Read Card Failed";
                        NSLog(error);

                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:_msrCallbackId];
                        return;
                    }

                    NSMutableString * tracks = [NSMutableString stringWithFormat:@""];
                    
                    for (int i = 6; i < len; i++) {

                        cardSwiped = YES;
                        //get first track data
                        if (buf[i]==0x31) {

                            i++;
                            NSString *stringLength;
                            NSInteger inttext=0;
                            NSInteger track1length=0;
                            //count length of track data [30][30][30][39] means 9 bytes data
                            stringLength= [[NSString alloc] initWithFormat:@"%x",buf[i]];
                            
                            // NSLog(@"the %d string = %@",i,stringLength);
                            inttext=([stringLength intValue]-30)*1000;
                            track1length=track1length+inttext;
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x",buf[i]];
                            inttext=([stringLength intValue]-30)*100;
                            track1length=track1length+inttext;
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x",buf[i]];
                            inttext=([stringLength intValue]-30)*10;
                            track1length=track1length+inttext;
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x",buf[i]];
                            inttext=([stringLength intValue]-30)*1;
                            track1length=track1length+inttext;
                            i++;
                            //get first track data length
                            
                            if (track1length>0)
                            {
                                unsigned char buffer[track1length];
                                NSMutableData *data=[[NSMutableData alloc] init];
                                
                                for (int j=0;j<track1length;j++)
                                {
                                    buffer[j]=buf[i];
                                    i++;
                                }
                                //get first track data
                                [data appendBytes:buffer length:track1length];
                                //convert track data into string
                                NSString *stringtest = [[NSString alloc] 
                                                        initWithData:(NSData *)data
                                                        encoding:NSASCIIStringEncoding];
                                
                                NSLog(@"track 1: %@",stringtest);
                                [tracks appendString:@"Track 1:"];
                                [tracks appendString:stringtest];
                            }
                            else if (track1length == 0) {
                                
                                NSLog(@"Track1: No data");
                                [tracks appendString:@"Track 1: no data"];
                                break;
                            }
                        }
                        
                        //get track 2 data
                        if (buf[i] == 0X32) {

                            i++;
                            NSString *stringLength;
                            NSInteger inttext=0;
                            NSInteger track2length=0;
                            
                            stringLength= [[NSString alloc] initWithFormat:@"%x:",buf[i]];
                            
                            inttext=([stringLength intValue]-30)*1000;
                            track2length=track2length+inttext;
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x:",buf[i]];
                            
                            inttext=([stringLength intValue]-30)*100;
                            track2length=track2length+inttext;
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x:",buf[i]];
                            
                            inttext=([stringLength intValue]-30)*10;
                            track2length=track2length+inttext;
                            
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x:",buf[i]];
                            
                            inttext=([stringLength intValue]-30)*1;
                            track2length=track2length+inttext;
                            i++;
                            
                            NSString *debutrack2;
                            debutrack2=[[NSString alloc] initWithFormat:@"<<%li>>",(long)track2length];
                            
                            //  [debutrack2 release];
                            if (track2length > 0) {
                                unsigned char buffer[track2length];
                                NSMutableData *data=[[NSMutableData alloc] init];
                                for (int j = 0; j < track2length; j++) {
                                    buffer[j]= buf[i];
                                    i++;
                                }
                                [data appendBytes:buffer length:track2length];
                                NSString *stringtest = [[NSString alloc] 
                                                        initWithData:(NSData *)data
                                                        encoding:NSASCIIStringEncoding];
                                
                                NSLog(@"Track 2: %@",stringtest);

                                [tracks appendString:@"Track 2:"];
                                [tracks appendString:stringtest];
                            }
                            else if(track2length == 0)
                            {
                                NSLog(@"Track 2: no data");
                                [tracks appendString:@"Track 2: no data"];
                                break;
                            }
                        }
                        //get track 3 data
                        if (buf[i] == 0X33) {

                            i++;
                            NSString *stringLength;
                            NSInteger inttext=0;
                            NSInteger track2length=0;
                            
                            stringLength= [[NSString alloc] initWithFormat:@"%x:",buf[i]];
                            
                            inttext=([stringLength intValue]-30)*1000;
                            track2length=track2length+inttext;
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x:",buf[i]];
                            
                            inttext=([stringLength intValue]-30)*100;
                            track2length=track2length+inttext;
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x:",buf[i]];
                            
                            inttext=([stringLength intValue]-30)*10;
                            track2length=track2length+inttext;
                            
                            i++;
                            stringLength= [[NSString alloc] initWithFormat:@"%x:",buf[i]];
                            
                            inttext=([stringLength intValue]-30)*1;
                            track2length=track2length+inttext;
                            i++;
                            
                            NSString *debutrack2;
                            debutrack2=[[NSString alloc] initWithFormat:@"<<%li>>",(long)track2length];
                            
                            if (track2length>0)
                            {
                                unsigned char buffer[track2length];
                                NSMutableData *data=[[NSMutableData alloc] init];
                                for (int j=0;j<track2length;j++)
                                {
                                    buffer[j]= buf[i];
                                    
                                    i++;
                                }
                                [data appendBytes:buffer length:track2length];
                                NSString *stringtest = [[NSString alloc] 
                                                        initWithData:(NSData *)data
                                                        encoding:NSASCIIStringEncoding
                                                        ];
                                NSLog(@"Track 3: %@",stringtest);
                                [tracks appendString:@"Track 3:"];
                                [tracks appendString:stringtest];
                            }
                            else if (track2length==0) {

                                NSLog(@"Track 3: No data");

                                [tracks appendString:@"Track 3: no data"];
                                break;
                            }
                            break;
                        }
                    }

                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:tracks];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:_msrCallbackId];

                    //end of convert msr
                }
                else if (buf[4] == 0x90) { // Encrypted Tracks
                    
                    NSString *buf6 = [[NSString alloc] initWithFormat:@"%x:",buf[6]];
                    NSInteger stringvalue6 = [self get16FormartIntValueWithString:buf6];
                    NSString *buf7 = [[NSString alloc] initWithFormat:@"%x:",buf[7]];
                    NSInteger stringvalue7 = [self get16FormartIntValueWithString:buf7];
                    // NSLog(@"buf7 = %@",buf7);
                    // NSLog(@"666 = %ld,777 === %ld",(long)stringvalue6,(long)stringvalue7);
                    //TrankLenth
                    NSInteger trankLenth = stringvalue6*255+stringvalue7;
                    NSInteger KsnLenth = 11;
                   
                    unsigned char buffer1[7];
                    memset(buffer1,0X00,sizeof(buffer1));
                    for(int j = 0; j < 6 ; j++) {
                        
                        buffer1[j] =buf[j+trankLenth+8+KsnLenth];
                        // NSLog(@"buffer1 = %c",buffer1[j]);
                    }
                    NSString *pan6 = [[NSString alloc ]initWithFormat:@"%s",buffer1];

                    unsigned char buffer2[5];
                    memset(buffer2, 0x00, sizeof(buffer2));
                    
                    for(int j = 0; j < 4 ; j++) {
                        
                        buffer2[j] = buf[j+trankLenth+8+KsnLenth+6];
                        // NSLog(@"buffer2 = %c",buffer2[j]);
                    }
                    NSString *pan4 = [[NSString alloc]initWithFormat:@"%s",buffer2];
                    
                    NSString * nameLengh16 = [[NSString alloc] initWithFormat:@"%x",buf[trankLenth+8+KsnLenth+10+4]];
                    NSInteger nameLenghstr = [self get16FormartIntValueWithString:nameLengh16];
                    NSInteger nameLengthStart = trankLenth+8+KsnLenth+10+5;
                    
                    NSMutableData *data = [[NSMutableData alloc] init];
                    unsigned char buffer[nameLenghstr];
                    
                    for (NSInteger i = 0; i<nameLenghstr; i++) {
                    
                        buffer[i] = buf[nameLengthStart+i];
                    }
                    [data appendBytes:buffer length:nameLenghstr];
                    
                    NSString *test2=[[NSString alloc] initWithFormat:@"%s",buffer ];
                    
                    NSString *str1 = [NSString stringWithFormat:@"FIRST 6 OF PAN: %@",pan6];
                    NSString *str2 = [NSString stringWithFormat:@"\n\nLAST 4 OF PAN: %@",pan4];
                    NSString *str3 = [NSString stringWithFormat:@"\n\nACCCOUNT NAME: %@",test2];
                    
                    NSString *showStr = [[str1 stringByAppendingString:str2]stringByAppendingString:str3];
                    
                    NSLog(@"encrypted tracks: %@",showStr);
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:showStr];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:_msrCallbackId];
                }
                else {
                    error = @"Read Card Failed";
                    NSLog(error);

                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:_msrCallbackId];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (NSInteger)get16FormartIntValueWithString:(NSString *)str {
    
    NSString *first = [str substringToIndex:1];
    NSString *last = [[str substringFromIndex:1] substringToIndex:1];

    NSInteger firstInt = [self getIntFromtext:first];
    NSInteger lastInt = [self getIntFromtext:last];

    NSInteger sum = firstInt*16+lastInt;
    
    return sum;
}

- (NSInteger)getIntFromtext:(NSString *)texts{

    NSInteger textValue ;
    NSString *text = texts.uppercaseString;

    if ([text isEqualToString:@"A"]) {
        textValue = 10;
    }
    else if([text isEqualToString:@"B"]) {
        textValue = 11;
    }
    else if([text isEqualToString:@"C"]) {
        textValue = 12;
    }
    else if([text isEqualToString:@"D"]) {
        textValue = 13;
    }
    else if([text isEqualToString:@"E"]) {
        textValue = 14;
    }
    else if([text isEqualToString:@"F"]) {
        textValue = 15;
    }
    else {
        textValue = [text integerValue];
    }

    return textValue;
}

// send the command to P200 ternimal to turn on the msr reader to wait for swiping card
-(void)_sendEncryptedCommand {

    uint8_t buf[] = {0X55, 0x66, 0x77, 0x88, 0x48, 0x32, 0x30,0x01,0x01,0x01,0x00};
    [_sessionController writeData:[NSData dataWithBytes:buf length:sizeof(buf)]];
}

- (void)_sendUnencryptedCommand {

    uint8_t buf[] = {0X55, 0x66, 0x77, 0x88, 0x48, 0x32, 0x30};
    [_sessionController writeData:[NSData dataWithBytes:buf length:sizeof(buf)]];
}



#pragma - ICC internals


// process the data from P200 ternimal
- (void)_processICCData:(NSData *)data {

    CDVPluginResult *pluginResult = nil;
    NSString *error = nil;

    Byte *buf = (Byte *)[data bytes];
    NSInteger len = data.length;
    
    NSLog(@"_sessionDataReceived: %@", [[Global getInstance] getHexString:buf start:0 end:len]);

    if (len >=5 && buf[4] != FRAME_TOF_DISPLAY && buf[4] != FRAME_TOF_ICC) {
        
        error = [NSString stringWithFormat:@"Response data error %@",[[Global getInstance]getHexString:buf start:0 end:len]];
        NSLog(error);

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [pluginResult setKeepCallbackAsBool:YES];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:_iccCallbackId];
        return;
    }
    if (len >=5 && buf[4] == FRAME_TOF_DISPLAY) {
        
        if (buf[5] != 0x00) {

            error = [NSString stringWithFormat:@"Display state error: %@", [[Global getInstance] getHexString:buf start:0 end:len]];
            NSLog(error);

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
            [pluginResult setKeepCallbackAsBool:YES];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:_iccCallbackId];
        }
        else {
            _iccState = STATE_ICC_CMD1;
            [self _writeICCData];
        }
        return;
    }    
    Byte end1 = buf[data.length-2];
    Byte end2 = buf[data.length-1];
    
    if(len >= 5 && buf[4] == FRAME_TOF_ICC ){
    
        if (buf[5] != 0x00) {
    
            if (iccRun) {
    
                iccRun = NO;
            }
            error = [NSString stringWithFormat:@"ICC state error: %@", [[Global getInstance] getHexString:buf start:0 end:len]];
            NSLog(error);

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
            [pluginResult setKeepCallbackAsBool:YES];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:_iccCallbackId];
            return;
        }
        switch (_iccState) {
            
            case STATE_ICC_TURN_ON:
                NSLog(@"Please Insert Card");
                _iccState = STATE_ICC_CMD1;
                [self _writeICCData];
                break;
            
            case STATE_ICC_CMD1: {
                NSLog(@"Processing");
                NSLog(@"Please wait");
                NSLog(@"IC Card Inserted");
                _iccState = STATE_ICC_CMD2;
                [self _writeICCData];
                break;
            }
            
            case STATE_ICC_CMD2:  {
                
                if(end1 == 0x90 && end2 == 0x00){
                    iccRun = NO;
                    NSLog(@"Read Card Success");

                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[Global getInstance] getHexString:buf start:7 end:len]];

                    [self.commandDelegate sendPluginResult:pluginResult callbackId:_iccCallbackId];
                }
                else {

                    if (aidIndex == [aidArray count]) {

                        // [self showEntryDialog]; ??
                        // [self updateLabel]; ??
                    }
                }
                break;
            }
            case STATE_ICC_CMD3:

                if (end1 == 0x90 && end2 == 0x00) {

                    NSLog(@"Read Card Success");

                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[Global getInstance] getHexString:buf start:7 end:len]];

                    [self.commandDelegate sendPluginResult:pluginResult callbackId:_iccCallbackId];
                }
                else {

                    error = [NSString stringWithFormat:@"Error: %@",[[Global getInstance] getHexString:buf start:len-2 end:len]];
                    NSLog(error);

                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
                    [pluginResult setKeepCallbackAsBool:YES];

                    [self.commandDelegate sendPluginResult:pluginResult callbackId:_iccCallbackId];
                }
                break;
                
            case STATE_ICC_TURN_OFF:
                NSLog(@"STATE_ICC_TURN_OFF");
                closeRes = YES;
                // [self.navigationController popViewControllerAnimated:YES];
                break;

            default:
                break;
        }
        
    }
}

// send data to P200 terminal
- (void)_writeICCData {

    switch (_iccState) {
            
        case STATE_ICC_TURN_ON:
            // standby
            break;
            
        case STATE_ICC_CMD1:
            [self _sendOpenCommand];
            NSLog(@"Please Insert Card");
            break;
    
        case STATE_ICC_CMD2:
            [sendAidThread start];
            break;
    
        case STATE_ICC_CMD3:
            [self _sendReadingCommand2];
            break;
    
        case STATE_ICC_TURN_OFF:
            [self _sendCloseCommand];
            NSLog(@"Closing...");
            // [[[NSThread alloc]initWithTarget:self selector:@selector(closeAndBack) object:nil] start];
            break;
    
        default:
            break;
    }
}

-(Byte *)getAidData:(NSString *)aid
{
    Byte *aidData = [StringUtil hexStringToBytes:aid];
    if(!aidData)
        return nil;
    Byte *data = malloc(sizeof(Byte)*(9+[StringUtil getBytesDataLength:aid]));
    data[0] = TAG_ICC_SEND_COMMAND;
    data[1] = TAG_ICC_SLOT_ICC;
    data[2] = 30;
    data[3] = 0xff;
    memcpy(data+4, iccCmd, sizeof(iccCmd));
    data[8] = [StringUtil getBytesDataLength:aid];
    memcpy(data+9, aidData, [StringUtil getBytesDataLength:aid]);
    NSString *log = [[Global getInstance]getHexString:data start:0 end:(9+[StringUtil getBytesDataLength:aid])];
    NSLog(@"aid data--->%@",log);
    return data;
}
-(NSInteger)getAidDataLength:(NSString *)aid
{
    return (9+[StringUtil getBytesDataLength:aid]);
}

-(void)sendICCCmd
{
    iccRun = YES;
    aidIndex = 0;
    while (iccRun) {
        //NSLog(@"aidIndex----->%ld",aidIndex);
        if (aidIndex == [aidArray count]) {
            aidIndex = 0;
            iccRun = NO;

            return;
        }
        Byte *frameData = [self getAidData:[aidArray objectAtIndex:aidIndex]];
        NSData *data = [self getIccCmdFrameData:frameData dataLength:[self getAidDataLength:[aidArray objectAtIndex:aidIndex]]];
        
        [_sessionController writeData:data];
        aidIndex ++;
        [NSThread sleepForTimeInterval:0.5];
    }
}
-(void)_sendOpenCommand {
    
    uint8_t buf[] = {0X55, 0x66, 0x77, 0x88, 0x4E, 0x01, 0x31, 0x33, 0x30};
    NSLog(@"open cmd---> %@", [[Global getInstance] getHexString:buf start:0 end:sizeof(buf)]);
    [_sessionController writeData:[NSData dataWithBytes:buf length:sizeof(buf)]];
}

-(void)_sendReadingCommand1 {
    
    uint8_t buf[] = {0X55, 0x66, 0x77, 0x88, 0x4E, 0x02, 0x31, 0x30, 0xFF, 0x00, 0xA4, 0x04, 0x00, 0x09, 0xA0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x3F};
    
    NSLog(@"_sendReadingCommand1: %@", [[Global getInstance] getHexString:buf start:0 end:sizeof(buf)]);
    
    [_sessionController writeData:[NSData dataWithBytes:buf length:sizeof(buf)]];
}

-(void)_sendReadingCommand2 {
    
    Byte *aidData = [self getAidData:inputAid];
    
    if(!inputAid || [inputAid isEqualToString:@""]) {
        
        NSLog(@"Error: Please input AID"); // TODO CDV CB
        return; 
    }
    if (!aidData) {
        
        NSLog(@"Error: Please input correct AID"); // TODO CDV CB
        return;
    }
    NSData *aidFrameData = [self getIccCmdFrameData:aidData dataLength:[self getAidDataLength:inputAid]];
    [_sessionController writeData:aidFrameData];
}

-(void)_sendCloseCommand {    

    uint8_t buf[] = {0X55, 0x66, 0x77, 0x88, 0x4E, 0x03, 0x31};
    NSLog(@"close cmd--->%@",[[Global getInstance]getHexString:buf start:0 end:sizeof(buf)]);
    [_sessionController writeData:[NSData dataWithBytes:buf length:sizeof(buf)]];
}

-(NSData *)getIccCmdFrameData:(Byte *)_data dataLength:(NSInteger)length {

    Byte *frameData = malloc(length+sizeof(iccFrameCmd));
    memcpy(frameData, iccFrameCmd, sizeof(iccFrameCmd));
    memcpy(frameData+sizeof(iccFrameCmd), _data, length);
    NSString *log = [[Global getInstance]getHexString:frameData start:0 end:(length+sizeof(iccFrameCmd))];
    NSLog(@"icc cmd framedata--->%@",log);
    NSData *data = [NSData dataWithBytes:frameData length:(length +sizeof(iccFrameCmd))];
    return data;
}



#pragma - Display internals



-(void)_sendDisplayCommand:(NSString *) displayStr {

    NSLog(@"_sendDisplayCommand %@",displayStr);

    // NSMutableString *displayStr = [NSMutableString stringWithFormat:@"%c",1];
    // [displayStr appendString:@"Please Insert\n"];
    // [displayStr appendString:[NSString stringWithFormat:@"%c",1]];
    // [displayStr appendString:@"IC Card"];

    NSArray *dataArray = [StringUtil convertDisplayData:displayStr timeOut:30];
    Byte *data = malloc([dataArray count]);
    for (int i=0; i<[dataArray count]; i++) {
        NSNumber *temp = [dataArray objectAtIndex:i];
        data[i] = [temp unsignedCharValue];
    }
    Byte *frameData = malloc([dataArray count]+sizeof(displayFrameCmd));
    memcpy(frameData, displayFrameCmd, sizeof(displayFrameCmd));
    memcpy(frameData+(sizeof(displayFrameCmd)), data, [dataArray count]);
    NSMutableString *s = [NSMutableString stringWithString:@""];
    for (int i=0; i<([dataArray count]+sizeof(displayFrameCmd)); i++) {
        [s appendString:[NSString stringWithFormat:@"%x",frameData[i]]];
        [s appendString:@" "];
    }
    NSLog(@"display cmd--->%@",s);
    [_sessionController writeData:[NSData dataWithBytes:frameData length:([dataArray count]+sizeof(displayFrameCmd))]];
}

@end
