//
//  CJChartPlotData.h
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJChartPlotData : NSObject

@property (nonatomic, strong, readonly) NSString *xDateString;
@property (nonatomic, strong, readonly) NSString *yValueString;

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

/**
 *  唯一的初始化方法
 *
 *  @param xDateString      xDateString
 *  @param yValueString     yValueString
 */
- (instancetype)initWithXDateString:(NSString *)xDateString yValueString:(NSString *)yValueString;

@end
