//
//  CPTScatterPlotViewController.m
//  Lee
//
//  Created by lichq on 14-11-19.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import "CPTScatterPlotViewController.h"

@interface CPTScatterPlotViewController ()

@end



@implementation CPTScatterPlotViewController
@synthesize dataForPlot;
@synthesize lineGraph;
@synthesize graphHostingView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"ScatterPlot", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

#pragma mark 创建基于XY轴图CPTXYGraph，并对XY轴图进行设置
    #pragma mark ———————-———————1.添加主题，设置与屏幕边缘之间的空隙
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];//设置主题（相当于设置背景）附：目前支持五种主题:kCPTDarkGradientTheme, kCPTPlainBlackTheme, kCPTPlainWhiteTheme, kCPTSlateTheme(石板色主题),kCPTStocksTheme(股票主题)，
    [newGraph applyTheme:theme];    //设置CPTXYGraph的主题
    newGraph.paddingLeft   = 10.0;  //设置图的四周与屏幕边缘之间的空隙大小
    newGraph.paddingTop    = 10.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingBottom = 10.0;
    self.lineGraph = newGraph;
    self.graphHostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    self.graphHostingView.hostedGraph     = newGraph;//将hostingView的hostedGraph与graph关联起来，也就是说：我们要在View(CPTGraphHostingView)上画一个基于xy轴的图（CPTXYGraph）。
    
    #pragma mark ———————-———————2.设置可视空间CPTPlotSpace
    //设置一屏内可显示的x,y量度范围plotSpace
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    
    //设置x轴方向的量度范围：起点1.0, 长度2个单位
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(1.0)
                                                    length:@(2.0)];
    
    //设置y轴方向的量度范围：起点1.0, 长度3个单位
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(1.0)
                                                    length:@(3.0)];
    
    //设置轴滑动范围。X轴滑动范围为从0开始后的5个单位长度，Y轴范围从1开始后的3个单位，而又Y轴初始显示区域就是从1开始并且3个单位长度，所以Y轴不能滑动，即此处只能坐标只能按照X轴横向滑动
    plotSpace.globalXRange=[CPTPlotRange plotRangeWithLocation:@(0.0)
                                                    length:@(5.0)];
    plotSpace.globalYRange=[CPTPlotRange plotRangeWithLocation:@(1.0)
                                                        length:@(3.0)];
    
    
    plotSpace.allowsUserInteraction = YES;  //是否允许拖动
    //[self.graphHostingView setAllowPinchScaling:NO];//禁止缩放：（两指捏扩动作）
    
    #pragma mark ———————-———————3.设置两个轴 CPTXYAxis
    // Axes设置x,y轴属性，如原点，量度间隔，标签，刻度，颜色等
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;//获取XYGraph的轴的集合,其中包括xAxis和yAxis
    CPTXYAxis *x          = axisSet.xAxis;
    x.orthogonalPosition = @(2.0);//设置x轴的原点位置
    x.majorIntervalLength         = @(0.5);//设置x轴主刻度：每0.5显示一个刻度
    x.minorTicksPerInterval       = 2;//设置x轴细分刻度：每一个主刻度范围内显示细分刻度的个数,即0.5刻度之间再显示两个细刻度
    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:@(1.99)
                                                              length:@(0.02)],
                                 [CPTPlotRange plotRangeWithLocation:@(0.99)
                                                              length:@(0.02)],
                                 [CPTPlotRange plotRangeWithLocation:@(2.99)
                                                              length:@(0.02)]];
    x.labelExclusionRanges = exclusionRanges;//设置1.99-2.01，0.99-1.01，2.99-3.01不显示数字的主刻度，又x轴每0.5显示一个刻度，所以这里即1,2,3不显示刻度
    
    CPTXYAxis *y = axisSet.yAxis;
    y.orthogonalPosition = @(2.0);
    y.majorIntervalLength         = @(0.5);
    y.minorTicksPerInterval       = 5;
    exclusionRanges          = @[[CPTPlotRange plotRangeWithLocation:@(1.99)
                                                              length:@(0.02)],
                                 [CPTPlotRange plotRangeWithLocation:@(0.99)
                                                              length:@(0.02)],
                                 [CPTPlotRange plotRangeWithLocation:@(3.99)
                                                              length:@(0.02)]];
    y.labelExclusionRanges = exclusionRanges;
    y.delegate             = self;//需要实现CPTAxisDelegate协议,以此来定制主刻度显示标签
    
    
    // Create a blue plot area
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];//创建了一个可编辑的线条风格lineStyle，用来描述描绘线条的宽度，颜色和样式等，这个 lineStyle 会被多次用到。
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 2.0;  //线条宽度
    lineStyle.lineColor         = [CPTColor redColor];  //线条颜色
    
//    x.minorTickLineStyle = lineStyle;
    
    
    
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 3.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    
#pragma mark 添加蓝红渐变的曲线图CPTScatterPlot
    //下面我们向图中添加曲线的描绘
    CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
    boundLinePlot.dataLineStyle = lineStyle;    //曲线图的曲线属性
    boundLinePlot.identifier    = @"Blue Plot"; //曲线图的标识（注意：一个图中可以有多个曲线图，每个曲线图通过其 identifier 进行唯一标识。）
    boundLinePlot.dataSource    = self;         //曲线图的数据源
    
    //Do a red-blue gradient: 渐变色区域 如果我们不仅仅是描绘曲线，还想描绘曲线覆盖的区域，那么就要设置曲线图的区域填充颜色 areaFill，并设置 areaBaseValue。areaBaseValue就是设置该填充颜色从哪个值开始描述，比如本例是从1.0开始描绘
    /*
    CPTColor * blueColor  = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
    CPTColor * redColor   = [CPTColor colorWithComponentRed:1.0 green:0.3 blue:0.3 alpha:0.8];
    CPTGradient * areaGradient1 = [CPTGradient gradientWithBeginningColor:blueColor
                                                              endingColor:redColor];//从红色变到蓝色的渐变色 CPTGradient
    areaGradient1.angle = -90.0f;//将渐变色旋转-90度（即顺时针方向旋转90度），使得红色在下面，蓝色在上面
    CPTFill * areaGradientFill  = [CPTFill fillWithGradient:areaGradient1];
    boundLinePlot.areaFill      = areaGradientFill;//设置曲线图区域的填充颜色
//    */
//    /*
    CPTImage *fillImage = [CPTImage imageNamed:@"imageFill0"];
    fillImage.tiled = YES;
    CPTFill *areaImageFill = [CPTFill fillWithImage:fillImage];
    boundLinePlot.areaFill      = areaImageFill;;   //设置曲线图区域的填充图片
//    */
    boundLinePlot.areaBaseValue = [NSNumber numberWithFloat:1.0]; // 渐变色的起点位置
    
    
    // Add plot symbols: 曲线上的数值点的符号形状（下面用蓝色的实心原点）
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    symbolLineStyle.lineWidth = 2.0;
    
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];//符号形状类型：实心原点
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor yellowColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;  //设置曲线上的数值点的符号形状
    
    [newGraph addPlot:boundLinePlot];
    
    
#pragma mark 添加破折线风格的绿色曲线图CPTScatterPlot
    // Create a green plot area
    lineStyle                        = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth              = 3.f;
    lineStyle.lineColor              = [CPTColor greenColor];
    lineStyle.dashPattern            = @[@5.0, @5.0];
    
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.dataLineStyle = lineStyle;//破折线风格的线条
    dataSourceLinePlot.identifier    = @"Green Plot";
    dataSourceLinePlot.dataSource    = self;
    
    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(1.0) blue:CPTFloat(0.3) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient_2 = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient_2.angle = -90.0;
    CPTFill *areaGradientFill_2 = [CPTFill fillWithGradient:areaGradient_2];
    dataSourceLinePlot.areaFill      = areaGradientFill_2;
    dataSourceLinePlot.areaBaseValue = @(1.75);
    
    // Animate in the new plot, as an example 淡入动画
    dataSourceLinePlot.opacity = 0.0;
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 2.0;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = @1.0;//即[NSNumber numberWithFloat:1.0];
    [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
    [newGraph addPlot:dataSourceLinePlot];
    
    
    
#pragma mark 初始化数据
    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
    for ( NSUInteger i = 0; i < 60; i++ ) {
        NSNumber *xVal = @(1.0 + i * 0.05);
        NSNumber *yVal = @(1.2 * arc4random() / (double)UINT32_MAX + 1.2);//rand(), (float)RAND_MAX
        [contentArray addObject:@{ @"x": xVal, @"y": yVal }];
    }
    self.dataForPlot = contentArray;
    
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];//动态修改 CPTPlotSpace 的范围
#endif
}

-(void)changePlotRange
{
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.lineGraph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(0.0) length:@(3.0 + 2.0 * arc4random() / UINT32_MAX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(0.0) length:@(3.0 + 2.0 * arc4random() / UINT32_MAX)];
}

#pragma mark -
#pragma mark Plot Data Source Methods 实现数据源协议

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.dataForPlot.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = self.dataForPlot[index][key];
    
    // Green plot gets shifted above the blue
    if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
        if ( fieldEnum == CPTScatterPlotFieldY ) {
            num = @([num doubleValue] + 1.0);
        }
    }
    return num;
}

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle *positiveStyle = nil;
    static CPTTextStyle *negativeStyle = nil;
    static dispatch_once_t positiveOnce;
    static dispatch_once_t negativeOnce;
    
    NSFormatter *formatter = axis.labelFormatter;
    CGFloat labelOffset    = axis.labelOffset;
    NSDecimalNumber *zero  = [NSDecimalNumber zero];
    
    NSMutableSet *newLabels = [NSMutableSet set];
    
    for ( NSDecimalNumber *tickLocation in locations ) {
        CPTTextStyle *theLabelTextStyle;
        
        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) { //对于轴上大于等于0的刻度标签用绿色描绘
            dispatch_once(&positiveOnce, ^{
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor greenColor];
                positiveStyle = newStyle;
            });
            
            theLabelTextStyle = positiveStyle;
        }
        else {
            dispatch_once(&negativeOnce, ^{ //小于0的刻度标签用红色描绘
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                negativeStyle = newStyle;
            });
            
            theLabelTextStyle = negativeStyle;
        }
        
        NSString *labelString       = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation;
        newLabel.offset       = labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels;
    
    return NO;//因为在这里我们自己设置了轴标签的描绘，所以这个方法返回 NO 告诉系统不需要使用系统的标签描绘设置了。
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
