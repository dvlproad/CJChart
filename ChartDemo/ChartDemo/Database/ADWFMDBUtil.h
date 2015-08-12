//
//  ADWFMDBUtil.h
//  ChartDemo
//
//  Created by lichq on 15-1-7.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonFMDBUtil.h"
#import "ADWInfo.h"

@interface ADWFMDBUtil : NSObject

+ (BOOL)createTable;
+ (BOOL)insertInfo:(ADWInfo *)info;
+ (BOOL)removeInfoWhereUID:(NSString *)uid date:(NSString *)date;
+ (BOOL)updateInfoExceptUID_DATE:(ADWInfo *)info whereUID:(NSString *)uid date:(NSString *)date;
+ (NSMutableArray *)selectInfoArrayWhereUID:(NSString *)uid;
+ (ADWInfo *)selectInfoWhereUID:(NSString *)uid date:(NSString *)date;




@end
