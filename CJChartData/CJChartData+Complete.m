//
//  CJChartData+Complete.m
//  ChartDemo
//
//  Created by 李超前 on 2016/11/15.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CJChartData+Complete.h"

#import "NSDate+Category.h"
#import "NSDate+FindAllDate.h"

#import "NSString+Category.h"

@implementation CJChartData (Complete)

/** 完善图标数据源CJChartData */
- (void)completeChartDataByData:(NSArray *)datas {
    /* 1、获取数据的开头日期和结尾日期 */
    NSDate *dateBegin = [NSDate date];
    NSDate *dateEnd = [NSDate date];
    if ([datas count] != 0) {
        CJChartPlotData *info = [datas objectAtIndex:0];
        dateBegin = [info.xDateString standDate];
    }
    
    [self completeChartDataByData:datas withDateBegin:dateBegin dateEnd:dateEnd];
}

- (void)completeChartDataByData:(NSArray *)datas withDateBegin:(NSDate *)dateBegin dateEnd:(NSDate *)dateEnd {
    /* 2、获取坐标轴上显示的开头日期和结尾日期 */
    //①、判断：如果现有坐标刻度(X轴坐标)小于最小应有值，这里应默认将其扩大，以使得不会产生一个坐标里面只有一个刻度的效果
    NSInteger dayDistance = [dateEnd dayDistanceFromDate:dateBegin];
    NSLog(@"天数差为%ld", dayDistance);
    if (dayDistance < self.xShowCountLeast) {
        dateBegin = [dateEnd dateDistances:-self.xShowCountLeast+1 type:eDistanceDay];
    }
    
    //②、增加：开始日期提前一点，结束日期延后一点，以使得能保证所有的数据都不会显示在边界上，而造成不好的效果
    NSDate *showDateBegin = [dateBegin dateDistances:-self.xPlaceholderUnitCountBegin type:eDistanceDay];
    NSDate *showDateEnd = [dateEnd dateDistances:self.xPlaceholderUnitCountLast type:eDistanceDay];
    
    //横轴上通过日期数据(开始日期以及结束日期)，来获取该坐标轴的最大值、最小值，以使得之后能确定坐标轴的范围。
    self.xDatas = [showDateEnd findAllDateFromDate:showDateBegin];
    self.xMin = 0;
    self.xMax = [self.xDatas count] - 1;//注意这里记得减去1否则个数不正确，因为这里是从0开始算
    
    //纵轴上通过用户体重值数据，来获取该坐标轴的最大值、最小值，以使得之后能确定坐标轴的范围。
    //同时横轴上将日期数据Y转为XY数据，以作之后轴标签数据、纵轴上用户体重数据（也是日期Y）也改为XY形式的数据，以作之后坐标系上的店的数据
    /* ②、取出dataModels中每个dataModel的日期，结合自己设定的初始日期设置X；取出其值，设置为Y */
    NSMutableArray *yPlotDatas = [[NSMutableArray alloc]init];
    
    if (datas.count == 0) {
        self.yPlotDatas = yPlotDatas;
        self.yMin = self.yMinWhenEmpty;
        self.yMax = self.yMaxWhenEmpty;
        
    }else{
        CJChartPlotData *firstChartPlotData = datas[0];
        CGFloat yMinValue = [firstChartPlotData.yValueString floatValue];
        CGFloat yMaxValue = [firstChartPlotData.yValueString floatValue];
        for (CJChartPlotData *info in datas) {
            NSDate *date = [info.xDateString standDate];
            NSInteger xValue = [date dayDistanceFromDate:showDateBegin];
            CGFloat yValue = [info.yValueString floatValue];
            
            info.x = xValue;
            info.y = yValue;
            
            yMinValue = yValue < yMinValue ? yValue : yMinValue;
            yMaxValue = yValue > yMaxValue ? yValue : yMaxValue;
            
            [yPlotDatas addObject:info];
        }
        
        self.yPlotDatas = yPlotDatas;
        self.yMin = floorf(yMinValue/5) * 5 - 5;   //floorf 向下取整
        self.yMax = floorf(yMaxValue/5) * 5 + 6;
    }
}


@end
