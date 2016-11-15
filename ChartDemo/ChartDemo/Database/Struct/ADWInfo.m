//
//  ADWInfo.m
//  ChartDemo
//
//  Created by lichq on 15-1-7.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "ADWInfo.h"


@implementation ADWInfo

- (instancetype)initWithXDateString:(NSString *)xDateString yValueString:(NSString *)yValueString {
    self = [super initWithXDateString:xDateString yValueString:yValueString];
    if (self) {
        _date = xDateString;
        _weight = yValueString;
    }
    return self;
}


//从服务器返回的标准dic结构，转为自定义的结构体
+ (ADWInfo *)turnToStructFromStandardDic:(NSDictionary *)dic{
    NSString *xDateString = [[dic valueForKeyPath:kADWKeyDate] substringToIndex:10];
    NSString *yValueString = [[dic valueForKey:kADWKeyWeight] stringValue];
    
    ADWInfo *info = [[ADWInfo alloc] initWithXDateString:xDateString yValueString:yValueString];
    info.uid = [[dic valueForKey:kADWKeyUID] stringValue];
    info.wid = [[dic valueForKey:kADWKeyWID] stringValue];
    info.modified = [[dic valueForKeyPath:kADWKeyModified] stringValue];
    
    BOOL is_delete = [[dic valueForKey:kADWKeyExecType] boolValue];
    info.execTypeL = execTypeNone;
    info.execTypeN = is_delete ? execTypeDelete : execTypeUpdate;
    
    return info;
}


@end
