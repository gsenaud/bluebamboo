//
//  BmpUtil.h
//  P200DemoProject
//
//  Created by Hao Fu on 8/8/12.
//  Copyright (c) 2012 BlueBamboo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ByteBuffer.h"
@interface BmpUtil : NSObject
+(ByteBuffer *) getBmpDataWithWidth:(NSInteger)width andHeight:(NSInteger)height andBitmap:(unsigned char *)bitmap andBitDataL:(NSInteger)bitmapDataLength;
+(Byte)getThreshold:(Byte *)grayLevel;
@end
