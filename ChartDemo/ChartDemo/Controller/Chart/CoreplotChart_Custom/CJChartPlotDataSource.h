//
//  CJChartPlotDataSource.h
//  ChartDemo
//
//  Created by 李超前 on 2016/11/16.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CorePlot-CocoaTouch.h>
#import "CJChartData.h"

@interface CJChartPlotDataSource : NSObject <CPTPlotDataSource> {
    
}

- (instancetype)initWithChartData:(CJChartData *)chartDataModel;

@end
