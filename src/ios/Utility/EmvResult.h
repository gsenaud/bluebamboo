//
//  EmvResult.h
//  P200Demo
//
//  Created by BlueBabmoo Shanghai on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmvResult : NSObject <NSXMLParserDelegate>
{
    NSString *status;
    NSString *result;
    NSString *ac;
    NSString *cid;
    NSString *iad;
    NSString *uniNumber;
    NSString *atc;
    NSString *tvr;
    NSString *tsi;
    NSString *transDate;
    NSString *transTime;
    NSString *transType;
    NSString *amount;
    NSString *tcc;
    NSString *aip;
    NSString *termCountryCode;
    NSString *amountOther;
    NSString *termCap;
    NSString *cvr;
    NSString *termType;
    NSString *idsn;
    NSString *dfName;
    NSString *termAppVersion;
    NSString *sequenceCounter;
    NSString *trackII;
    NSString *pan;
    NSString *expiredDate;
    NSString *transCurrencyCode;
    
    NSString *_eName;
    NSString *_eValue;
    BOOL _isSetting;
}

@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, retain) NSString *ac;
@property (nonatomic, retain) NSString *cid;
@property (nonatomic, retain) NSString *iad;
@property (nonatomic, retain) NSString *uniNumber;
@property (nonatomic, retain) NSString *atc;
@property (nonatomic, retain) NSString *tvr;
@property (nonatomic, retain) NSString *tsi;
@property (nonatomic, retain) NSString *transDate;
@property (nonatomic, retain) NSString *transTime;
@property (nonatomic, retain) NSString *transType;
@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSString *tcc;
@property (nonatomic, retain) NSString *aip;
@property (nonatomic, retain) NSString *termCountryCode;
@property (nonatomic, retain) NSString *amountOther;
@property (nonatomic, retain) NSString *termCap;
@property (nonatomic, retain) NSString *cvr;
@property (nonatomic, retain) NSString *termType;
@property (nonatomic, retain) NSString *idsn;
@property (nonatomic, retain) NSString *dfName;
@property (nonatomic, retain) NSString *termAppVersion;
@property (nonatomic, retain) NSString *sequenceCounter;
@property (nonatomic, retain) NSString *trackII;
@property (nonatomic, retain) NSString *pan;
@property (nonatomic, retain) NSString *expiredDate;
@property (nonatomic, retain) NSString *transCurrencyCode;


- (id)initWithSring:(NSString *)xmlString;


@end
