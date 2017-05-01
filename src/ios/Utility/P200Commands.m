//
//  P200Commands.m
//  P200DemoProject
//
//  Created by Hao Fu on 8/24/12.
//  Copyright (c) 2012 BlueBamboo. All rights reserved.
//

#import "P200Commands.h"
#import "ByteBuffer.h"
#import "Global.h"
#import "StringUtil.h"
unsigned char head[] = {0x55,0x66,0x77,0x88};
unsigned char printHead[] = {0x55,0x66,0x77,0x88,0x44};
Byte qrcodePrintingHead[] = {0x1d,0x6b,0x50};
Byte displayHead[]={0x55,0x66,0x77,0x88,0x4f};
typedef enum{
    ADD,
    DECREASE,
    FIXED_BLOCK
}M1_OPERATION;

@implementation P200Commands
+(NSMutableArray *)getBarcodePrintingCmdWithBarcodeType:(NSInteger)barcodeType barcodeContent:(NSString *) content
{
    if((barcodeType != BARCODE_CODE128 && barcodeType != BARCODE_EAN_8
       && barcodeType !=BARCODE_EAN_13 && barcodeType != BARCODE_UPC_A 
       && barcodeType != BARCODE_UPC_E) || !content)
        return nil;
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *data = (unsigned char *)malloc(sizeof(printHead)+4+sizeof(unsigned char)*contentData.length);
    NSMutableArray *array = [[NSMutableArray alloc]init];
    memcpy(data, printHead, sizeof(printHead));
    data[5] = 0x1d;
    data[6] = 0x6b;
    switch (barcodeType) {
        case BARCODE_CODE128:
            data[7] = BARCODE_CODE128;
            data[8] = content.length;
            break;
        case BARCODE_EAN_8:
            data[7] = BARCODE_EAN_8;
            data[8] = 0x08;
            break;    
        case BARCODE_EAN_13:
            data[7] = BARCODE_EAN_13;
            data[8] = 0x0d;
            break;
        case BARCODE_UPC_A:
            data[7] = BARCODE_UPC_A;
            data[8] = 0x0c;
            break;
        case BARCODE_UPC_E:
            data[7] = BARCODE_UPC_E;
            data[8] = 0x08;
            break;
        default:
            break;
    }
#pragma mark Leo change the unsigned to const
    const char *contentBytes = [contentData bytes];
    memcpy(data+9, contentBytes, contentData.length);
    for(int i=0;i<(9+contentData.length);i++){
        NSNumber *number = [NSNumber numberWithUnsignedChar:data[i]];
        [array insertObject:number atIndex:i];
    }
    return array;
}
+ (ByteBuffer *)getQRcodePrintingCmdWithModuleSize:(NSInteger)moduleSize alignment:(NSInteger)alignment errorCorrectionLevel:(NSInteger)level maskingNum:(NSInteger)maskingNum content:(NSString *)content
{
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
#pragma mark Leo change the unsigned char to bytes 
    //Byte *contentBytes = [contentData bytes];
    const unsigned  char *contentByte= (const unsigned  char *)([contentData bytes]);
    Byte *contentBytes = (Byte *)contentByte;
    
    ByteBuffer *buffer = [[ByteBuffer alloc]initWithDataLength:(contentData.length + sizeof(printHead)+sizeof(qrcodePrintingHead)+6)];
    [buffer putBytes:printHead arrayLength:sizeof(printHead)];
    
    [buffer putBytes:qrcodePrintingHead arrayLength:sizeof(qrcodePrintingHead)];
    
    [buffer putByte:(Byte)moduleSize];
    [buffer putByte:(Byte)alignment];
    [buffer putByte:(Byte)level];
    [buffer putByte:(Byte)maskingNum];
    
    unsigned short len = (unsigned short)contentData.length;
    [buffer putShort:len isBigEndian:YES];
    [buffer putBytes:contentBytes arrayLength:contentData.length];
    return buffer;
}
+ (ByteBuffer *)getPinCmdWithPan:(NSString *)pan desc:(NSString *)desc
{
    ByteBuffer *data = nil;
    if(desc == nil || [desc isEqualToString:@""]){
        return nil;
    }
    NSData *descData = [desc dataUsingEncoding:NSUTF8StringEncoding];
    if(pan == nil || [pan isEqualToString:@""]){
        data = [[ByteBuffer alloc]initWithDataLength:(sizeof(head)+1+4+descData.length)];
        [data putBytes:head arrayLength:sizeof(head)];
        [data putByte:FRAME_TOF_PIN];
        [data putByte:PIN_ENCRYPTION_DUKPT];
        [data putByte:0x00];
        [data putByte:descData.length];
        [data putBytes:(Byte *)[descData bytes] arrayLength:descData.length];
        [data putByte:0x01];//keyIndex;
    }else {
        NSData *panData = [pan dataUsingEncoding:NSUTF8StringEncoding];
        data = [[ByteBuffer alloc]initWithDataLength:(sizeof(head)+1+4+panData.length+descData.length) ];
        [data putBytes:head arrayLength:sizeof(head)];
        [data putByte:FRAME_TOF_PIN];
        [data putByte:PIN_ENCRYPTION_DUKPT];
        [data putByte:panData.length];
#pragma mark Leo change the char to byte
        Byte *byte1 = (Byte *)[panData bytes];
        [data putBytes:byte1 arrayLength:panData.length];
        [data putByte:descData.length];
#pragma mark Leo change the char to byte
        Byte *byte2 = (Byte *)[descData bytes];
        [data putBytes:byte2 arrayLength:descData.length];
        [data putByte:0x01];//keyIndex;
    }
    return data;
}

+ (ByteBuffer *)getPinEncryptedWithPan:(NSString *)pan desc:(NSString *)desc
{
    ByteBuffer *data = nil;
    if(desc == nil || [desc isEqualToString:@""]){
        return nil;
    }
    NSData *descData = [desc dataUsingEncoding:NSUTF8StringEncoding];
    if(pan == nil || [pan isEqualToString:@""]){
        data = [[ByteBuffer alloc]initWithDataLength:(sizeof(head)+1+4+descData.length+17)];
        [data putBytes:head arrayLength:sizeof(head)];
        [data putByte:FRAME_TOF_PIN];
        [data putByte:PIN_ENCRYPTION_MK_SK_3DES];
        [data putByte:0x00];
        [data putByte:descData.length];
        [data putBytes:(Byte *)[descData bytes] arrayLength:descData.length];
        [data putByte:0x01];//keyIndex;
        [data putByte:0x10];//session key lenth
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];//session key
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
    }else {
        NSData *panData = [pan dataUsingEncoding:NSUTF8StringEncoding];
        data = [[ByteBuffer alloc]initWithDataLength:(sizeof(head)+1+4+panData.length+descData.length+17) ];
        [data putBytes:head arrayLength:sizeof(head)];
        [data putByte:FRAME_TOF_PIN];
        [data putByte:PIN_ENCRYPTION_MK_SK_3DES];
        [data putByte:panData.length];
#pragma mark Leo change the char to byte
        Byte *byte1 = (Byte *)[panData bytes];
        [data putBytes:byte1 arrayLength:panData.length];
        [data putByte:descData.length];
#pragma mark Leo change the char to byte
        Byte *byte2 = (Byte *)[descData bytes];
        [data putBytes:byte2 arrayLength:descData.length];
        [data putByte:0x01];//keyIndex;
        [data putByte:0x10];//session key lenth
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];//session key
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        [data putByte:0x11];
        
    }
    return data;
}
+ (BOOL)checkResponseBuf:(Byte *)buf withLength:(NSInteger)_length
{
    if (!buf || _length < 4) {
        return NO;
    }
    if(buf[0] == 0x55 && buf[1] == 0x66
       && buf[2] == 0x77 && buf[3] == 0x88){
        return YES;
    }else {
        return NO;
    }
}
+ (NSMutableArray *)splitResponseBuf:(Byte *)buf withLength:(NSInteger)_length
{
    NSMutableArray *indexArray = [[NSMutableArray alloc]init];
    NSMutableArray *cmdArray = [[NSMutableArray alloc]init];
    for (int i=0; i<_length; i++) {
        if (i != _length - 3) {
            if (buf[i] == 0x55 && buf[i+1] == 0x66 
                && buf[i+2] == 0x77 && buf[i+3] == 0x88) {
                NSNumber *num = [[NSNumber alloc]initWithInt:i];
                [indexArray addObject:num];
            }
        }
        
    }
    NSLog(@"index count---->%lu",(unsigned long)[indexArray count]);
    for (int i=0; i < [indexArray count]; i++) {
        if(i != [indexArray count] - 1){
            NSNumber *num1 = [indexArray objectAtIndex:i];
            int index1 = [num1 intValue];
            NSNumber *num2 = [indexArray objectAtIndex:i+1];
            int index2 = [num2 intValue];
            Byte *cmd = malloc(index2 - index1);
            for (int j=0; j<(index2-index1); j++) {
                cmd[j] = buf[index1+j];
            }
            NSData *cmdData = [NSData dataWithBytes:cmd length:index2 - index1 ];
            [cmdArray addObject:cmdData];
            
        }else {
            int index = [[indexArray objectAtIndex:i]intValue];
            Byte *cmd = malloc(_length - index);
            for (int j=0; j<(_length - index); j++) {
                cmd[j] = buf[index+j];
            }
            NSData *cmdData = [NSData dataWithBytes:cmd length:(_length - index)];
            [cmdArray addObject:cmdData];
            
        }
    }
    return cmdArray;
}
+ (ByteBuffer *)getPiccOpenReaderCmdWithTimeout:(NSInteger)timeout
{
    if (timeout < 1 || timeout > 30) {
        NSLog(@"Error(P200Commands->getPiccOpenReaderCmdWithTimeout):param timeout must be 1~30");
        return nil;
    }
    NSString *time = @"";
    if(timeout < 10){
        time = [time stringByAppendingString:@"0"];
        time = [time stringByAppendingFormat:@"%ld",(long)timeout];
    }else {
        time = [time stringByAppendingFormat:@"%ld",(long)timeout];
    }
    ByteBuffer *data = [[ByteBuffer alloc]initWithDataLength:(sizeof(head)+4)];
    [data putBytes:head arrayLength:sizeof(head)];
    [data putByte:FRAME_TOF_PICC];
    [data putByte:PICC_OPEN_READER];
    [data putByte:[time characterAtIndex:0]];
    [data putByte:[time characterAtIndex:1]];
    return data;
}
+ (ByteBuffer *)getPiccM1AuthCmdWithBlockNo:(NSInteger) blockNo serialNo:(Byte *)serialNo serialNoLength:(NSInteger) length password:(Byte *)password passwordLength:(NSInteger)pwLength
{
    if (blockNo < 0x00 || blockNo > 0x3f) {
        NSLog(@"Error(P200Commands->getPiccM1AuthCmdWithBlockNo):param blockNo must be 0x00~0x3f");
        return nil;
    }
    if (!serialNo) {
        NSLog(@"Error(P200Commands->getPiccM1AuthCmdWithBlockNo):param serialNo must not be null");
        return nil;
    }
    if (length != 4) {
        NSLog(@"Error(P200Commands->getPiccM1AuthCmdWithBlockNo):param serialNoLength must be 4");
        return nil;
    }
    if (pwLength != 6) {
        NSLog(@"Error(P200Commands->getPiccM1AuthCmdWithBlockNo):param passwordLength must be 6");
        return nil;
    }
    ByteBuffer *data = [[ByteBuffer alloc]initWithDataLength:(sizeof(head)+15)];
    [data putBytes:head arrayLength:sizeof(head)];
    [data putByte:FRAME_TOF_PICC];
    [data putByte:PICC_SEND_CMD];
    [data putByte:PICC_M1_AUTH];
    [data putByte:0x0a];
    [data putByte:blockNo];
//    Byte pwd[] = {0xff,0xff,0xff,0xff,0xff,0xff};
    [data putBytes:password arrayLength:pwLength];
    [data putBytes:serialNo arrayLength:length];
    return data;
}
+ (ByteBuffer *)getPiccM1ReadCmdWithBlockNo:(NSInteger)blockNo
{
    if (blockNo < 0x00 || blockNo > 0x3f) {
        NSLog(@"Error(P200Commands->getPiccM1ReadCmdWithBlockNo):param blockNo must be 0x00~0x3f");
        return nil;
    }
    ByteBuffer *data = [[ByteBuffer alloc]initWithDataLength:sizeof(head)+4];
    [data putBytes:head arrayLength:sizeof(head)];
    [data putByte:FRAME_TOF_PICC];
    [data putByte:PICC_SEND_CMD];
    [data putByte:PICC_M1_READ];
    [data putByte:blockNo];
    return data;
}
+ (ByteBuffer *)getPiccM1WriteCmdWithBlockNo:(NSInteger)blockNo content:(NSString *)content
{
    if(blockNo < 0x00 || blockNo > 0x3f){
        NSLog(@"Error(P200Commands->getPiccM1WriteCmd):param blockNo must be 0x00~0x3f");
        return nil;
    }
    if (!content || [content length] == 0
        || [[content dataUsingEncoding:NSUTF8StringEncoding]length] > 16) {
        NSLog(@"Error(P200Commands->getPiccM1WriteCmd):param content must be 1~16 byte(s)");
        return nil;
    }
    NSInteger length = [[content dataUsingEncoding:NSUTF8StringEncoding]length] + 5 + sizeof(head);
    ByteBuffer *data = [[ByteBuffer alloc]initWithDataLength:length];
    [data putBytes:head arrayLength:sizeof(head)];
    [data putByte:FRAME_TOF_PICC];
    [data putByte:PICC_SEND_CMD];
    [data putByte:PICC_M1_WRITE];
    [data putByte:blockNo];
    [data putByte:[[content dataUsingEncoding:NSUTF8StringEncoding]length]];
    [data putBytes:(Byte *)[[content dataUsingEncoding:NSUTF8StringEncoding]bytes] arrayLength:[[content dataUsingEncoding:NSUTF8StringEncoding]length]];
    return data;
}
+ (ByteBuffer *)getPiccCloseReaderCmd
{
    ByteBuffer *data = [[ByteBuffer alloc]initWithDataLength:(sizeof(head)+2)];
    [data putBytes:head arrayLength:sizeof(head)];
    [data putByte:FRAME_TOF_PICC];
    [data putByte:PICC_CLOSE_READER];
    return data;
}
+ (ByteBuffer *)getDisplayCmdWithContent:(NSString *)content timeout:(NSInteger)timeout
{
    NSMutableArray *dataArray = [StringUtil convertDisplayData:content timeOut:timeout];
    Byte *data = malloc([dataArray count]);
    for (int i=0; i<[dataArray count]; i++) {
        NSNumber *temp = [dataArray objectAtIndex:i];
        data[i] = [temp unsignedCharValue];
    }
    ByteBuffer *buffer = [[ByteBuffer alloc]initWithDataLength:sizeof(displayHead)+[dataArray count]];
    [buffer putBytes:displayHead arrayLength:sizeof(displayHead)];
    [buffer putBytes:data arrayLength:[dataArray count]];
    free(data);
    return buffer;
}
+ (ByteBuffer *)getPiccM1OperationInitCmdWithBlockNo:(NSInteger)blockNo backupBlockNo:(NSInteger)backupBlockNo
{
    if(blockNo < 0x00 || blockNo > 0x3f){
        NSLog(@"Error(P200Commands->getPiccM1OperationInitCmd):param blockNo must be 0x00~0x3f");
        return nil;
    }
    if(backupBlockNo < 0x00 || backupBlockNo > 0x3f){
        NSLog(@"Error(P200Commands->getPiccM1OperationInitCmd):param backupBlockNo must be 0x00~0x3f");
        return nil;
    }
    ByteBuffer *data = [[ByteBuffer alloc]initWithDataLength:sizeof(head) + 5];
    [data putBytes:head arrayLength:sizeof(head)];
    [data putByte:FRAME_TOF_PICC];
    [data putByte:PICC_SEND_CMD];
    [data putByte:PICC_M1_OPERATION_INIT];
    [data putByte:blockNo];
    [data putByte:backupBlockNo];
    return data;
}
+ (ByteBuffer *)getPiccM1OperationCmdWithOperationType:(NSInteger)operationType blockNo:(NSInteger)blockNo blockData:(NSInteger)blockData backupBlockNo:(NSInteger)backupBlockNo
{
    if(blockNo < 0x00 || blockNo > 0x3f){
        NSLog(@"Error(P200Commands->getPiccM1OperationCmd):param blockNo must be 0x00~0x3f");
        return nil;
    }
    if(backupBlockNo < 0x00 || backupBlockNo > 0x3f){
        NSLog(@"Error(P200Commands->getPiccM1OperationCmd):param backupBlockNo must be 0x00~0x3f");
        return nil;
    }
    ByteBuffer *data = [[ByteBuffer alloc]initWithDataLength:sizeof(head) + 10 ];
    [data putBytes:head arrayLength:sizeof(head)];
    [data putByte:FRAME_TOF_PICC];
    [data putByte:PICC_SEND_CMD];
    [data putByte:PICC_M1_OPERATION];
    switch (operationType) {
        case PICC_M1_OPERATION_ADD:
            [data putByte:'+'];
            break;
        case PICC_M1_OPERATION_DECREASE:
            [data putByte:'-'];
            break;
        case PICC_M1_OPERATION_COPY:
            [data putByte:'='];
            break;
        default:
            break;
    }
    [data putByte:blockNo];
    [data putInt:blockData];
    [data putByte:backupBlockNo];
    return data;
}
+ (ByteBuffer *)getPiccApduCmdWithCmd:(Byte *)cmd cmdLength:(NSInteger)cmdLength cmdData:(Byte *)cmdData cmdDataLength:(NSInteger)cmdDataLength
{
    if (!cmd) {
        NSLog(@"Error(P200Commands->getPiccApduCmd):param cmd must not be null");
        return nil;
    }
    if (cmdLength == 0) {
        NSLog(@"Error(P200Commands->getPiccApduCmd):param cmdLength must not be 0");
        return nil;
    }
    if (!cmdData) {
        NSLog(@"Error(P200Commands->getPiccApduCmd):param cmdData must not be null");
        return nil;
    }
    if (cmdDataLength == 0) {
        NSLog(@"Error(P200Commands->getPiccApduCmd):param cmdDataLength must not be 0");
        return nil;
    }
    
    ByteBuffer *data = [[ByteBuffer alloc]initWithDataLength:(sizeof(head)+5+cmdLength+cmdDataLength)];
    [data putBytes:head arrayLength:sizeof(head)];
    [data putByte:FRAME_TOF_PICC];
    [data putByte:PICC_SEND_CMD];
    [data putByte:PICC_APDU_CMD];
    [data putByte:0xff];
    [data putBytes:cmd arrayLength:cmdLength];
    [data putByte:cmdDataLength];
    [data putBytes:cmdData arrayLength:cmdDataLength];
    return data;
}
@end
