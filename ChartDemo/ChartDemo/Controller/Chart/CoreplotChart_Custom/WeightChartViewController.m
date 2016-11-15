//
//  WeightChartViewController.m
//  HealthyDiet
//
//  Created by lichq on 15-1-6.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "WeightChartViewController.h"

#import "CPTXYGraph+CompleteTitleForWeightChart.h"
#import "CPTXYGraph+CompletePaddingAndBorderForWeightChart.h"

#import "CPTXYGraph+CompleteXYPlotSpace.h"
#import "CPTXYGraph+CompleteXYAxisSet.h"

#import "QCPTTheme.h"
#import "CJChartAxisSetting.h"

static CPTTextStyle *yPositiveStyle = nil;
static CPTTextStyle *yNegativeStyle = nil;
static dispatch_once_t yPositiveOnce;
static dispatch_once_t yNegativeOnce;


static CGFloat standValue_Y = 55.0;


//边框属性
//绘图区plotArea的边框属性
#define border_Width_plotArea   4.0
#define border_Color_plotArea   [UIColor redColor].CGColor


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

//网格线设置
//去掉最开头、最结尾的网格线，其实是显示不到而已
#define globalXRange_NoShowAtBeginAndLast   0.1
#define globalYRange_NoShowAtBeginAndLast   0.1

#define Text_Color_isGreaterThanOrEqualTo_Y [CPTColor blackColor]   //y轴轴标签值大于指定值时候的文字颜色
#define Text_Color_isLessThan_Y             [CPTColor blackColor]     //y轴轴标签值小于指定值时候的文字颜色

#define Text_Color_Default_X                [CPTColor blackColor]     //x轴轴标签默认的文字牙呢

        
@interface WeightChartViewController () {
    
}
@property (nonatomic, strong) CJChartAxisSetting *chartAxisSetting;
@property (nonatomic, assign) BOOL customXAxis; /**< 自定义X轴 */
@property (nonatomic, assign) BOOL customYAxis; /**< 自定义Y轴 */

@property (nonatomic, strong) CPTPlotRange *globalXRange;
@property (nonatomic, strong) CPTPlotRange *globalYRange;
@property (nonatomic, strong) CPTPlotRange *currentXRange;//为了限制缩放的最小距离

@end

@implementation WeightChartViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //耗时的操作
        //sleep(5);
        [self getLocalInfoForWeight];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新界面
            [self reloadUIForWeight];
        });
    });
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.uid = @"1";
    //curValue = 55.0;
    //tarValue = 65.0;
    
#ifdef UseTempWeightData
    NSString *path = [[NSBundle mainBundle] pathForResource:@"weight.plist" ofType:nil];
    NSMutableArray *array = [[NSMutableArray alloc]initWithContentsOfFile:path];
    
    NSArray *tempData = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in array) {
        NSString *xDateString = [dic valueForKey:kADWKeyDate];
        NSString *yValueString = [dic valueForKey:kADWKeyWeight];
        
        ADWInfo *info = [[ADWInfo alloc] initWithXDateString:xDateString yValueString:yValueString];
        info.uid = [[dic valueForKey:kADWKeyUID] stringValue];
        info.wid = [dic valueForKey:kADWKeyWID];
        info.modified = [dic valueForKey:kADWKeyModified];
        
//        [tempData addObject:info];
        [QSqliteUtilADW insertInfo:info];
    }
#endif
    
    
    ADWInfo *info = [[ADWInfo alloc] initWithXDateString:@"2016-08-29" yValueString:@"72"];
    info.uid = self.uid;
    info.wid = @"10001";
    info.modified = @"1013513515";
    [ADWFMDBUtil insertInfo:info];
    
    ADWInfo *info2 = [[ADWInfo alloc] initWithXDateString:@"2016-09-04" yValueString:@"70"];
    info2.uid = self.uid;
    info2.wid = @"10002";
    info2.modified = @"1013513516";
    [ADWFMDBUtil insertInfo:info2];
    
    ADWInfo *info3 = [[ADWInfo alloc] initWithXDateString:@"2016-09-09" yValueString:@"65"];
    info3.uid = self.uid;
    info3.wid = @"10003";
    info3.modified = @"1013513517";
    [ADWFMDBUtil insertInfo:info3];
}



- (IBAction)addWeight:(id)sender{
    
}


/** 获取本地数据库中的体重数据 */
- (void)getLocalInfoForWeight {
    self.datas = [ADWFMDBUtil selectInfoArrayWhereUID:self.uid];
    NSLog(@"self.datas = %@", self.datas);
}

/** 更新体重的UI */
- (void)reloadUIForWeight {
    self.chartDataModel = [[CJChartData alloc] initWithXShowCountLeast:3 xShowCountDefault:10];
    self.chartDataModel.xPlaceholderUnitCountBegin = 2;
    self.chartDataModel.xPlaceholderUnitCountLast = 2;
    self.chartDataModel.yMinWhenEmpty = standValue_Y - 5;
    self.chartDataModel.yMaxWhenEmpty = standValue_Y + 6;
    [self.chartDataModel completeChartDataByData:self.datas];
    
    
    self.chartAxisSetting = [[CJChartAxisSetting alloc] init];
    self.chartAxisSetting.fixedXAxisByAbsolutePosition = YES;
    self.chartAxisSetting.fixedYAxisByAbsolutePosition = YES;
    
    [self reloadChartUI];
}

- (void)reloadChartUI {
    self.customXAxis = YES;
    self.customYAxis = YES;
    [self createCPTXYGraph];
    //[self.graphHostingView.hostedGraph reloadData];//刷新画板
}



- (void)createCPTXYGraph {
#pragma mark 创建基于XY轴图CPTXYGraph，并对XY轴图进行设置
#pragma mark ———————-———————1.添加主题，标题，设置与屏幕边缘之间的空隙
    CPTXYGraph *xyGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    //CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    CPTTheme *theme = [[QCPTTheme alloc]init];  //自定义coreplot主题
    [xyGraph applyTheme:theme];                //添加画布Graph的主题Theme
    [xyGraph completeGraphTitle:NSLocalizedString(@"体重趋势图", nil) subTitle:@""];
    [xyGraph completeGraphPaddingAndBorder];
    
    
    self.lineGraph = xyGraph;
    self.graphHostingView.hostedGraph     = xyGraph;
    self.graphHostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    self.graphHostingView.allowPinchScaling = YES;
    
    
    
#pragma mark ———————-———————2.设置可视空间CPTXYPlotSpace
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *)xyGraph.defaultPlotSpace;
    [xyGraph completeXYPlotSpaceCommonSetting];
    [xyGraph completeXYPlotSpaceRangeByChartDataModel:self.chartDataModel];
    [xyPlotSpace setDelegate:self];//用来设置缩放操作.注意：这里需要等到设置完plotSpace的xyRange和globalXYRange之后，才能设置setDelegate。否则会出现坐标轴为空的原因是否是delegate方法中有部分数据需要这里的range呢？
    //TODO
    self.globalXRange = xyPlotSpace.globalXRange;
    self.currentXRange = xyPlotSpace.xRange;
    self.globalYRange = xyPlotSpace.yRange;
    
    
    
#pragma mark ———————-———————3.设置两个轴 CPTXYAxis
    // Axes设置x,y轴属性，如原点，量度间隔，标签，刻度，颜色等
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)xyGraph.axisSet;//获取XYGraph的轴的集合,其中包括xAxis和yAxis
    CPTXYAxis *xAxis = xyAxisSet.xAxis;
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    [xyGraph completeXAxisSettingWithFixedXAxisByAbsolutePosition:self.chartAxisSetting.fixedXAxisByAbsolutePosition];
    [xyGraph completeYAxisSettingWithFixedYAxisByAbsolutePosition:self.chartAxisSetting.fixedYAxisByAbsolutePosition];
    [xyGraph completeXAxisTitle:@"时间"];
    [xyGraph completeYAxisTitle:@"体重(Kg)"];
    
    xAxis.plotArea.borderWidth = border_Width_plotArea;
    xAxis.plotArea.borderColor = border_Color_plotArea;
    yAxis.plotArea.borderWidth = 3;
    yAxis.plotArea.borderColor = [UIColor greenColor].CGColor;

    
    if (self.customXAxis) {
        xAxis.delegate             = self;//需要实现CPTAxisDelegate协议,以此来定制主刻度显示标签
    }
    if (self.customYAxis) {
        yAxis.delegate             = self;//需要实现CPTAxisDelegate协议,以此来定制主刻度显示标签
    }
    
#pragma mark 添加曲线图CPTScatterPlot
    [self addScatterPlotForGraph:xyGraph];
}




/*
 - (CPTPlotRange *)getPlotRangeWithMin:(CGFloat)min max:(CGFloat)max {
 return [CPTPlotRange plotRangeWithLocation:@(min) length:@(max - min)];
 }
 */




//添加曲线图CPTScatterPlot
- (void)addScatterPlotForGraph:(CPTXYGraph *)newGraph{
    CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier    = @"Blue Plot"; //曲线图的标识（注意：一个图中可以有多个曲线图，每个曲线图通过其 identifier 进行唯一标识。）
    boundLinePlot.dataSource    = self;         //曲线图的数据源
    boundLinePlot.delegate = self;  //曲线图的委托，比如实现各个数据点响应操作的CPTScatterPlotDelegate委托
    
    //①、设置曲线图中的曲线（线条颜色、宽度、如果是破折线，还要设置破折线样式dashPattern）
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];//创建了一个可编辑的线条风格
    lineStyle.lineColor = Line_Color_ScatterPlot;
    lineStyle.lineWidth = Line_Width_ScatterPlot;
    lineStyle.dashPattern = Line_dashPattern_ScatterPlot;//破折号dash样式
    boundLinePlot.dataLineStyle = lineStyle;    //曲线图的曲线属性
    
    //②、设置曲线图中曲线上的的数值点的符号（形状、大小、颜色）Add plot symbols:
    CPTPlotSymbol *plotSymbol = PlotSymbol_Style;//设为圆点
    plotSymbol.fill          = [CPTFill fillWithColor:PlotSymbol_Color];
    //设置点的边缘线的颜色以及宽度
    CPTMutableLineStyle *symbolLineStyle = Line_Style_PlotSymbol;
    symbolLineStyle.lineColor = Line_Color_PlotSymbol;
    symbolLineStyle.lineWidth = Line_Widht_PlotSymbol;
    plotSymbol.lineStyle     = symbolLineStyle; //圆点的边缘线
    plotSymbol.size          = PlotSymbol_Size;
    boundLinePlot.plotSymbol = plotSymbol;  //设置曲线上的数值点的符号形状
    
    
    //③、设置曲线图中曲线覆盖区域areaFill的填充（填充色、填充其实位置）
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(1.0) blue:CPTFloat(0.3) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    boundLinePlot.areaFill      = areaGradientFill;
    boundLinePlot.areaBaseValue = @(1.75);
    
    
    [newGraph addPlot:boundLinePlot];
}





//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//



//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
#pragma mark - 给折现上的点添加值（plot添加值的折现  index点的位置 ）//参考饼状图CPTPieChartViewController的绘制
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx{
    CJChartPlotData *chartPlotData = [self.chartDataModel.yPlotDatas objectAtIndex:idx];
    NSString *yText = [NSString stringWithFormat:@"%.1f", chartPlotData.y];
    
    CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:yText];
    
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
    
    textStyle.color = [CPTColor greenColor];
    textStyle.fontSize = 10.0f;
    label.textStyle = textStyle;
    
    
    return label;
}
 
 
#pragma mark 点击各个数据点响应操作(需添加CPTScatterPlotDelegate协议)
- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx{
    
//    NSDecimalNumber *deNumber = [NSDecimalNumber decimalNumberWithDecimal:plot.areaBaseValue];//NSDecimal转为NSDecimalNumber
//    NSLog(@"idx = %zd, %f, %f, %@, %@", idx, plot.labelOffset, [deNumber floatValue], NSStringFromCGRect(plot.contentsRect), NSStringFromCGPoint(plot.position));
    //plot.plotArea.axisSet;
    //TODO怎么获取所点击的坐标点的位置
    
}
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//




#pragma mark -
#pragma mark - CPTPlotDataSource 实现数据源协议
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.chartDataModel.yPlotDatas.count;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    CJChartPlotData *chartPlotData = [self.chartDataModel.yPlotDatas objectAtIndex:index];
    
    NSNumber *number = nil;
    if (fieldEnum == CPTScatterPlotFieldX) {
        number = [NSNumber numberWithFloat:chartPlotData.x];
    } else {
        number = [NSNumber numberWithFloat:chartPlotData.y];
    }
    return number;
}

#pragma mark - CPTAxisDelegate (X轴、Y轴标签设置)
- (BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    //NSLog(@"dataForXLable->%d ?=? %d<-locationsCount", self.dataForXLable.count, locations.count);
    //注locations只代表主刻度上的那些location
    
    /* Y轴标签设置 */
    if (axis.coordinate == CPTCoordinateY) {
        //CGFloat labelOffset    = axis.labelOffset;
        NSNumber *n_standValue_Y  = [NSNumber numberWithFloat:standValue_Y];
        
        NSMutableSet *axisLabelsY = [NSMutableSet set];
        for ( NSDecimalNumber *location in locations ) {
            CPTAxisLabel *axisLabel = [self yAxis:axis axisLabelAtLocation:location withBaseValue:n_standValue_Y];
            [axisLabelsY addObject:axisLabel];
        }
        axis.axisLabels = axisLabelsY;
        
        return NO;
    }
    
    
    /* X轴标签设置 */
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
#pragma mark 功能：实现缩放时候，轴标签能根据轴上的点的个数自适应，以使得不会出现轴标签密密麻麻的排在一起的情况
    NSInteger gapNumForDay = [self getGapDistanceAtLocations:locations];
    NSInteger gapNumForMonth = [self getGapDistanceForMonthAtLocations:locations];
    
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
        
        CJDate *myDate = [self.chartDataModel.xDatas objectAtIndex:[location integerValue]];
        
        if ([location intValue]%gapNumForDay == 0) {
            //②、获取当前location上的标签文本值
            //NSFormatter *formatter = axis.labelFormatter;
            //NSString *axisLabelText = [formatter stringForObjectValue:location];
            
            NSString *axisLabelTextDay = @"kong";
            
            
            if (myDate.isFirstDayInMonth) {
                axisLabelTextDay = [NSString stringWithFormat:@"%zd.%02zd", myDate.month, myDate.day];
            }else{
                axisLabelTextDay = [NSString stringWithFormat:@"%zd", myDate.day];
            }
            
            CPTAxisLabel *axisLabel = [self xAxisDay:axis axisLabelAtLocation:location withText:axisLabelTextDay];
            [axisLabelsX addObject:axisLabel];
        }
        
        
        if ([location intValue]%gapNumForMonth == 0) {
            //获取当前location上的标签文本值
            NSString *axisLabelTextMonth = @"kong";
        
            if (myDate.isMiddleDayInMonth) {
                axisLabelTextMonth = [NSString stringWithFormat:@"%zd月", myDate.month];
                
                CPTAxisLabel *axisLabel = [self xAxisMonth:axis axisLabelAtLocation:location withText:axisLabelTextMonth];
                [axisLabelsX addObject:axisLabel];
            }
        }
    }
    
    axis.axisLabels = axisLabelsX;
    
    return NO;//因为在这里我们自己设置了轴标签的描绘，所以这个方法返回 NO 告诉系统不需要使用系统的标签描绘设置了。
}


/**
 *  计算最后绘制出来的轴刻度要以每隔多少间隔才绘制一个（以防当轴上的点过多时，如果全绘制会导致轴刻度密密麻麻的）
 *
 *  @return 相邻刻度的间隔（计算方法为：通过设置最大允许多少刻度来计算）
 */
- (NSInteger)getGapDistanceAtLocations:(NSSet *)locations {
    NSInteger gapNum = 1;//每间隔gapNum个刻度单位再显示。
    NSInteger maxTickShowNumber = self.chartDataModel.xShowCountLeast; //设置坐标轴最多展示多少个刻度
    if ([locations count] > maxTickShowNumber) { //如果locations的个数超过自己规定的个数(这里设为7个)
        gapNum = [locations count]/maxTickShowNumber;
        NSLog(@"gapNum = %zd", gapNum);
    }
    return gapNum;
}


- (NSInteger)getGapDistanceForMonthAtLocations:(NSSet *)locations {
    NSInteger gapNum = 1;
    NSInteger maxTickShowNumber = self.chartDataModel.xShowCountLeast; //设置坐标轴最多展示多少个刻度
    if ([locations count] > maxTickShowNumber) {
        gapNum = [locations count]/maxTickShowNumber; //设置"月"行最多展示
        NSLog(@"gapNum = %zd", gapNum);
    }
    return gapNum;
}

- (CPTAxisLabel *)yAxis:(CPTAxis *)axis axisLabelAtLocation:(NSDecimalNumber *)location withBaseValue:(NSNumber *)n_standValue_Y {
    //NSLog(@"location = %@: %d", location, [location intValue]);
    
    
    //①、获取标签样式
    CPTTextStyle *theLabelTextStyle = [axis.labelTextStyle mutableCopy];
    
    
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
#pragma mark 功能：对轴上不同的点设置不同的刻度标签颜色，如与standValue为标准，大于等于用一种，小于用另外一种
    if ( [location isGreaterThanOrEqualTo:n_standValue_Y] ) {
        dispatch_once(&yPositiveOnce, ^{
            CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
            newStyle.color = Text_Color_isGreaterThanOrEqualTo_Y;
            yPositiveStyle = newStyle;
        });
        
        theLabelTextStyle = yPositiveStyle;
    }
    else {
        dispatch_once(&yNegativeOnce, ^{
            CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
            newStyle.color = Text_Color_isLessThan_Y;
            yNegativeStyle = newStyle;
        });
        
        theLabelTextStyle = yNegativeStyle;
    }
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//
    
    
    //②、获取标签文本
    NSString *labelString       = [NSString stringWithFormat:@"%d", [location intValue]];
    CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
    
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
    
    axisLabel.tickLocation = location;
    axisLabel.offset       = axis.labelOffset + offset_axisConstraints_Y;
    //axisLabel.offset       = x.labelOffset + x.majorTickLength;
    //axisLabel.rotation     = CPTFloat(M_PI_4);
    
    return axisLabel;
}


- (CPTAxisLabel *)xAxisDay:(CPTAxis *)axis axisLabelAtLocation:(NSDecimalNumber *)location withText:(NSString *)text {
    //①、获取标签样式
    static CPTTextStyle *positiveStyle = nil;
    static dispatch_once_t positiveOnce;
    
    CPTTextStyle *theLabelTextStyle;
    dispatch_once(&positiveOnce, ^{
        CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
        newStyle.color = Text_Color_Default_X;
        positiveStyle = newStyle;
    });
    theLabelTextStyle = positiveStyle;
    
    CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] init];
    [newLabelLayer setText:text];
    [newLabelLayer setTextStyle:theLabelTextStyle];
    
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
    
    axisLabel.tickLocation = location;
    
    axisLabel.offset       = axis.labelOffset + offset_axisConstraints_X;
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
- (CPTAxisLabel *)xAxisMonth:(CPTAxis *)axis axisLabelAtLocation:(NSDecimalNumber *)location withText:(NSString *)text {
    CPTTextStyle *theLabelTextStyle;
    static CPTTextStyle *positiveStyle = nil;
    static dispatch_once_t positiveOnce;
    dispatch_once(&positiveOnce, ^{
        CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
        newStyle.color = [CPTColor redColor];
        positiveStyle = newStyle;
    });
    theLabelTextStyle = positiveStyle;
    
    
    CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] init];
    [newLabelLayer setText:text];
    [newLabelLayer setTextStyle:theLabelTextStyle];
    
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
    //axisLabel.tickLocation = tickLocation.decimalValue;
    double dValue = location.doubleValue + 0.1; //为了不让它覆盖掉之前的lable，所以加0.1，而不是整数
    NSDecimalNumber *result = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:dValue];
    axisLabel.tickLocation = result;
    
    axisLabel.offset       = axis.labelOffset + offset_axisConstraints_X + 20;
    //axisLabel.offset       = x.labelOffset + x.majorTickLength;
    //axisLabel.rotation     = CPTFloat(M_PI_4);
    
    return axisLabel;
}




//TODO 以下代码为新增
- (BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint{
//    NSLog(@"interactionScale = %f %@", interactionScale, NSStringFromCGPoint(interactionPoint));
    return true;
}

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(UIEvent *)event atPoint:(CGPoint)point{
//    NSLog(@"event = %@", event);
    return YES;
}

///*
//放大缩小包括滑动的时候都会调用它
- (CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    
    
    if ( coordinate == CPTCoordinateY){
        
        #pragma mark 功能：禁止Y轴缩放（虽然之前以通过设置Y的range和gloalrange来实现禁止Y轴的移动，这种情况下，虽然Y轴缩放的时候没法再原来的基础上再缩小了，但却还会有在原来的基础上放大的情况，所以为保证Y轴不止不能移动，也要不能缩放，这里要在原来禁止移动的基础上，禁止掉Y轴的缩放。
        CPTXYPlotSpace *xySpace = (CPTXYPlotSpace*)space;
        return xySpace.yRange; //xySpace.globalYRange
        //return yPlotRange;//与上述等价。参见：http://blog.csdn.net/guicl0219/article/details/9361499
        //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//
        
    }else{
    
        CPTXYGraph *newGraph  = (CPTXYGraph *)[space graph];
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
        CPTXYAxis *x          = axisSet.xAxis;
        
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
        #pragma mark CorePlot 点线图的时候，缩放不超过 一定范围的功能实现(参见：http://blog.csdn.net/remote_roamer/article/details/8936889)
        //限制缩放和移动的时候。不超过原始范围
        
        
        if ([self.globalXRange containsRange:newRange]){
            //如果缩放范围在 原始范围内。则返回缩放范围
            
            //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
            #pragma mark 功能：缩放时候，当放大到太大的时候，即轴上的数值点（即单位长度，而不是指显示的轴标签个数，因为很明显两个轴标签之间可能有多个数值）小于最少规定的数值点时，不让其继续缩放。（因为缩放到太大的时候，可能导致一个坐标系里都看不到一个点。）
            if (newRange.lengthDouble < self.chartDataModel.xShowCountLeast) {//这里是通过newRange.length来判断。不是通过locations.length来判断。实际上两者是等价的。只不过是这里取不到locations.length而已
                return self.currentXRange;
            }
            self.currentXRange = newRange;
            //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//
            
            
            x.titleLocation = [CoreplotUtil calculateTitleLocationByCurRange:newRange];
            
            return newRange;
            
        }else if([newRange containsRange:self.globalXRange]){
            //如果缩放范围在原始范围外，则返回原始范围
            return self.globalXRange;
            
        }else{
            //如果缩放和移动，导致新范围和元素范围向交叉。则要控制左边或者右边超界的情况
            double oldXRangeMin = [self.globalXRange.location doubleValue];
            double newXRangeMin = [newRange.location doubleValue];
            
            double oldXRangeMax = [self.globalXRange.end doubleValue]; //TODO: 待验证
            double newXRangeMax = [newRange.end doubleValue];
            
            NSLog(@"willChangePlotRangeTo  newRange :%@\n xplotRange is %@",newRange,self.globalXRange);
            
            if (oldXRangeMin >= newXRangeMin){
                //限制左边不超界
                CPTPlotRange * returnPlot = [[CPTPlotRange alloc ] initWithLocation:self.globalXRange.location length:newRange.length];
                return returnPlot;
            }
            
            if (newXRangeMax > oldXRangeMax){
                double offset = newXRangeMax - oldXRangeMax;
                
                //限制右边不超界
                CPTPlotRange * returnPlot = [[CPTPlotRange alloc ] initWithLocation:[NSNumber numberWithDouble:(newXRangeMin - offset)] length:newRange.length];
                //                CPTPlotRange * returnPlot = [[CPTPlotRange alloc ] initWithLocation:newRange.location length:xPlotRange.length];
                NSLog(@"右边超界，超界 %f", offset);
                NSLog(@"将要返回的 range 是：%@",returnPlot);
                
                
                x.titleLocation = [CoreplotUtil calculateTitleLocationByCurRange:returnPlot];
                return returnPlot;
            }
        }
        return newRange;
        //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//
    }
}

//*/


//add by lichq
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"WillBeginDragging");
}

- (void)dealloc{
    [picker_birthday dismiss];
    picker_birthday.delegate = nil;
    picker_birthday = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
