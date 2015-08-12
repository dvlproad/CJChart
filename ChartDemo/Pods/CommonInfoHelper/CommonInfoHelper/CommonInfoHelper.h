//
//  CommonInfoHelper.h
//  CommonFMDBUtilDemo
//
//  Created by lichq on 7/4/15.
//  Copyright (c) 2015 ciyouzen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define execTypeNone    @"sync_ok"
#define execTypeAdd     @"add"
#define execTypeDelete  @"delete"
#define execTypeUpdate  @"update"
#define execTypeTempAdd @"tempAdd"  //临时新增（比如在编辑状态时候，没点击完成就代表没正式新增）

#define sexTypeWommen   @"0"    //女
#define sexTypeMan      @"1"    //男

#define kNoData @"no_data"

@interface NSDictionary (StringValueForKeyPath)

- (NSString *)stringValueForKeyPath:(NSString *)keyPath;

@end


@implementation NSDictionary (StringValueForKeyPath)

- (NSString *)stringValueForKeyPath:(NSString *)keyPath{
    id object = [self valueForKeyPath:keyPath];
    
    if ([object isKindOfClass:[NSNumber class]]) {
        NSLog(@"%@字段类型是NSNumber", keyPath);
        return [object stringValue];
    }
    
    return object;
}


@end




@interface CommonInfoHelper : NSObject

+ (NSString *)getUUID;
+ (NSString *)getModified;
+ (NSString *)updateModified:(NSString *)modified;

@end
