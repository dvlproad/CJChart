//
//  ADWInfo.m
//  ChartDemo
//
//  Created by lichq on 15-1-7.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "ADWInfo.h"


@implementation ADWInfo


//从服务器返回的标准dic结构，转为自定义的结构体
+ (ADWInfo *)turnToStructFromStandardDic:(NSDictionary *)dic{
    ADWInfo *info = [[ADWInfo alloc]init];
    info.uid = [[dic valueForKey:kADWKeyUID] stringValue];
    info.date = [[dic valueForKeyPath:kADWKeyDate] substringToIndex:10];
    info.wid = [[dic valueForKey:kADWKeyWID] stringValue];
    info.weight = [[dic valueForKey:kADWKeyWeight] stringValue];
    info.modified = [[dic valueForKeyPath:kADWKeyModified] stringValue];
    
    BOOL is_delete = [[dic valueForKey:kADWKeyExecType] boolValue];
    info.execTypeL = execTypeNone;
    info.execTypeN = is_delete ? execTypeDelete : execTypeUpdate;
    
    return info;
}


@end
