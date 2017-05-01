//
//  BmpUtil.m
//  P200DemoProject
//
//  Created by Hao Fu on 8/8/12.
//  Copyright (c) 2012 BlueBamboo. All rights reserved.
//

#import "BmpUtil.h"
#import "ByteBuffer.h"

@implementation BmpUtil

+(ByteBuffer *) getBmpDataWithWidth:(NSInteger) width andHeight:(NSInteger)height andBitmap:(unsigned char *)bitmap andBitDataL:(NSInteger)bitmapDataLength
{
    //bitmapfileheader
    unsigned short bfType = 0x4d42;
    unsigned long   bfSize;
    unsigned short bfReserved1 = 0;
    unsigned short bfReserved2 = 0;
    unsigned long   bfOffBits = 62;
    //bitmapinfoheader
    unsigned long biSize = 40;
    NSInteger          biWidth = width;
    NSInteger          biHeight = height;
    unsigned short biPlanes = 1;
    unsigned short biBitCount = 1;
    unsigned long   biCompression = 0;
    unsigned long   biSizeImage;
    NSInteger            biXPelsPerMeter = 0;
    NSInteger            biYPelsPerMeter = 0;
    unsigned long   biClrUsed = 2;
    unsigned long   biClrImportant = 0;

    NSInteger r = width % 8;
    NSInteger n = width / 8;
    NSInteger rb = n;
    if(r > 0)
        rb++;
    NSInteger nc = 0;
    if((rb%4) > 0)
        nc = 4 - rb%4;
    else if(rb<4)
        nc = 4 - rb;
    NSInteger dataSize = (rb+nc)*height;

    bfSize = 62 + dataSize;
    biSizeImage = dataSize;

    ByteBuffer *buffer = [[ByteBuffer alloc]initWithDataLength:bfSize];
    
    [buffer putShort:bfType];
    [buffer putInt:bfSize];
    [buffer putShort:bfReserved1];
    [buffer putShort:bfReserved2];
    [buffer putInt:bfOffBits];
    
    [buffer putInt:biSize];
    [buffer putInt:biWidth];
    [buffer putInt:biHeight];
    [buffer putShort:biPlanes];
    [buffer putShort:biBitCount];
    [buffer putInt:biCompression];
    [buffer putInt:biSizeImage];
    [buffer putInt:biXPelsPerMeter];
    [buffer putInt:biYPelsPerMeter];
    [buffer putInt:biClrUsed];
    [buffer putInt:biClrImportant];
    
    [buffer putInt:0];
    [buffer putInt:0x00ffffff];
    //NSLog(@"bitmapDataLeng--->%d",bitmapDataLength);

    
    Byte *gray = (Byte *)malloc(bitmapDataLength / 4);
    Byte grayLevel[256];
    memset(grayLevel, 0, 256);
    
    for(NSInteger i=0;i<bitmapDataLength;i+=4){
        unsigned char R = bitmap[i];
        unsigned char G = bitmap[i+1];
        unsigned char B = bitmap[i+2];
//        NSLog(@"R->%d,G->%d,B->%d",R,G,B);
        Byte grayColor = (299*R+578*G+115*B) / 1000;
        gray[i/4] = grayColor;
        grayLevel[grayColor]++;
    }
//    Byte T = [BmpUtil getThreshold:grayLevel];
    Byte T = 128;
    NSLog(@"t--->%d",T);
//    unsigned char T = 128;
    for (NSInteger i=height - 1;i >= 0 ; i--) {
        Byte b = 0;
        NSInteger k = 0;
        for (int j=0; j<n ; j++) {
            b = 0;
            for (k=0;k<8; k++) {
                b |= ((Byte)(gray[i*width+j*8+k]>T ? 1:0)) << (7-k);
            }
            [buffer putByte:b];
        }
        if (r>0) {
            b = 0;
            k=0;
            while (k<r) {
                b |= ((Byte)(gray[i*width + n*8 +k] > T ? 1:0)) <<(7-k);
                k++;
            }
            [buffer putByte:b];
        }
        k=0;
        while (k<nc) {
            [buffer putByte:0];
            k++;
        }
    }
    free(gray);
    return buffer;
}
+(Byte)getThreshold:(Byte *)grayLevel
{
    Byte peak1 = 0;
    NSInteger index1 = 0;
    Byte peak2 = 0;
    NSInteger index2= 0;
    Byte T=0;
    //取第一个波峰
    for (int i=0; i<256; i++) {
        if(peak1 < grayLevel[i]){
            peak1 = grayLevel[i];
            index1 = i;
        }
    }
    for (int i=0; i<256; i++) {
        if (peak2 < grayLevel[i] && i!=index1) {
            peak2 = grayLevel[i];
            index2 = i;
        }
    }
    if(index2 <index1){
        NSInteger temp = index1 ;
        index1 = index2;
        index2 = temp;
    }
    int temp = peak1;
    for (NSInteger i=index1; i<index2; i++) {
        if(temp >grayLevel[i]){
            temp = grayLevel[i];
            T = i;
        }
    }
    return T;
}
@end
