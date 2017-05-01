//
//  P200Commands.h
//  P200DemoProject
//
//  Created by Hao Fu on 8/24/12.
//  Copyright (c) 2012 BlueBamboo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ByteBuffer.h"

#define BARCODE_CODE128 0x49
#define BARCODE_EAN_8   0x03
#define BARCODE_EAN_13  0x02
#define BARCODE_UPC_A   0x00
#define BARCODE_UPC_E   0x01

#define PIN_ENCRYPTION_FIXED_KEY_3DES 0x01
#define PIN_ENCRYPTION_MK_SK_3DES     0x02
#define PIN_ENCRYPTION_DUKPT          0x03
#define PIN_ENCRYPTION_DUKPT_3DES     0x04
#define PIN_ENCRYPTION_MK_SK_DES      0x05

#define PICC_OPEN_READER  0x01
#define PICC_SEND_CMD     0x02
#define PICC_CLOSE_READER 0x03

#define PICC_APDU_CMD     0x01
#define PICC_M1_AUTH      0x10
#define PICC_M1_READ      0x11
#define PICC_M1_WRITE     0x12
#define PICC_M1_OPERATION 0x13
#define PICC_M1_OPERATION_INIT 0x14
#define PICC_M1_OPERATION_ADD         1
#define PICC_M1_OPERATION_DECREASE    2
#define PICC_M1_OPERATION_COPY        3

@interface P200Commands : NSObject
+(NSMutableArray *)getBarcodePrintingCmdWithBarcodeType:(NSInteger)barcodeType barcodeContent:(NSString *) content;
+ (ByteBuffer *)getQRcodePrintingCmdWithModuleSize:(NSInteger)moduleSize alignment:(NSInteger)alignment errorCorrectionLevel:(NSInteger)level maskingNum:(NSInteger)maskingNum content:(NSString *)content;
+ (ByteBuffer *)getPinCmdWithPan:(NSString *)pan desc:(NSString *)desc;
+ (ByteBuffer *)getPinEncryptedWithPan:(NSString *)pan desc:(NSString *)desc;

+ (BOOL)checkResponseBuf:(Byte *)buf withLength:(NSInteger)_length;
+ (NSMutableArray *)splitResponseBuf:(Byte *)buf withLength:(NSInteger)_length;

+ (ByteBuffer *)getPiccOpenReaderCmdWithTimeout:(NSInteger)timeout;
+ (ByteBuffer *)getPiccM1AuthCmdWithBlockNo:(NSInteger) blockNo serialNo:(Byte *)serialNo serialNoLength:(NSInteger) length password:(Byte *)password passwordLength:(NSInteger)pwLength;
+ (ByteBuffer *)getPiccM1ReadCmdWithBlockNo:(NSInteger)blockNo;

+ (ByteBuffer *)getPiccM1WriteCmdWithBlockNo:(NSInteger)blockNo content:(NSString *)content;
+ (ByteBuffer *)getDisplayCmdWithContent:(NSString *)content timeout:(NSInteger)timeout;

+ (ByteBuffer *)getPiccCloseReaderCmd;
+ (ByteBuffer *)getPiccM1OperationInitCmdWithBlockNo:(NSInteger)blockNo backupBlockNo:(NSInteger)backupBlockNo;
+ (ByteBuffer *)getPiccM1OperationCmdWithOperationType:(NSInteger)operationType blockNo:(NSInteger)blockNo blockData:(NSInteger)blockData backupBlockNo:(NSInteger)backupBlockNo;
+ (ByteBuffer *)getPiccApduCmdWithCmd:(Byte *)buf cmdLength:(NSInteger)cmdLength cmdData:(Byte *)cmdData cmdDataLength:(NSInteger)cmdDataLength;
@end
