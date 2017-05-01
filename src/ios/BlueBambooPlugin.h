//
//  BlueBambooPlugin.h
//  Blue Bamboo Cordova Plugin
//
//  © 2017 Thomas Fétiveau, All rights reserved.

#ifndef BlueBambooPlugin_h
#define BlueBambooPlugin_h

#import <Cordova/CDVPlugin.h>
#import <ExternalAccessory/ExternalAccessory.h>
@class P200DemoSessionController;

@interface BlueBambooPlugin : CDVPlugin {

	NSString* _connectCallbackId;
	NSString* _emvCallbackId;
	NSString* _iccCallbackId;
	NSString* _msrCallbackId;

	NSInteger _mode;
	
	// connection
	NSMutableArray *_accessoryList;
	EAAccessory *_selectedAccessory;
	P200DemoSessionController *_sessionController;
	NSArray *_supportedExternalAccessoryProtocols;
	BOOL _isConnected;

	// commons
	uint64_t _totalBytesRead;

	// ICC
	NSInteger _iccState;
	NSInteger aidIndex;
	NSMutableArray *aidArray;
	NSThread *sendAidThread;
	BOOL readSuccessfully;
	BOOL closeRes;
	BOOL iccRun;
	NSString *inputAid;

	// MSR
    NSInteger _msrState;

    // EMV
    NSInteger _emvState;
    NSInteger _amount;
    NSString *_amountStr;
    NSString *_terminalId;
    NSString *_merchantId;
    NSString *_pan;
    NSString *_printContent;
}

- (void)connect:(CDVInvokedUrlCommand *)command;
- (void)disconnect:(CDVInvokedUrlCommand *)command;
- (void)startICC:(CDVInvokedUrlCommand *)command;
- (void)startMSR:(CDVInvokedUrlCommand *)command;
- (void)startDisplay:(CDVInvokedUrlCommand *)command;
- (void)clearDisplay:(CDVInvokedUrlCommand *)command;
- (void)startEMV:(CDVInvokedUrlCommand *)command;
- (void)print:(CDVInvokedUrlCommand *)command;

@end

#endif
