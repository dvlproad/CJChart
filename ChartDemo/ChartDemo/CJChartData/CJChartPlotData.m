//
//  CJChartPlotData.m
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "CJChartPlotData.h"

@implementation CJChartPlotData

- (instancetype)init {
    NSLog(@"Error:初始化方法选择错误");
    return nil;
}

- (instancetype)initWithXDateString:(NSString *)xDateString yValueString:(NSString *)yValueString {
    self = [super init];
    if (self) {
        _xDateString = xDateString;
        _yValueString = yValueString;
    }
    return self;
}

@end
