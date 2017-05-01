//
//  ByteBuffer.h
//  P200DemoProject
//
//  Created by Hao Fu on 12-8-8.
//  Copyright (c) 2012年 Bluebamboo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ByteBuffer : NSObject{
    NSInteger index;
}
@property Byte *buffer;
@property NSInteger bufferLength;
-(id)initWithDataLength:(NSInteger) dataLength;
-(void)putShort:(unsigned short) shortValue;
-(void)putInt:(NSInteger) intValue;
-(void)putUnsignedInt:(unsigned long)intValue;
-(void)putByte:(Byte) byteValue;
- (void)putBytes:(Byte *) byteArray arrayLength:(NSInteger) arrayLength;
-(void)putShort:(unsigned short)shortValue isBigEndian:(BOOL)flag;
@end
