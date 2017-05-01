//
//  P200DemoSessionController.h
//  P200DemoProject
//
//  Created by Wei REN on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

extern NSString *P200DemoSessionDataReceivedNotification;

@interface P200DemoSessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate> {
    EAAccessory *_accessory;
    EASession *_session;
    NSString *_protocolString;
    NSMutableData *_writeData;
    NSMutableData *_readData;
}

+ (P200DemoSessionController *)sharedController;
- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;
- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;
//- (void)writeDate:(uint8_t) bytes maxLength:(int) length;

- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(long long)bytesToRead;

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;


@end
