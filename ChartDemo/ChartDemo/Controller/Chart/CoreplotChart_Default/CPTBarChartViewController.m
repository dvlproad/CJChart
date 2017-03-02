//
//  CPTBarChartViewController.m
//  Lee
//
//  Created by lichq on 14-11-24.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import "CPTBarChartViewController.h"

@interface CPTBarChartViewController ()

@end



@implementation CPTBarChartViewController

@synthesize timer;
@synthesize barChart;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"BarChart", nil);
    }
    return self;
}

#pragma mark -
#pragma mark Initialization and teardown
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)reloadChartUI{
    [self setUpBarData];
    //[self.graphHostingView.hostedGraph reloadData];//因为这里涉及到柱状图的颜色要重新绘制，而不只是柱状图的大小，所以，我们不适用reloadData，而使用重新创建的createChart方法
    [self createChart];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //初始化数据
    [self setUpBarData];
    [self createChart];
    
#ifdef MEMORY_TEST
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                selector:@selector(timerFired) userInfo:nil repeats:YES];
#endif
}


-(void)timerFired
{
    static NSUInteger counter = 0;
    
    NSLog(@"\n----------------------------\ntimerFired: %ld", counter++);
    [self setUpBarData];
    [self createChart];
}

#pragma mark - 初始化数据
- (void)setUpBarData{
    NSMutableArray *contentArrayBG = [NSMutableArray arrayWithCapacity:100];
    for ( NSUInteger i = 0; i < 5; i++ ) {
        NSNumber *xVal = @(i + 0.5);//在这里加上0.5之后，下面的柱状图就可以不用偏移了
        NSNumber *yVal = @(300);
        [contentArrayBG addObject:@{ @"x": xVal, @"y": yVal }];
    }
    self.dataForBarBG = contentArrayBG;
    self.colorForBarBG = [CPTColor lightGrayColor];
    
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
    for ( NSUInteger i = 0; i < 5; i++ ) {
        NSNumber *xVal = @(i + 0.5);//在这里加上0.5之后，下面的柱状图就可以不用偏移了
        NSNumber *yVal = @(rand()%7 * 50);
        [contentArray addObject:@{ @"x": xVal, @"y": yVal }];
    }
    self.dataForBar = contentArray;
    self.colorForBar = [CPTColor greenColor];
}

- (void)createChart{
    
    // Create barChart from theme
    CPTXYGraph *newGraph = [self initizileCPTXYGraph];
    self.barChart = newGraph;
    self.graphHostingView.hostedGraph = newGraph;
    
    // Graph title
    [self setUpGraphTitle:newGraph];
    
    #pragma mark 设置课件范围X轴:0-16; Y轴0-300
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(0.0)
                                                    length:@(self.dataForBarBG.count)];//这里的长度记得设成BG的长度
    
    CGFloat yMax = [[[self.dataForBarBG firstObject] valueForKey:@"y"] floatValue];//设置柱状图的最大值
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(0.0)
                                                    length:@(yMax)];
    
    #pragma mark 设置X轴
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.axisLineStyle             = nil;
    x.majorTickLineStyle        = nil;
    x.minorTickLineStyle        = nil;
    //x.minorTicksPerInterval    = 5;//设置x轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    x.majorIntervalLength       = @(1.0);//x轴主刻度：每多少单位显示一个刻度
    x.orthogonalPosition        = @(0.0);//设置x轴的原点位置
    x.title                     = @"X Axis";
    x.titleLocation             = @(2.5f);//x标题位于坐标多少处
    x.titleOffset               = 15.0;   //x标题从图表框中下移15.0的大小

    // Define some custom labels for the data elements
//    x.labelRotation  = CPTFloat(M_PI_4);//轴标签的旋转角度。当x.labelingPolicy = CPTAxisLabelingPolicyNone;时，在这里设置无效，需要在其他地方设置
    
#pragma mark 自定义轴label
    x.labelingPolicy = CPTAxisLabelingPolicyNone;//自定义轴label：当设置这个Policy之后，坐标轴label及背景线tick都需要自己绘制，否则显示为空，请不要过度惊慌
    NSArray *customTickLocations = @[@0.5, @1.5, @2.5, @3.5, @4.5];//这里弄成0.5是为了跟上面呼应
    NSArray *xAxisLabels         = @[NSLocalizedString(@"热量", nil),
                                     NSLocalizedString(@"蛋白质", nil),
                                     NSLocalizedString(@"脂质", nil),
                                     NSLocalizedString(@"碳水化合物", nil),
                                     NSLocalizedString(@"钠", nil)];
    
    
    NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
    for (int i = 0; i < customTickLocations.count; i++) {
        NSNumber *tickLocation = [customTickLocations objectAtIndex:i];
        NSString *labText = [xAxisLabels objectAtIndex:i];
        
        
        /*
        CPTMutableTextStyle的创建：（自定义标签时，如设置标签的字体大小，字体颜色等经常要用的）
        CPTMutableTextStyle *newlabelTextStyle = [x.labelTextStyle mutableCopy];//复制原本的
        newlabelTextStyle.color = [CPTColor redColor];
        newlabelTextStyle.fontSize = 10.0f;
        */
        
        
        //设置标签的字体颜色lichq
        CPTMutableTextStyle *newlabelTextStyle = [x.labelTextStyle mutableCopy];
        newlabelTextStyle.color = [CPTColor redColor];
        newlabelTextStyle.fontSize = 10.0f;
        
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:labText
                                                          textStyle:newlabelTextStyle];
        newLabel.tickLocation = tickLocation;
//        newLabel.offset       = x.labelOffset + x.majorTickLength;
        newLabel.offset       = x.labelOffset - 0;
//        newLabel.rotation     = CPTFloat(M_PI_4);
        [customLabels addObject:newLabel];
    }
    x.axisLabels = customLabels;
    
    #pragma mark 设置Y轴
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle         = nil;
    y.majorTickLineStyle    = nil;
    y.minorTickLineStyle    = nil;
    y.majorIntervalLength   = @(yMax/6);//50.0f设置成0的时候，则可以不显示y轴的轴标签
    y.orthogonalPosition    = @(0.0);
    y.title                 = @"Y Axis";
    y.titleOffset           = 45.0;
    y.titleLocation         = @(yMax/2);//150.0f
    

    //因为这里的柱状图没法设置背景柱状，所以我们通过绘制一张背景的柱状图来当背景。
    //如果我们还要要求前景的每个柱状能根据柱值的大小来设置不同的颜色，我们也是要将原本的一张前景柱状图分成每个柱子一张柱状图。
    #pragma mark 第一张BarChart
    /*
    CPTBarPlot的创建：
    使用CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor cyanColor]
                                                 horizontalBars:NO];能按缺省的设置创建图标。
    即：此时缺省的柱状图的柱子是外黑色线边，里自定义色到黑色的渐变填充效果。
    所以：当我们要做一个自己想要的柱子时，需要重新自定义柱子的外线边以及内填充色，其参数分别为:
    (CPTMutableLineStyle *)barPlot.lineStyle 和 (CPTFill *)barPlot.fill。
    
    附：
    1、CPTLineStyle(CPTMutableLineStyle)线条的创建(画线条时，经常要用的)
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    等价于:
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    barLineStyle.lineWidth = CPTFloat(1.0);
    barLineStyle.lineColor = [CPTColor clearColor];
    
    CPTColor的创建：
    方法①：
    CPTColor * blueColor  = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
    CPTColor * redColor   = [CPTColor colorWithComponentRed:1.0 green:0.3 blue:0.3 alpha:0.8];
    方法②：//利用系统颜色自制CPTColor
    CPTColor *greenColor = [CPTColor colorWithCGColor:[UIColor greenColor].CGColor];
    方法③：//直接使用系统CPTColor的color函数
    CPTColor *clearColor = [CPTColor clearColor];
    
    
    2、CPTGradient渐变色的创建
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor lightGrayColor]
                                                        endingColor:[CPTColor lightGrayColor]
                                                  beginningPosition:0.0
                                                     endingPosition:1.0];
     由于柱状图经常是竖直的，所以我们经常要将渐变色的立起来，即将gradient设置一个旋转角度angle。如：
     gradient.angle = -90.0f;//将渐变色旋转-90度（即逆时针方向旋转90度），使得BeginningColor在下面，endingColor在上面
     //渐变色的颜色分别为：
     0                 -> beginningPosition :BeginningColor到BeginningColor
     beginningPosition -> endingPosition    :BeginningColor到endingColor的渐变色
     endingPosition    -> 1                 :endingPosition到endingPosition
     即：只有beginningPosition -> endingPosition 这一段是渐变的，其他都是纯色的
     
    如果渐变区域是从0 -> 1的话，可以简写为如下：
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor lightGrayColor]
                                                        endingColor:[CPTColor lightGrayColor]];
    */
    
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor cyanColor]
                                               horizontalBars:NO];
    barPlot.baseValue  = @(0.0);// 柱子的起始基线：即最下沿的 y 坐标
    barPlot.dataSource = self;
    barPlot.barOffset  = @(-0.0f);//图形向左/右(正值向右)偏移：0.25(不偏移的话好像有错误)
    //    barPlot.barCornerRadius = 2.0;
    barPlot.identifier = @"Bar Plot BGBar";//id，根据此id来区分不同的plot，或者为不同plot提供不同数据源
    /*
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor lightGrayColor]
                                                        endingColor:[CPTColor lightGrayColor]];
    gradient.angle = -90.0f;
    CPTFill *fill = [CPTFill fillWithGradient:gradient];
    */
    CPTFill *fill = [CPTFill fillWithColor:self.colorForBarBG];//方法②
    barPlot.fill = fill;//如果不设置，则会使用默认的颜色到黑色的渐变色(注意点是areaFill，柱状图是fill)
    //barPlot.baseValue  = [[NSDecimalNumber numberWithFloat:0.0] decimalValue]; // 渐变色的起点位置 [[NSDecimalNumber zero] decimalValue];//注意点是areaBaseValue，柱状图是baseValue
    
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = CPTFloat(1.0);
    barLineStyle.lineColor = [CPTColor clearColor];
    barPlot.lineStyle = barLineStyle;//如果不设置，则会使用默认的黑色
    //barPlot.barWidth = [[NSDecimalNumber numberWithFloat:0.5] decimalValue];//设置柱状宽度
    //barPlot.barWidthScale = 0.5;
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];//添加图形到绘图空间
    
    
#pragma mark 第二张BarChart
    barPlot                = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor]
                                                  horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = @(0.0);
    barPlot.barOffset       = @(0.0f);
    barPlot.barCornerRadius = 2.0;
    
    barPlot.identifier      = @"Bar Plot 1";
    barPlot.fill = [CPTFill fillWithColor:self.colorForBar];
    barPlot.lineStyle = barLineStyle;
    
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];
}


- (CPTXYGraph *)initizileCPTXYGraph{
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    //设置背景
    //方法①：通过设置theme主题达到设置背景的目的
    //注意要先设置theme主题，否则设置的newGraph.plotAreaFrame.borderLineStyle将会无效
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    //CPTTheme *theme = [[QCPTTheme alloc]init];//自定义coreplot主题
    [newGraph applyTheme:theme];
    /*
    //方法②：直接设置背景
    newGraph.backgroundColor = [UIColor darkGrayColor].CGColor;//设置背景（必须在设置主题theme后，否则设置的内容将会被主题所覆盖掉而导致设置无效）
    newGraph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];//设置背景将会覆盖主题所设置的fill
    */
    
    //Paddings
    newGraph.paddingLeft   = 10.0;//默认的好像是20.0
    newGraph.paddingRight  = 10.0;
    newGraph.paddingTop    = 10.0;
    newGraph.paddingBottom = 10.0;
    
    //Border
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor redColor];
    newGraph.plotAreaFrame.borderLineStyle = lineStyle;//设置成nil的时候，就不会有边框
    newGraph.plotAreaFrame.cornerRadius    = 0.0;
    newGraph.plotAreaFrame.masksToBorder   = NO;
    
    
    //设置内边距：
    newGraph.plotAreaFrame.paddingLeft   = 70.0;
    newGraph.plotAreaFrame.paddingTop    = 20.0;
    newGraph.plotAreaFrame.paddingRight  = 20.0;
    newGraph.plotAreaFrame.paddingBottom = 30.0;
    
    
    return newGraph;
}

#pragma mark - Graph title
- (void)setUpGraphTitle:(CPTXYGraph *)newGraph{
    NSString *lineOne = @"Graph Title";
    NSString *lineTwo = @"已摄入营养素";
    
    BOOL hasAttributedStringAdditions = (&NSFontAttributeName != NULL) &&
    (&NSForegroundColorAttributeName != NULL) &&
    (&NSParagraphStyleAttributeName != NULL);
    
    if ( hasAttributedStringAdditions ) {
        NSMutableAttributedString *graphTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo]];
        
        [graphTitle addAttribute:NSForegroundColorAttributeName
                           value:[UIColor darkGrayColor]
                           range:NSMakeRange(0, lineOne.length)];
        
        [graphTitle addAttribute:NSForegroundColorAttributeName
                           value:[UIColor grayColor]
                           range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        
        NSMutableParagraphStyle *paragraphStyle =[[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment = CPTTextAlignmentCenter;
        [graphTitle addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:NSMakeRange(0, graphTitle.length)];
        
        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        [graphTitle addAttribute:NSFontAttributeName
                           value:titleFont
                           range:NSMakeRange(0, lineOne.length)];
        
        titleFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        [graphTitle addAttribute:NSFontAttributeName
                           value:titleFont
                           range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        
        newGraph.attributedTitle = graphTitle;
    }else {
        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
        titleStyle.color         = [CPTColor whiteColor];
        titleStyle.fontName      = @"Helvetica-Bold";
        titleStyle.fontSize      = 16.0;
        titleStyle.textAlignment = CPTTextAlignmentCenter;
        
        newGraph.title          = [NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo];
        newGraph.titleTextStyle = titleStyle;
    }
    newGraph.titleDisplacement        = CGPointMake(0.0, 10.0);//设置title显示的位置
    newGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;//设置靠哪边
}

/*
- (NSMutableSet *)bulidLabelTitleForX:(CPTXYAxis *)x{//自定义轴label
    x.labelingPolicy = CPTAxisLabelingPolicyNone;//自定义轴label：当设置这个Policy之后，坐标轴label及背景线tick都需要自己绘制，否则显示为空，请不要过度惊慌
    NSArray *customTickLocations = @[@1, @5, @10, @15];
    NSArray *xAxisLabels         = @[@"Label A", @"Label B", @"Label C", @"Label D"];
    
    CPTTextStyle *textStyle = x.labelTextStyle;
    //CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    //textStyle.color = [CPTColor colorWithComponentRed:CPTFloat((float)0x09/0xFF)green:CPTFloat((float)0x31/0xFF)blue:CPTFloat((float)0x4A/0xFF)alpha:CPTFloat(1.0)];
    
    NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
    for (int i = 0; i < customTickLocations.count; i++) {
        NSNumber *tickLocation = [customTickLocations objectAtIndex:i];
        NSString *labText = [xAxisLabels objectAtIndex:i];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:labText
                                                          textStyle:textStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset       = x.labelOffset + x.majorTickLength;//newLabel.offset=5;
        newLabel.rotation     = CPTFloat(M_PI_4);
        [customLabels addObject:newLabel];
    }
    
    return customLabels;
}
*/




#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot.identifier isEqual:@"Bar Plot BGBar"] ) {
        return self.dataForBarBG.count;
    }else if ( [plot.identifier isEqual:@"Bar Plot 1"] ) {
        return self.dataForBar.count;
    }else{
        return 0;
    }
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        
        NSDictionary *dic = nil;
        if ( [plot.identifier isEqual:@"Bar Plot BGBar"] ) {
            dic = [self.dataForBarBG objectAtIndex:index];
        }else if ( [plot.identifier isEqual:@"Bar Plot 1"] ) {
            dic = [self.dataForBar objectAtIndex:index];
        }
        
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation://x 轴坐标（柱子位置）：
                num = [dic valueForKey:@"x"];
                break;
                
            case CPTBarPlotFieldBarTip:     //y 轴坐标（柱子长度）：
                num = [dic valueForKey:@"y"];
                break;
        }
    }
    
    
    return num;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
