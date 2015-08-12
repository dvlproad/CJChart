//
//  ADNInfo.h
//  ChartDemo
//
//  Created by lichq on 15-1-8.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kADNKeyi2_sum       @"i2_sum"
#define kADNKeyi4_sum       @"i4_sum"
#define kADNKeyi5_sum       @"i5_sum"
#define kADNKeyi6_sum       @"i6_sum"
#define kADNKeyi11_sum      @"i51_sum"

@interface ADNInfo : NSObject

@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSString *date;

@property(nonatomic, strong) NSString *i2_sum;
@property(nonatomic, strong) NSString *i4_sum;
@property(nonatomic, strong) NSString *i5_sum;
@property(nonatomic, strong) NSString *i6_sum;
@property(nonatomic, strong) NSString *i11_sum;

@property(nonatomic, strong) NSString *i2_need;
@property(nonatomic, strong) NSString *i4_need;
@property(nonatomic, strong) NSString *i5_need;
@property(nonatomic, strong) NSString *i6_need;
@property(nonatomic, strong) NSString *i11_need;

@property(nonatomic, strong) NSString *i2_recommend;
@property(nonatomic, strong) NSString *i4_recommend;
@property(nonatomic, strong) NSString *i5_recommend;
@property(nonatomic, strong) NSString *i6_recommend;
@property(nonatomic, strong) NSString *i11_recommend;



@end
