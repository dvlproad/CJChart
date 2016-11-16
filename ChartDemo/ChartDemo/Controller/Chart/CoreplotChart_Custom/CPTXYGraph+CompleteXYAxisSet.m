//
//  CPTXYGraph+CompleteXYAxisSet.m
//  ChartDemo
//
//  Created by 李超前 on 2016/11/15.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CPTXYGraph+CompleteXYAxisSet.h"

//坐标轴与边界距离(待完善)
#define kConstraintWithLowerOffsetX 60 //设置所固定的Y坐标轴与最小值的偏移
#define kConstraintWithLowerOffsetY 0 //设置所固定的Y坐标轴与最小值的偏移(一般设为0)

//在默认的距离上再偏移多少 adn: after_default_num   adr: after_default__ratio
#define adn_titleLocation_Y -5.0    //标题刻度位置在默认的基础上再偏移多少值
#define adn_titleOffset_Y   -5.0    //标题像素位置...

@implementation CPTXYGraph (CompleteXYAxisSet)

#pragma mark - 设置坐标轴（有时候要求固定坐标轴位置，即使是在缩放的时候）
- (void)completeXAxisSettingWithFixedXAxisByAbsolutePosition:(BOOL)fixedXAxisByAbsolutePosition {
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)self.axisSet;//获取XYGraph的轴的集合,其中包括xAxis和yAxis
    CPTXYAxis *xAxis = xyAxisSet.xAxis;
    
    //针对该坐标想要固定的点在该轴上的位置相对view是否始终不变(会改变的情况：比如轴原点位置改变，轴缩放）的情况可有设置orthogonalPosition和设置axisConstraints两种不同方法，其中设置axisConstraints是最强方法，且注意使用axisConstraints后，原本orthogonalPosition将会自动变成永远无效，所以使用axisConstraints的时候，可不设置orthogonalPosition
    //方法：设置轴位置
    //方法①：始终不变，则可直接使用orthogonalPosition“固定”（其实只是设置而已）。
    //方法②：会改变，则应该使用axisConstraints真正固定
    if (fixedXAxisByAbsolutePosition) {//通过绝对位置，设置x轴的原点位置
        xAxis.orthogonalPosition = @(66);
    } else {                                //通过相对位置位置，设置x轴的原点位置
        xAxis.axisConstraints =
        [CPTConstraints constraintWithLowerOffset:kConstraintWithLowerOffsetX];
        //[CPTConstraints constraintWithUpperOffset:60];
        //[CPTConstraints constraintWithRelativeOffset:0.5];
    }
    
    //设置轴大小：轴主刻度间距长度、轴主刻度间细分刻度个数
    xAxis.majorIntervalLength   = @(1.0);//设置x轴主刻度：每多少长度显示一个刻度
    xAxis.minorTicksPerInterval = 0;                        //设置x轴细分刻度：每一个主刻度范围内显示细分刻度的个数。注：如果没有细分刻度，则应该写0，而不是1
    
    //设置轴方向：坐标轴刻度方向、以及轴标签方向(CPTSignPositive正极朝向绘图区，CPTSignNegative负极朝外)
    xAxis.tickDirection = CPTSignPositive;
    xAxis.tickLabelDirection = CPTSignNegative;
    
    //设置主刻度线、细刻度线（颜色、宽度）
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];//创建了一个可编辑的线条风格lineStyle，用来描述描绘线条的宽度，颜色和样式等，这个 lineStyle 会被多次用到。
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineColor         = [CPTColor blueColor];  //线条颜色
    
    lineStyle.lineWidth         = 1.0;  //线条宽度
    xAxis.majorTickLineStyle = lineStyle;
    
    lineStyle.lineWidth         = 2.5;
    xAxis.minorTickLineStyle = lineStyle;
    
    //设置X轴其他设置（比如：实现哪些范围不显示轴信息（轴信息包含轴刻度和轴标签））
    /*
     NSArray *exclusionRanges_X = @[
     [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.99) length:CPTDecimalFromDouble(0.02)],
     [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(2.99) length:CPTDecimalFromDouble(0.02)]];
     x.labelExclusionRanges = exclusionRanges_X;//设置1.99-2.01，2.99-3.01范围内不显示轴信息，又由于这两个范围内原本只有2.0和3.0有轴信息，所以这里即成了2,3位置不显示轴信息
     */
    
}

- (void)completeYAxisSettingWithFixedYAxisByAbsolutePosition:(BOOL)fixedYAxisByAbsolutePosition {
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)self.axisSet;//获取XYGraph的轴的集合,其中包括xAxis和yAxis
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    
    if (fixedYAxisByAbsolutePosition) {//通过绝对位置，设置y轴的原点位置
        CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
        CPTPlotRange *xRange = xyPlotSpace.globalXRange;
        NSInteger xLength = [xRange.length integerValue];//self.chartDataModel.xMax
        yAxis.orthogonalPosition = @(xLength-10.0);
    } else {                                //通过相对位置位置，设置y轴的原点位置
        yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:kConstraintWithLowerOffsetY];
    }
    yAxis.majorIntervalLength         = @(5.0);
    yAxis.minorTicksPerInterval       = 4;
    yAxis.tickDirection = CPTSignPositive;
    yAxis.tickLabelDirection = CPTSignNegative;
    
    
    
    NSArray *exclusionRanges_Y  = @[
                                    [CPTPlotRange plotRangeWithLocation:@(1.99) length:@(0.02)],
                                    [CPTPlotRange plotRangeWithLocation:@(0.99) length:@(0.02)],
                                    [CPTPlotRange plotRangeWithLocation:@(3.99) length:@(0.02)]];
    yAxis.labelExclusionRanges = exclusionRanges_Y;
}



/** 根据当前x轴范围，设置标题及其位置（位置的计算是用来“实现固定轴标题”的目的的，轴标题的固定是需要考虑缩放等的变化的） */
- (void)completeXAxisTitle:(NSString *)title {
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)self.axisSet;//获取XYGraph的轴的集合,其中包括xAxis和yAxis
    CPTXYAxis *xAxis = xyAxisSet.xAxis;
    
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
    CPTPlotRange *xRange = xyPlotSpace.xRange;
    NSNumber *xTitleLocation = [CoreplotUtil calculateTitleLocationByCurRange:xRange];//固定轴标题
    
    xAxis.title = title;
    xAxis.titleDirection = CPTSignNegative;
    xAxis.titleOffset += -kConstraintWithLowerOffsetX;  //x轴标题偏移量(实际中，我们常常需要将标题设置在轴附近)
    xAxis.titleLocation = xTitleLocation;
}

- (void)completeYAxisTitle:(NSString *)title {
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)self.axisSet;//获取XYGraph的轴的集合,其中包括xAxis和yAxis
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    
//    NSInteger yTitleLocation = self.chartDataModel.yMax;
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *)self.defaultPlotSpace;
    CPTPlotRange *yRange = xyPlotSpace.globalYRange;
    NSNumber *yTitleLocation = @([yRange.location integerValue] + [yRange.length integerValue]  + adn_titleLocation_Y);
    
    yAxis.title = title;
    yAxis.titleDirection = CPTSignNegative;
    yAxis.titleOffset += -10;    //放大或缩小y轴默认标题与y坐标轴的距离,值越大距离越大
    yAxis.titleLocation = yTitleLocation;//设置标题位置
}


@end
