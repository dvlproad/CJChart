//
//  CPTXYGraph+CompleteXYPlotSpace.h
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <CorePlot-CocoaTouch.h>
#import "CJChartData.h"

@interface CPTXYGraph (CompleteXYPlotSpace)

- (void)completeXYPlotSpaceCommonSetting;
- (void)completeXYPlotSpaceRangeByChartDataModel:(CJChartData *)chartDataModel;

@end
