//
//  Global.m
//  P200DemoProject
//
//  Created by Wei REN on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Global.h"

NSString * const defaultProtocolString = @"com.bluebamboo.p200";
BOOL cardSwiped = NO;

@implementation Global

static Global *instance;

+ (Global *)getInstance {
    @synchronized(self) {
        if(instance == nil) {
            instance = [[self alloc]init];
        }
        return instance;
    }
}

- (NSString *)getHexString:(void *)buffer start:(NSInteger)startIndex end:(NSInteger)endIndex {
    
    NSString *bufferStr = @"";
    Byte *buf = (Byte *)buffer;
    for(NSInteger i = startIndex; i < endIndex; i ++) {
        bufferStr = [bufferStr stringByAppendingFormat:@"%02X ",buf[i]];
    }
    return bufferStr;
}
- (NSString *)getHexString2:(void *)buffer start:(NSInteger)startIndex end:(NSInteger)endIndex {
    
    NSString *bufferStr = @"";
    Byte *buf = (Byte *)buffer;
    for(NSInteger i = startIndex; i < endIndex; i ++) {
        bufferStr = [bufferStr stringByAppendingFormat:@"0x%02X ",  buf[i]];
    }
    return bufferStr;
}
@end
