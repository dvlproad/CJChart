//
//  CommonInfoHelper.m
//  CommonFMDBUtilDemo
//
//  Created by lichq on 7/4/15.
//  Copyright (c) 2015 ciyouzen. All rights reserved.
//

#import "CommonInfoHelper.h"

@implementation CommonInfoHelper

+ (NSString *)getUUID{
    CFUUIDRef identifier = CFUUIDCreate(NULL);
    NSString *identifierString = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, identifier));
    CFRelease(identifier);
    //NSLog(@"identifierString = %@", identifierString);
    return identifierString;
}

+ (NSString *)getModified{
    /*
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
     */
    
    
    //当前时间转为1970年以来的秒数//获取自1970年以来的毫秒数
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
    NSLog(@"1970timeInterval:%f",time); //NSTimeInterval是double类型
    
    NSString *modified = [NSString stringWithFormat:@"%.0f", time];
    return modified;
}


+ (NSString *)updateModified:(NSString *)modified{
    NSString *modified_new = [NSString stringWithFormat:@"%d", [modified intValue]+1];
    return modified_new;
}


@end
