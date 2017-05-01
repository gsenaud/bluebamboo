//
//  StringUtil.h
//  P200DemoProject
//
//  Created by Hao Fu on 8/16/12.
//  Copyright (c) 2012 BlueBamboo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtil : NSObject
+(Byte *)hexStringToBytes:(NSString *)hexString Offset:(NSInteger)offset Count:(NSInteger)count;
+(Byte *)hexStringToBytes:(NSString *)hexString;
+(NSInteger)getBytesDataLength:(NSString *)hexString;
+(NSMutableArray *) convertDisplayData:(NSString *)content timeOut:(NSInteger)timeout;
+(BOOL)isAllNumOrChar:(NSString *)string;
+(BOOL)isAllNum:(NSString *)string;
+(BOOL)isAllHexNum:(NSString *)string;
+ (NSString *)asciiBytesToString:(Byte *)buffer offset:(NSInteger)offset count:(NSInteger)count;
@end
