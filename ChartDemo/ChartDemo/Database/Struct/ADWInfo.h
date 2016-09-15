//
//  ADWInfo.h
//  ChartDemo
//
//  Created by lichq on 15-1-7.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonInfoHelper.h>

#define kADWKeyUID      @"uid"
#define kADWKeyDate     @"date"
#define kADWKeyWID      @"wid"
#define kADWKeyWeight   @"weight"
#define kADWKeyModified @"modified"
#define kADWKeyExecType @"is_delete"

@interface ADWInfo : NSObject

@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSString *date;
@property(nonatomic, strong) NSString *wid;//recordID 该条记录的id，相当于主键(有时即uuid)
@property(nonatomic, strong) NSString *weight;
@property(nonatomic, strong) NSString *modified;
@property(nonatomic, strong) NSString *execTypeL;
@property(nonatomic, strong) NSString *execTypeN;

+ (ADWInfo *)turnToStructFromStandardDic:(NSDictionary *)dic;

@end
