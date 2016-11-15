//
//  CPTXYGraph+CompleteXYPlotSpace.m
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CPTXYGraph+CompleteXYPlotSpace.h"

@implementation CPTXYGraph (CompleteXYPlotSpace)

- (void)completeXYPlotSpaceCommonSetting {
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
    
    //设置移动时的停止动画这些参数（保持默认即可变化不大）
    xyPlotSpace.momentumAnimationCurve = CPTAnimationCurveCubicIn;
    xyPlotSpace.bounceAnimationCurve = CPTAnimationCurveBackIn;
    xyPlotSpace.momentumAcceleration = 20000.0;
    [xyPlotSpace setAllowsMomentumX:YES];
    
    xyPlotSpace.allowsUserInteraction = YES; //是否允许拖动
}

/** 设置显示和移动范围 */
- (void)completeXYPlotSpaceRangeByChartDataModel:(CJChartData *)chartDataModel {
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
    
    CGFloat showXMin = chartDataModel.xMax-chartDataModel.xShowCountDefault;//只显示最近的几天 所以min是 self.xMax-UnitCount_X_Default 天
    CGFloat showXMax = chartDataModel.xMax;
    
    CGFloat showYMin = chartDataModel.yMin;
    CGFloat showYMax = chartDataModel.yMax-0.1;
    
    xyPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(showXMin)
                                               length:@(showXMax - showXMin)];
    xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(showYMin)
                                               length:@(showYMax - showYMin)];
    
    
    //②、设置轴的滑动范围。（能实现1、去掉最开头、最结尾的网格线（其实是显示不到而已），所以这里的最大值与最小值都有一个0.1的处理；2、坐标只按照X轴横向滑动，其实只是让Y轴最大滑动范围与Y轴的量度范围(初始显示区域)一样，以使得Y轴不能滑动而已）
    CGFloat globalXMin = chartDataModel.xMin + 0.1;
    CGFloat globalXMax = chartDataModel.xMax - 0.1;
    xyPlotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:@(globalXMin)
                                                            length:@(globalXMax - globalXMin)];
    xyPlotSpace.globalYRange = xyPlotSpace.yRange;
    
    //    [self.graphHostingView setAllowPinchScaling:NO];//禁止缩放：（两指捏扩动作,默认允许）
    
    //TODO
    //    self.globalXRange = xyPlotSpace.globalXRange;
    //    self.currentXRange = xyPlotSpace.xRange;
    //    self.globalYRange = xyPlotSpace.yRange;
}

@end
