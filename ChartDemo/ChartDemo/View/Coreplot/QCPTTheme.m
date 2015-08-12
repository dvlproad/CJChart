//
//  QCPTTheme.m
//  Lee
//
//  Created by lichq on 14-11-25.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import "QCPTTheme.h"

#define Line_Color_GridLine         [CPTColor grayColor]//网格线颜色
#define Line_Width_GridLine         .2f                 //网格线宽度
#define Line_dashPattern_GridLine   @[@2.0, @2.0]       //网格线间隔

@implementation QCPTTheme


#pragma mark - 1、设置背景CPGraph:为背景设置一个自定义颜色渐变
- (void)applyThemeToBackground:(CPTGraph *)graph{
    //方法一：背景没渐变的情况，可直接设置颜色填充
    graph.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    
    /*
    //方法二、背景有渐变的情况下，使用下面方法
    //①、初始化一个渐变区：
    CPTGradient *graphGradient = [CPTGradient gradientWithBeginningColor:[CPTColor redColor]
                                                            endingColor:[CPTColor redColor]];
    //②、为原本的渐变去再增加中间渐变色:如位置在25％处，颜色为yellowColor
    graphGradient = [graphGradient addColorStop:[CPTColor yellowColor] atPosition:0.25f];
    graphGradient = [graphGradient addColorStop:[CPTColor orangeColor] atPosition:0.50f];

    //③、设置渐变区角度角度：垂直90度（逆时针）
    graphGradient. angle = 90.0f ;
    
    //④、将渐变区设置到画布上，以进行填充
    graph.fill = [CPTFill fillWithGradient:graphGradient];
    */
    
    //附：CPTColor的初始化方法
    //[CPTColor redColor]
    //[CPTColor colorWithCGColor:[CPTColor redColor].cgColor]
    //[CPTColor colorWithGenericGray:0.7f]
    //
}


#pragma mark - 2、设置坐标系风格:在坐标轴上画上网格线。附：网格线的添加这里都是在刻度上(主刻度、细分刻度)才会有的。下面添加Y轴的网格线，该Y轴网格线线会平行于X轴(方便对数值)
- (void)applyThemeToAxisSet:(CPTXYAxisSet *)axisSet{//这里的参数类型改成子类CPTXYAxisSet
    
    //设置网格线线型
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = Line_Width_GridLine;
    majorGridLineStyle.lineColor = Line_Color_GridLine;
    majorGridLineStyle.dashPattern = Line_dashPattern_GridLine;
    
    
    CPTXYAxis *y = axisSet.yAxis ;
    y.tickDirection = CPTSignNegative ;//轴标签方向：CPSignNone:无(同CPSignNegative)，CPSignPositive:反向(在y轴的右边)，CPSignNegative:正向(在y轴的左边)
    y.majorGridLineStyle = majorGridLineStyle;//majorGridLineStyle设置主刻度平行线
    
    
    CPTXYAxis *x = axisSet.xAxis ;
    x.majorGridLineStyle = majorGridLineStyle;
    
    //y.minorGridLineStyle = majorGridLineStyle;//minorGridLineStyle设置副刻度平行线
    //附：如果labelingPolicy设置为 CPAxisLabelingPolicyNone，majorGridLineStyle等将不起作用
    //y.labelingPolicy = CPAxisLabelingPolicyNone;
    
    
    /*
    //TODO怎么允许某个区域才显示网格线？
    CPTPlotRange *range =
        [CPTPlotRange plotRangeWithLocation:CPTDecimalFromString(@"55.0")
                                     length:CPTDecimalFromString(@"8")];
    y.gridLinesRange = range;//y轴的网格线是横向的，所以这里是横向网格线在X的什么范围内(注意不是y的什么范围)有效
    x.gridLinesRange = range;
    */
    
}

#pragma mark - 3、设置PlotArea风格:设置绘图区。
/*
注意由于绘图区（PlotArea）位于背景图（Graph）的上层（参考 Core Plot 框架的类层次图 ），因此对于绘图区所做的设置会覆盖对 Graph 所做的设置，除非你故意在 Graph 的 4 边留白，否则看不到背景图的设置。
*/
- (void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame{
    plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];//这里使用透明，即绘图区背景颜色与画布背景保持一致。
}

@end
