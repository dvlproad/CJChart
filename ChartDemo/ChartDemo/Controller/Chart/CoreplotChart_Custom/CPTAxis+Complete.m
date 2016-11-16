//
//  CPTAxis+Complete.m
//  ChartDemo
//
//  Created by 李超前 on 2016/11/16.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CPTAxis+Complete.h"

static CPTTextStyle *yPositiveStyle = nil;
static CPTTextStyle *yNegativeStyle = nil;
static dispatch_once_t yPositiveOnce;
static dispatch_once_t yNegativeOnce;

#define Text_Color_isGreaterThanOrEqualTo_Y [CPTColor blackColor]   //y轴轴标签值大于指定值时候的文字颜色
#define Text_Color_isLessThan_Y             [CPTColor blackColor]     //y轴轴标签值小于指定值时候的文字颜色

#define Text_Color_Default_X                [CPTColor blackColor]     //x轴轴标签默认的文字牙呢

@implementation CPTAxis (Complete)

- (void)completeCoordinateYLocations:(NSSet *)locations {
    //CGFloat labelOffset    = axis.labelOffset;
    NSNumber *n_standValue_Y  = [NSNumber numberWithFloat:standValue_Y];
    
    NSMutableSet *axisLabelsY = [NSMutableSet set];
    for ( NSDecimalNumber *location in locations ) {
        CPTAxisLabel *axisLabel = [self getYAxisLabelAtLocation:location withBaseValue:n_standValue_Y];
        [axisLabelsY addObject:axisLabel];
    }
    self.axisLabels = axisLabelsY;
}

- (CPTAxisLabel *)getYAxisLabelAtLocation:(NSDecimalNumber *)location withBaseValue:(NSNumber *)n_standValue_Y {
    //NSLog(@"location = %@: %d", location, [location intValue]);
    
    
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
    #pragma mark 功能：对轴上不同的点设置不同的刻度标签颜色，如与standValue为标准，大于等于用一种，小于用另外一种
    //①、获取标签样式 textStyle (CPTTextStyle)
    CPTTextStyle *textStyle = [self.labelTextStyle mutableCopy];
    if ( [location isGreaterThanOrEqualTo:n_standValue_Y] ) {
        dispatch_once(&yPositiveOnce, ^{
            CPTMutableTextStyle *newStyle = [self.labelTextStyle mutableCopy];
            newStyle.color = Text_Color_isGreaterThanOrEqualTo_Y;
            yPositiveStyle = newStyle;
        });
        
        textStyle = yPositiveStyle;
        
    } else {
        dispatch_once(&yNegativeOnce, ^{
            CPTMutableTextStyle *newStyle = [self.labelTextStyle mutableCopy];
            newStyle.color = Text_Color_isLessThan_Y;
            yNegativeStyle = newStyle;
        });
        
        textStyle = yNegativeStyle;
    }
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//
    
    
    //②、获取标签文本 text (NSString)
    NSString *text       = [NSString stringWithFormat:@"%d", [location intValue]];
    
    //由①和②组成TextLayer
    CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:text style:textStyle];
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
    axisLabel.tickLocation = location;
    axisLabel.offset       = self.labelOffset + (0); //坐标轴刻度的位置
    //axisLabel.offset       = x.labelOffset + x.majorTickLength;
    //axisLabel.rotation     = CPTFloat(M_PI_4);
    
    return axisLabel;
}

- (void)completeCoordinateXLocations:(NSSet *)locations withChartData:(CJChartData *)chartDataModel {
#pragma mark 功能：实现缩放时候，轴标签能根据轴上的点的个数自适应，以使得不会出现轴标签密密麻麻的排在一起的情况
    NSInteger maxTickShowCount = chartDataModel.xShowCountLeast; //设置坐标轴最多展示多少个刻度
    NSInteger gapNumForDay = [self getGapDistanceAtLocations:locations
                                        withMaxTickShowCount:maxTickShowCount];
    NSInteger gapNumForMonth = [self getGapDistanceForMonthAtLocations:locations
                                                  withMaxTickShowCount:maxTickShowCount];
    
    /*//TODO怎么动态修改x轴主刻度的间距(附：以下注释的代码无效)
     //额外增加的代码，一般只在规定时候设置
     NSInteger gapXScaleMajor = 1.0;//x轴主刻度的间距.注意刻度数变化的时候，势必会影响到轴上显示的刻度个数，即location的个数。
     if ([locations count] > 28) {
     gapXScaleMajor = locations.count/28;
     }
     axis.majorIntervalLength = CPTDecimalFromDouble(gapXScaleMajor);//设置x轴主刻度
     */
    
    NSMutableSet *axisLabelsX = [NSMutableSet set];
    for ( NSDecimalNumber *location in locations ) {
        //NSLog(@"location = %@: %d", location, [location intValue]);
        
        CJDate *myDate = [chartDataModel.xDatas objectAtIndex:[location integerValue]];
        
        if ([location intValue]%gapNumForDay == 0) {
            CPTAxisLabel *axisLabel = [self getXAxisLabelDayAtLocation:location withDateMoel:myDate];
            [axisLabelsX addObject:axisLabel];
        }
        
        
        if ([location intValue]%gapNumForMonth == 0) {
            //获取当前location上的标签文本值
            if (myDate.isMiddleDayInMonth) {
                CPTAxisLabel *axisLabel = [self getXAxisLabelMonthAtLocation:location withDateMoel:myDate];
                [axisLabelsX addObject:axisLabel];
            }
        }
    }
    
    self.axisLabels = axisLabelsX;
}


/**
 *  计算最后绘制出来的轴刻度要以每隔多少间隔才绘制一个（以防当轴上的点过多时，如果全绘制会导致轴刻度密密麻麻的）
 *
 *  @return 相邻刻度的间隔（计算方法为：通过设置最大允许多少刻度来计算）
 */
- (NSInteger)getGapDistanceAtLocations:(NSSet *)locations withMaxTickShowCount:(NSInteger)maxTickShowCount {
    NSInteger gapNum = 1;//每间隔gapNum个刻度单位再显示。
    
    if ([locations count] > maxTickShowCount) { //如果locations的个数超过自己规定的个数(这里设为7个)
        gapNum = [locations count]/maxTickShowCount;
        NSLog(@"gapNum = %zd", gapNum);
    }
    return gapNum;
}


- (NSInteger)getGapDistanceForMonthAtLocations:(NSSet *)locations withMaxTickShowCount:(NSInteger)maxTickShowCount {
    NSInteger gapNum = 1;
    if ([locations count] > maxTickShowCount) {
        gapNum = [locations count]/maxTickShowCount; //设置"月"行最多展示
        NSLog(@"gapNum = %zd", gapNum);
    }
    return gapNum;
}




- (CPTAxisLabel *)getXAxisLabelDayAtLocation:(NSDecimalNumber *)location withDateMoel:(CJDate *)dateModel {
    //②、获取当前location上的标签文本值
    //NSFormatter *formatter = axis.labelFormatter;
    //NSString *axisLabelText = [formatter stringForObjectValue:location];
    NSString *dayText = @"kong";
    if (dateModel.isFirstDayInMonth) {
        dayText = [NSString stringWithFormat:@"%zd.%02zd", dateModel.month, dateModel.day];
    } else {
        dayText = [NSString stringWithFormat:@"%zd", dateModel.day];
    }
    
    //①、获取标签样式
    static CPTTextStyle *positiveStyle = nil;
    static dispatch_once_t positiveOnce;
    
    CPTTextStyle *theLabelTextStyle;
    dispatch_once(&positiveOnce, ^{
        CPTMutableTextStyle *newStyle = [self.labelTextStyle mutableCopy];
        newStyle.color = Text_Color_Default_X;
        positiveStyle = newStyle;
    });
    theLabelTextStyle = positiveStyle;
    
    CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] init];
    [newLabelLayer setText:dayText];
    [newLabelLayer setTextStyle:theLabelTextStyle];
    
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
    
    axisLabel.tickLocation = location;
    
    axisLabel.offset       = self.labelOffset;
    //axisLabel.offset       = x.labelOffset + x.majorTickLength;
    axisLabel.rotation     = CPTFloat(M_PI_2);
    
    return axisLabel;
}

/**
 *  绘制X轴上的location位置的月刻度
 *
 *  @param axis     坐标轴
 *  @param location 坐标轴上的位置
 *  @param text     坐标轴上的文本
 *
 *  @return 坐标刻度
 */
- (CPTAxisLabel *)getXAxisLabelMonthAtLocation:(NSDecimalNumber *)location withDateMoel:(CJDate *)dateModel {
    NSString *monthText = @"kong";
    monthText = [NSString stringWithFormat:@"%zd月", dateModel.month];
    
    CPTTextStyle *theLabelTextStyle;
    static CPTTextStyle *positiveStyle = nil;
    static dispatch_once_t positiveOnce;
    dispatch_once(&positiveOnce, ^{
        CPTMutableTextStyle *newStyle = [self.labelTextStyle mutableCopy];
        newStyle.color = [CPTColor redColor];
        positiveStyle = newStyle;
    });
    theLabelTextStyle = positiveStyle;
    
    
    CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] init];
    [newLabelLayer setText:monthText];
    [newLabelLayer setTextStyle:theLabelTextStyle];
    
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
    //axisLabel.tickLocation = tickLocation.decimalValue;
    double dValue = location.doubleValue + 0.1; //为了不让它覆盖掉之前的lable，所以加0.1，而不是整数
    NSDecimalNumber *result = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:dValue];
    axisLabel.tickLocation = result;
    
    axisLabel.offset       = self.labelOffset;
    //axisLabel.offset       = x.labelOffset + x.majorTickLength;
    //axisLabel.rotation     = CPTFloat(M_PI_4);
    
    return axisLabel;
}


@end
