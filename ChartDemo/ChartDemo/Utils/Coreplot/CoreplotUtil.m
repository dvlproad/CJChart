//
//  CoreplotUtil.m
//  Lee
//
//  Created by lichq on 15/4/9.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "CoreplotUtil.h"

@implementation CoreplotUtil

#pragma mark - 当缩放的时候用下面的方法固定轴标题位置
+ (NSNumber *)calculateTitleLocationByCurRange:(CPTPlotRange *)curRange{
    //return curRange.maxLimit;
    
    //发现以下方法只使用于滑动时候，不使用于缩放时候
    //计算方法一：使用double类型的 maxLimitDouble值
    //NSLog(@"%f + %f = %f", curRange.locationDouble, curRange.lengthDouble, curRange.endDouble);
    
    double lengthDouble = curRange.lengthDouble;//如果
    double subDouble = lengthDouble * adr_titleLocation_X; //注意：不要删掉：这里使用减去10%，而不使用减去具体数字（比如double subDouble = 5.0），是为了使得不仅在滑动的时候能让轴标签固定，也能在缩放的时候使得轴标签固定。
    double dValue = curRange.maxLimitDouble + subDouble;
    NSNumber *decimalNumber = [NSNumber numberWithDouble:dValue];
    return decimalNumber;
    
    
    /*
     //计算方法二：使用NSDecimal类型的 maxLimit值
     //要运算NSDecimal必须先至少转化为NSDecimalNumber后，才能运算，运算之后再转回来(牢记NSDecimalNumber是NSNumber的子类)
     //①NSDecimal转NSDecimalNumber
     NSDecimalNumber *maxLimit = [NSDecimalNumber decimalNumberWithDecimal:curRange.maxLimit];
     //NSDecimalNumber运算方法一：将数值型转为NSDecimalNumber后，直接进行同NSDecimalNumber间运算。
     //NSDecimalNumber *subDNum = [NSDecimalNumber decimalNumberWithString:@"-5"];
     NSDecimalNumber *subDNum = (NSDecimalNumber *)[NSDecimalNumber numberWithFloat:2.0f];
     
     NSDecimalNumber *result = [maxLimit decimalNumberBySubtracting:subDNum];
     
     
     //NSDecimalNumber运算方法二：将NSDecimalNumber转为数值型后，直接进行同数值型运算（因为它是NSNumber子类）后，再将运算后的数值型转为NSDecimalNumber型。
     
     //②NSDecimalNumber转NSDecimal
     NSDecimal resultDecimal = result.decimalValue;
     
     return resultDecimal;
     */
}


@end
