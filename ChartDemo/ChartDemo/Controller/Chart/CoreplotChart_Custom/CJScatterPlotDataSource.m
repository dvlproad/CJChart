//
//  CJScatterPlotDataSource.m
//  ChartDemo
//
//  Created by 李超前 on 2016/11/16.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CJScatterPlotDataSource.h"

@interface CJScatterPlotDataSource () {
    
}
@property (nonatomic, strong) CJChartData *chartDataModel; /**< 图标数据 */

@end

@implementation CJScatterPlotDataSource

- (instancetype)init {
    return nil;
}

- (instancetype)initWithChartData:(CJChartData *)chartDataModel {
    self = [super init];
    if (self) {
        _chartDataModel = chartDataModel;
    }
    return self;
}

#pragma mark - CPTPlotDataSource 实现数据源协议
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.chartDataModel.yPlotDatas.count;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    CJChartPlotData *chartPlotData = [self.chartDataModel.yPlotDatas objectAtIndex:index];
    
    NSNumber *number = nil;
    if (fieldEnum == CPTScatterPlotFieldX) {
        number = [NSNumber numberWithFloat:chartPlotData.x];
    } else {
        number = [NSNumber numberWithFloat:chartPlotData.y];
    }
    return number;
}

/** 给折现上的点添加值（plot添加值的折现  index点的位置 ）//参考饼状图CPTPieChartViewController的绘制 */
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx{
    CJChartPlotData *chartPlotData = [self.chartDataModel.yPlotDatas objectAtIndex:idx];
    NSString *yText = [NSString stringWithFormat:@"%.1f", chartPlotData.y];
    
    CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:yText];
    
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
    
    textStyle.color = [CPTColor greenColor];
    textStyle.fontSize = 10.0f;
    label.textStyle = textStyle;
    
    
    return label;
}

@end
