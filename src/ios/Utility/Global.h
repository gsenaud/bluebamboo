//
//  Global.h
//  P200DemoProject
//
//  Created by Wei REN on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_LOG_MODE 1

#define STATE_ALERT_ROOT_LANGUAGE_DONE 11
#define STATE_ALERT_ROOT_NOT_CONNECTED 12

#define STATE_MENU_ROOT_MAIN_MENU 11
#define STATE_MENU_ROOT_ACCESSORY_LIST 12

#define STATE_PRINTER 10
#define STATE_PRINTER_PRINT_TEXT 11
#define STATE_PRINTER_PRINT_IMAGE 12
#define STATE_PRINTER_PRINT_BARCODE 13
#define STATE_PRINTER_PRINT_EMPTY_LINE 14
#define STATE_PRINTER_PRINT_QRCODE 15

#define STATE_PRINTER_PRINT_BMP1 121

#define STATE_MSR 20
#define STATE_MSR_DISPLAY 21
#define STATE_MSR_COMMAND 22
#define STATE_MSR_ENCRYPTED_COMMAND 23

#define STATE_PIN 30

#define STATE_ICC 50
#define STATE_ICC_TURN_ON 51
#define STATE_ICC_CMD1 52
#define STATE_ICC_CMD2 53
#define STATE_ICC_TURN_OFF 54
#define STATE_ICC_CMD3 55

#define STATE_EMV 60
#define STATE_EMV_INIT 61
#define STATE_EMV_AUTHORIZE 62
#define STATE_EMV_AUTHORIZE_ONLINE 63
#define STATE_EMV_COMFIRMATION 64
#define STATE_EMV_GET_TERMINAL_ID 65
#define STATE_EMV_SET_LANGUAGE 66
#define STATE_EMV_FAILED 67
#define STATE_EMV_GET_MERCHANT_ID 68
#define STATE_EMV_UPDATE_PARAM 69
#define STATE_EMV_PRINT_RECEIPT 71
#define STATE_EMV_ENTER_PASSWORD 72
#define STATE_EMV_SET_PIN_ENTER_MODE 73

#define FRAME_ACK 0x06
#define FRAME_TOF_PRINT 0x44
#define FRAME_TOF_EMV 0x45
#define FRAME_TOF_MSR 0x48
#define FRAME_TOF_MSR_BACK 0x84
#define FRAME_TOF_PIN 0x4D
#define FRAME_TOF_ICC 0x4E
#define FRAME_TOF_DISPLAY 0x4F
#define FRAME_TOF_PICC 0x40

#define TAG_DISPLAY_ALIGH_CENTER 0x01
#define TAG_DISPLAY_ALIGH_RIGHT 0x02
#define TAG_DISPLAY_ALIGH_LEFT 0x03

#define TAG_ICC_SEND_COMMAND 0x02
#define TAG_ICC_SLOT_ICC 0x31

static int receiptId = 0;

extern NSString * const defaultProtocolString;
extern BOOL cardSwiped;

@interface Global : NSObject {
    
}

+ (Global *)getInstance;

- (NSString *)getHexString:(void *)buffer start:(NSInteger)startIndex end:(NSInteger)endIndex;
- (NSString *)getHexString2:(void *)buffer start:(NSInteger)startIndex end:(NSInteger)endIndex;
@end
