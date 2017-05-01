//
//  StringUtil.m
//  P200DemoProject
//
//  Created by Hao Fu on 8/16/12.
//  Copyright (c) 2012 BlueBamboo. All rights reserved.
//

#import "StringUtil.h"
#import "Global.h"

@implementation StringUtil
+(Byte *)hexStringToBytes:(NSString *)hexString Offset:(NSInteger)offset Count:(NSInteger)count
{
    if(!hexString || offset < 0 || count < 2 || (offset + count) > [hexString length]
        || (count % 2 != 0)){
        return nil;
    }
    
    Byte *buffer = malloc((sizeof(Byte)*count)>>1);
    NSInteger stringLength = offset + count;
    NSInteger byteIndex = 0;
    for(NSInteger i=offset;i<stringLength;i+=2){
        unichar ch = [hexString characterAtIndex:i];
        if(ch == ' ')
            i++;
        unichar ch1 = [hexString characterAtIndex:i];
        unichar ch2 = [hexString characterAtIndex:(i+1)];
        NSInteger temp1 = [StringUtil isHexChar:ch1];
        NSInteger temp2 = [StringUtil isHexChar:ch2];
        if (temp1 < 0 || temp2 < 0) {
            return nil;
        }
        Byte hex = [StringUtil isHexChar:ch1] << 4;
        hex |= ([StringUtil isHexChar:ch2]<<4) >> 4;
        buffer[byteIndex] = hex;
        byteIndex++;
    }
    return buffer;
}
+(Byte *)hexStringToBytes:(NSString *)hexString
{
    return [StringUtil hexStringToBytes:hexString Offset:0 Count:(NSInteger)[hexString length]];
}
+(NSInteger)getBytesDataLength:(NSString *)hexString
{
    NSInteger offset = 0;
    NSInteger count = [hexString length];
    Byte *buffer = malloc((sizeof(Byte)*count)>>1);
    NSInteger stringLength = offset + count;
    NSInteger byteIndex = 0;
    for(NSInteger i=offset;i<stringLength;i+=2){
        unichar ch = [hexString characterAtIndex:i];
        if(ch == ' ')
            i++;
        unichar ch1 = [hexString characterAtIndex:i];
        unichar ch2 = [hexString characterAtIndex:(i+1)];
        Byte hex = [StringUtil isHexChar:ch1] << 4;
        if(hex < 0)
            return -1;
        hex |= ([StringUtil isHexChar:ch2]<<4) >> 4;
        if(hex < 0)
            return -1;
        buffer[byteIndex] = hex;
        byteIndex++;
    }
    return byteIndex;
}
+(NSInteger) isHexChar:(unichar) ch
{
    if('a' <= ch && ch <= 'f')
        return  ch - 'a' + 10;
    if('A' <= ch && ch <= 'F')
        return ch - 'A' + 10;
    if('0' <= ch && ch <= '9')
        return ch - '0';
    return -1;
}
+(NSMutableArray *)convertDisplayData:(NSString *)content timeOut:(NSInteger)timeout
{
    NSMutableString *contents = [NSMutableString stringWithFormat:@"%c",3];
    [contents appendString:[NSString stringWithFormat:@"%ld",(long)timeout]];
    NSArray *contentArray = [content componentsSeparatedByString:@"\n"];
    for(int i=0;i<[contentArray count];i++){
        NSString *temp = [contentArray objectAtIndex:i];
        unichar alignFlag = [temp characterAtIndex:0];
        NSString *_content = [temp substringFromIndex:1];
//        NSLog(@"_content---->%@",_content);
        NSInteger _contentLength = [_content length];
        Byte b = i+0x31;
        NSMutableString *line = [NSMutableString stringWithFormat:@"%c",b];
        [line appendFormat:@"%c",alignFlag];
        Byte len = _contentLength;
        [line appendFormat:@"%c",len];
        [line appendString:_content];
        [contents appendString:line];
        
    }
    NSLog(@"display str----->%@",contents);
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
    Byte *contentData =(Byte *) [data bytes];
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    for(int i=0;i<[data length];i++){
        NSNumber *number = [NSNumber numberWithUnsignedChar:contentData[i]];
        [dataArray insertObject:number atIndex:i];
    }
//    NSMutableString *log = [NSMutableString stringWithString:@""];
//    for (int i=0; i<[data length]; i++) {
//        [log appendString:@" "];
//        [log appendFormat:@"%x",contentData[i]];
//    }
//    NSLog(@"display data---->%@",log);
    return dataArray;
}
+(BOOL)isAllNumOrChar:(NSString *)string
{
    BOOL res = YES;
    for (NSInteger i=0; i<string.length; i++) {
        unichar ch = [string characterAtIndex:i];
        if((ch <= 'z' && ch >= 'a')
           || (ch <= 'Z' && ch >= 'A')
           || (ch <= '9' && ch >= '0')){
            
        }else {
            res = NO;
            break;
        }
    }
    return res;
}
+(BOOL)isAllHexNum:(NSString *)string
{
    BOOL res = YES;
    for (int i=0; i<string.length; i++) {
        unichar ch = [string characterAtIndex:i];
        if((ch <= 'f' && ch >= 'a')
           || (ch <= 'F' && ch >= 'A')
           || (ch <= '9' && ch >= '0')){
            
        }else {
            res = NO;
            break;
        }
    }
    return res;
}
+ (BOOL)isAllNum:(NSString *)string
{
    BOOL res = YES;
    for (int i=0; i<string.length; i++) {
        unichar ch = [string characterAtIndex:i];
        if(ch <= '9' && ch >= '0'){
            
        }else {
            res = NO;
            break;
        }
    }
    return res;
}
+ (NSString *)asciiBytesToString:(Byte *)buffer offset:(NSInteger)offset count:(NSInteger)count
{
    Byte strBuf[32];
    NSLog(@"bu-->%@",[[Global getInstance]getHexString:buffer start:offset end:offset+count]);
    
    for (int i=0; i < (offset + count); i++) {
        if (buffer[offset+i] >= 0x20 && buffer[offset+i] <= 0x7e) {
            strBuf[i] = buffer[offset + i];
        }else {
            strBuf[i] = ' ';
        }
        
    }
    NSString *str = [[NSString alloc]initWithBytes:strBuf length:count encoding:NSASCIIStringEncoding];
    return str;
}
@end
