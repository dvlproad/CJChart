//
//  ADWFMDBUtil.m
//  ChartDemo
//
//  Created by lichq on 15-1-7.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "ADWFMDBUtil.h"

@implementation ADWFMDBUtil



+ (BOOL)createTable
{
    NSString *sql = @"create table if not exists ADW (uid Text, date TEXT, wid Text, weight TEXT, modified TEXT, execTypeL Text, PRIMARY KEY(uid, date));";
    return [CommonFMDBUtil create:sql];
}


#pragma mark - insert

+ (BOOL)insertInfo:(ADWInfo *)info
{
    NSAssert(info, @"info cannot be nil!");
    
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO ADW (uid, date, wid, weight, modified, execTypeL) VALUES ('%@', '%@', '%@', '%@', '%@', '%@')", info.uid, info.date, info.wid, info.weight, info.modified, info.execTypeL];//DB Error: 1 "unrecognized token: ":"" 即要求插入的字符串需加引号'，而对于表名，属性名，可以不用像原来那样添加。
    
    return [CommonFMDBUtil insert:sql];
}

#pragma mark - remove

+ (BOOL)removeInfoWhereUID:(NSString *)uid date:(NSString *)date
{
    NSString *sql = [NSString stringWithFormat:@"delete from ADW where name = '%@' and date ='%@'",uid, date];
    
    return [CommonFMDBUtil remove:sql];
}


#pragma mark - update
+ (BOOL)updateInfoExceptUID_DATE:(ADWInfo *)info whereUID:(NSString *)uid date:(NSString *)date
{
    
    //wid由后台生成的时候，再添加记录成功后，需要更新本地的wid，以用作下次通过wid更改weight值。
    NSString *sql = [NSString stringWithFormat:
                     @"UPDATE ADW SET wid = '%@', weight = '%@', modified = '%@', execTypeL = '%@' WHERE uid = '%@' and date = '%@'",
                     info.wid, info.weight, info.modified, info.execTypeL, uid, date];
    return [CommonFMDBUtil update:sql];
}


#pragma mark - query

+ (NSMutableArray *)selectInfoArrayWhereUID:(NSString *)uid
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM ADW where uid = '%@'", uid];
    
    NSMutableArray *array = [CommonFMDBUtil query:sql];
    if (array.count == 0) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        ADWInfo *info = [self transformToInfoByDic:dic];
        [result addObject:info];
    }
    return result;
}

+ (ADWInfo *)selectInfoWhereUID:(NSString *)uid date:(NSString *)date
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM ADW where uid = '%@' and date = '%@'", uid, date];
    
    NSArray *array = [CommonFMDBUtil query:sql];
    if (array.count == 0) {
        return nil;
    }
    ADWInfo *info = [self transformToInfoByDic:array[0]];
    return info;
}


+ (ADWInfo *)transformToInfoByDic:(NSDictionary *)dic{
    NSString *xDateString = [dic valueForKey:kADWKeyDate];
    NSString *yValueString = [dic valueForKey:kADWKeyWeight];
    
    ADWInfo *info = [[ADWInfo alloc] initWithXDateString:xDateString yValueString:yValueString];
    info.uid = dic[kADWKeyUID];
    info.wid = dic[kADWKeyWID];
    info.modified = dic[kADWKeyModified];
    info.execTypeL = dic[kADWKeyExecType];
    info.execTypeN = @"none";
    return info;
}





@end
