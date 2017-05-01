//
//  EmvResult.m
//  P200Demo
//
//  Created by BlueBabmoo Shanghai on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmvResult.h"

@interface EmvResult ()
@end

@implementation EmvResult

@synthesize status;
@synthesize result;
@synthesize ac;
@synthesize cid;
@synthesize iad;
@synthesize uniNumber;
@synthesize atc;
@synthesize tvr;
@synthesize tsi;
@synthesize transDate;
@synthesize transTime;
@synthesize transType;
@synthesize amount;
@synthesize tcc;
@synthesize aip;
@synthesize termCountryCode;
@synthesize amountOther;
@synthesize termCap;
@synthesize cvr;
@synthesize termType;
@synthesize idsn;
@synthesize dfName;
@synthesize termAppVersion;
@synthesize sequenceCounter;
@synthesize trackII;
@synthesize pan;
@synthesize expiredDate;
@synthesize transCurrencyCode;

- (id)initWithSring:(NSString *)xmlString {
    self = [super init];
    if (self) {
        status = [[NSString alloc]init];
        result = [[NSString alloc]init];
        NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
        NSXMLParser *logonParser = [[NSXMLParser alloc] initWithData:xmlData];
        [logonParser setDelegate:self];
        [logonParser setShouldResolveExternalEntities:YES];
        [logonParser parse];
    }
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"didStartElement qName %@", elementName);
    if([elementName isEqualToString:@"Response"]) {
        status = [attributeDict valueForKey:@"status"];
    }
    _eName = elementName;
    _isSetting = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //    NSLog(@"foundCharacters qName %@", _eName);
    //    NSLog(@"foundCharacters string %@", string);
    if((!_isSetting)) {
        
        if ([_eName isEqualToString:@"Result"]) {
            self.result = string;
            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"AC"]) {
            self.ac = string;

//            NSLog(@"foundCharacters self.ac = %@ ",self.ac);
        }
        if([_eName isEqualToString:@"CID"]) {
            self.cid = string;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"IAD"]) {
            self.iad = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"UniNumber"]) {
            self.uniNumber = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"ATC"]) {
            self.atc = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TVR"])  {
            self.tvr = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TSI"]) {
            self.tsi = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TransDate"]) {
            self.transDate = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TransTime"]) {
            self.transTime = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TransType"]) {
            self.transType = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"Amount"]) {
            self.amount = string;
            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TCC"]) {
            self.tcc = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"AIP"]) {
            self.aip = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TermCountryCode"]) {
            self.termCountryCode= string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"AmountOther"]) {
            self.amountOther = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TermCap"]) {
            self.termCap = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"CVR"]) {
            self.cvr = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TermType"]) {
            self.termType = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"IDSN"]) {
            self.idsn = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"DFName"]) {
            self.dfName = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TermAppVersion"]) {
            self.termAppVersion = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"SequenceCounter"]) {
            self.sequenceCounter = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TrackII"]) {
            self.trackII = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"PAN"]) {
            self.pan = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"ExpiredDate"]) {
            self.expiredDate = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        if ([_eName isEqualToString:@"TransCurrencyCode"]) {
            self.transCurrencyCode = string;
            //testClass.result = result;

            //          NSLog(@"foundCharacters result = %@ ",result);
        }
        _isSetting=YES;
    }
}

@end
