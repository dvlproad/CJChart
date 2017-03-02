//
//  WeightFMDBFileManager.m
//  ChartDemo
//
//  Created by lichq on 15-1-7.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "WeightFMDBFileManager.h"

@implementation WeightFMDBFileManager

+ (WeightFMDBFileManager *)sharedInstance {
    static WeightFMDBFileManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (void)createDatabaseForUserName:(NSString *)userName {
    NSAssert(userName != nil && [userName length] > 0, @"userName不能为空");
    
    [[WeightFMDBFileManager sharedInstance] cancelManagerAnyDatabase];
    
    NSString *databaseName = @"";
    if ([userName hasSuffix:@".db"]) {
        databaseName = userName;
    } else {
        databaseName = [NSString stringWithFormat:@"%@.db", userName];
    }
    
    NSString *directoryRelativePath = [CJFileManager getLocalDirectoryPathType:CJLocalPathTypeRelative
                                                            bySubDirectoryPath:@"DB"
                                                         inSearchPathDirectory:NSDocumentDirectory
                                                               createIfNoExist:YES];
    NSString *fileRelativePath = [directoryRelativePath stringByAppendingPathComponent:databaseName];
    
    //方法1：copy
    NSString *copyDatabasePath = [[NSBundle mainBundle] pathForResource:@"curfmdb.db" ofType:nil];
    [[WeightFMDBFileManager sharedInstance] createDatabaseInFileRelativePath:fileRelativePath
                                                         byCopyDatabasePath:copyDatabasePath
                                                            ifExistDoAction:CJFMDBFileExistActionTypeRerecertIt];
}

+ (NSArray *)allCreateTableSqls {
    NSString *sqlUserTabelCreate = [self sqlForCreateTable];
    
    NSArray *createTableSqls = @[sqlUserTabelCreate];
    
    return createTableSqls;
}

+ (void)reCreateCurrentDatabase {
    NSArray *createTableSqls = [self allCreateTableSqls];
    [[WeightFMDBFileManager sharedInstance] recreateDatabase:createTableSqls];
}

+ (BOOL)deleteFMDBDirectory {
    return [[WeightFMDBFileManager sharedInstance] deleteCurrentFMDBDirectory];
}

#pragma mark - WeightTable
+ (NSString *)sqlForCreateTable
{
    NSString *sql = @"create table if not exists Weight (uid Text, date TEXT, wid Text, weight TEXT, modified TEXT, execTypeL Text, PRIMARY KEY(uid, date));";
    return sql;
}


#pragma mark - insert

+ (BOOL)insertInfo:(ADWInfo *)info
{
    NSAssert(info, @"info cannot be nil!");
    
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('%@', '%@', '%@', '%@', '%@', '%@')", info.uid, info.date, info.wid, info.weight, info.modified, info.execTypeL];//DB Error: 1 "unrecognized token: ":"" 即要求插入的字符串需加引号'，而对于表名，属性名，可以不用像原来那样添加。
    
    /*
    INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('1', '2016-11-02', '10001', '55', '1013513515', '');
    INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('1', '2017-11-15', '10002', '60', '1013513515', '');
    INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('1', '2017-12-02', '10003', '65', '1013513515', '');
    INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('1', '2017-12-23', '10004', '63', '1013513515', '');
    INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('1', '2017-01-10', '10005', '60', '1013513515', '');
    INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('1', '2017-01-28', '10006', '63', '1013513515', '');
    INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('1', '2017-02-20', '10007', '60', '1013513515', '');
    INSERT OR REPLACE INTO Weight (uid, date, wid, weight, modified, execTypeL) VALUES ('1', '2017-03-02', '10008', '65', '1013513515', '');
    */
    return [[WeightFMDBFileManager sharedInstance] cjExecuteUpdate:@[sql]];
}

#pragma mark - remove

+ (BOOL)removeInfoWhereUID:(NSString *)uid date:(NSString *)date
{
    NSString *sql = [NSString stringWithFormat:@"delete from Weight where name = '%@' and date ='%@'",uid, date];
    
    return [[WeightFMDBFileManager sharedInstance] cjExecuteUpdate:@[sql]];
}


#pragma mark - update
+ (BOOL)updateInfoExceptUID_DATE:(ADWInfo *)info whereUID:(NSString *)uid date:(NSString *)date
{
    
    //wid由后台生成的时候，再添加记录成功后，需要更新本地的wid，以用作下次通过wid更改weight值。
    NSString *sql = [NSString stringWithFormat:
                     @"UPDATE Weight SET wid = '%@', weight = '%@', modified = '%@', execTypeL = '%@' WHERE uid = '%@' and date = '%@'",
                     info.wid, info.weight, info.modified, info.execTypeL, uid, date];
    return [[WeightFMDBFileManager sharedInstance] cjExecuteUpdate:@[sql]];
}


#pragma mark - query

+ (NSMutableArray *)selectInfoArrayWhereUID:(NSString *)uid
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Weight where uid = '%@'", uid];
    
    NSMutableArray *dictionarys = [[WeightFMDBFileManager sharedInstance] query:sql];
    if (dictionarys.count == 0) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionarys) {
        ADWInfo *info = [self transformToInfoByDic:dictionary];
        [result addObject:info];
    }
    return result;
}

+ (ADWInfo *)selectInfoWhereUID:(NSString *)uid date:(NSString *)date
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Weight where uid = '%@' and date = '%@'", uid, date];
    
    NSArray *array = [[WeightFMDBFileManager sharedInstance] query:sql];
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
