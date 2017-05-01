//
//  ByteBuffer.m
//  P200DemoProject
//
//  Created by Hao Fu on 12-8-8.
//  Copyright (c) 2012年 Bluebamboo. All rights reserved.
//

#import "ByteBuffer.h"

@implementation ByteBuffer
@synthesize bufferLength;
@synthesize buffer;
-(id)initWithDataLength:(NSInteger) dataLength
{
    self = [super init];
    if(self){
        buffer = (Byte *)malloc(sizeof(Byte)*dataLength);
    }
    index = 0;
    bufferLength = dataLength;
    return self;
}
-(void)putUnsignedInt:(unsigned long)intValue
{
    memcpy(buffer+index, &intValue, 4);
    index += 4;
}
- (void)putInt:(NSInteger)intValue
{
    memcpy(buffer+index, &intValue, 4);
    index += 4;
}
-(void)putShort:(unsigned short)shortValue isBigEndian:(BOOL)flag
{
    if (flag) {
        Byte little = (Byte)shortValue ;
        Byte big = (Byte)(shortValue << 8);
        memcpy(buffer+index, &big, 1);
        index += 1;
        memcpy(buffer+index, &little, 1);
        index += 1;
    }else {
        [self putShort:shortValue];
    }
}
-(void)putShort:(unsigned short)shortValue
{
    memcpy(buffer+index, &shortValue, 2);
    index += 2;
}
-(void)putByte:(Byte) byteValue
{
    memcpy(buffer+index, &byteValue, 1);
    index += 1;
}
- (void)putBytes:(Byte *)byteArray arrayLength:(NSInteger)arrayLength
{
    memcpy(buffer+index, byteArray, arrayLength);
    index += arrayLength;
}
-(void)dealloc
{
//    free(buffer);
}
@end
