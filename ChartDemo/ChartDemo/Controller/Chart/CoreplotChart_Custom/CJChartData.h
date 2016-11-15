//
//  CJChartData.h
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJDate.h"
#import "CJChartPlotData.h"

@interface CJChartData : NSObject

@property (nonatomic, assign) CGFloat xMin;
@property (nonatomic, assign) CGFloat xMax;
@property (nonatomic, strong) NSMutableArray<CJDate *> *xDatas;

@property (nonatomic, assign) CGFloat yMin;
@property (nonatomic, assign) CGFloat yMax;
@property (nonatomic, strong) NSMutableArray<CJChartPlotData *> *yPlotDatas;

@end
