//
//  CPTScatterPlot+Complete.m
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CPTScatterPlot+Complete.h"

//曲线上线的属性
#define Line_Color_ScatterPlot          [CPTColor greenColor]
#define Line_Width_ScatterPlot          1.0
#define Line_dashPattern_ScatterPlot    @[@5.0, @5.0]


//圆点上圆点的属性
#define PlotSymbol_Style    [CPTPlotSymbol ellipsePlotSymbol] //符号形状类型：实心原点
#define PlotSymbol_Color    [CPTColor greenColor] //点的填充色
#define PlotSymbol_Size     CGSizeMake(6.0, 6.0)  //点的大小

//原点上线的属性
#define Line_Style_PlotSymbol [CPTMutableLineStyle lineStyle] //点的边缘线类型
#define Line_Color_PlotSymbol [CPTColor whiteColor] //点的边缘线的颜色
#define Line_Widht_PlotSymbol 2.0   //点的边缘线的宽度（点固定大小时候，边缘线越宽，实心点越小）


@implementation CPTScatterPlot (Complete)

//添加曲线图CPTScatterPlot
- (void)completeScatterPlot:(NSString *)identifier {
    self.identifier    = identifier; //曲线图的标识（注意：一个图中可以有多个曲线图，每个曲线图通过其 identifier 进行唯一标识。）
    
    //①、设置曲线图中的曲线（线条颜色、宽度、如果是破折线，还要设置破折线样式dashPattern）
    self.dataLineStyle = [self getDataLineStyle];    //曲线图的曲线属性
    
    //②、设置曲线图中曲线上的的数值点的符号（形状、大小、颜色）Add plot symbols:
    CPTPlotSymbol *plotSymbol = PlotSymbol_Style;//设为圆点
    plotSymbol.fill          = [CPTFill fillWithColor:PlotSymbol_Color];
    //设置点的边缘线的颜色以及宽度
    plotSymbol.lineStyle     = [self getPlotSymbolLineStyle]; //圆点的边缘线
    plotSymbol.size          = PlotSymbol_Size;
    self.plotSymbol = plotSymbol;  //设置曲线上的数值点的符号形状
    
    
    //③、设置曲线图中曲线覆盖区域areaFill的填充（填充色、填充其实位置）
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(1.0) blue:CPTFloat(0.3) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    self.areaFill      = areaGradientFill;
    self.areaBaseValue = @(1.75);
}

- (CPTMutableLineStyle *)getDataLineStyle {
    CPTMutableLineStyle *dataLineStyle = [CPTMutableLineStyle lineStyle];//创建了一个可编辑的线条风格
    dataLineStyle.lineColor = Line_Color_ScatterPlot;
    dataLineStyle.lineWidth = Line_Width_ScatterPlot;
    dataLineStyle.dashPattern = Line_dashPattern_ScatterPlot;//破折号dash样式
    
    return dataLineStyle;
}

- (CPTMutableLineStyle *)getPlotSymbolLineStyle {
    CPTMutableLineStyle *plotSymbolLineStyle = Line_Style_PlotSymbol;
    plotSymbolLineStyle.lineColor = Line_Color_PlotSymbol;
    plotSymbolLineStyle.lineWidth = Line_Widht_PlotSymbol;
    
    return plotSymbolLineStyle;
}

@end
