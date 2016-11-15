//
//  CJChartData+Complete.h
//  ChartDemo
//
//  Created by 李超前 on 2016/11/15.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CJChartData.h"

@interface CJChartData (Complete)

- (void)completeChartDataByData:(NSArray *)datas;

- (void)completeChartDataByData:(NSArray *)datas withDateBegin:(NSDate *)dateBegin dateEnd:(NSDate *)dateEnd;

@end
