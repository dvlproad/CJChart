//
//  NutritionChartViewController.m
//  HealthyDiet
//
//  Created by lichq on 15-1-9.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "NutritionChartViewController.h"

#define Color(R,G,B,A)  [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A/255.0f]
#define Color_Green         Color(0x66, 0xcc, 0x00, 0xff)
#define Color_Yellow        Color(0xff, 0xcc, 0x33, 0xff)
#define Color_Red           Color(0xff, 0x00, 0x66, 0xff)

#define XLabelTextColor [CPTColor colorWithComponentRed:0.0 green:0.0 blue:0.0 alpha:1]//#000000

@interface NutritionChartViewController ()

@end

@implementation NutritionChartViewController
@synthesize barChart;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark Initialization and teardown

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getInfoL_NutritionChart];//这里不能执行界面更新。因为这里是获取信息，而一般获取信息是在非主线程中获取，如果界面的更新也写在这里的话，将会造成这个更新的执行虽然走到了，但其实还是要等到这个非主线程的线程结束任务后，他才会更新的，也就是说没有立即更新界面，而导致当等到这个线程关闭，主线程运行的时间太长的话，界面看起来好像出错一样。
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadUI_NutritionChart];
        });

    });
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.uid = @"1";
}



- (void)getInfoL_NutritionChart{
    ADNInfo *info_nutrition = [[ADNInfo alloc]init];
    
    info_nutrition.uid = @"20";
    info_nutrition.date = @"2015-03-28";
    
    info_nutrition.i2_sum = @"3000";
    info_nutrition.i4_sum = @"8";
    info_nutrition.i5_sum = @"20";
    info_nutrition.i6_sum = @"500";
    info_nutrition.i11_sum = @"16";
    
    info_nutrition.i2_need = @"2700";
    info_nutrition.i4_need = @"80";
    info_nutrition.i5_need = @"60";
    info_nutrition.i6_need = @"423.22";
    info_nutrition.i11_need = @"30";
    
    info_nutrition.i2_recommend = @"4800";
    info_nutrition.i4_recommend = @"120";
    info_nutrition.i5_recommend = @"75";
    info_nutrition.i6_recommend = @"461.03";
    info_nutrition.i11_recommend = @"45";
    
    [self setUpBarDataByDatas:info_nutrition];
}

- (void)setUpBarDataByDatas:(ADNInfo *)info{
    NSMutableArray *contentArrayBG = [[NSMutableArray alloc]init];
    for ( NSUInteger i = 0; i < 5; i++ ) {
        NSNumber *xVal = @(i + 0.5);//在这里加上0.5之后，下面的柱状图就可以不用偏移了
        NSNumber *yVal = @(1);
        [contentArrayBG addObject:@{ @"x": xVal, @"y": yVal }];
    }
    self.dataForBarBG = contentArrayBG;
    
    
    
    CGFloat i2_value = [self getValueByDividend:info.i2_sum andDivisor:info.i2_recommend];
    CGFloat i2_value_color = [self getValueByDividend:info.i2_sum andDivisor:info.i2_need];
    self.dataForBar = @[@{ @"x": @(0.5), @"y": @(i2_value)}];
    self.colorForBar = [self getCPTColorByValue:i2_value_color];
    
    CGFloat i4_value = [self getValueByDividend:info.i4_sum andDivisor:info.i4_recommend];
    CGFloat i4_value_color = [self getValueByDividend:info.i4_sum andDivisor:info.i4_need];
    self.dataForBar1 = @[@{ @"x": @(1.5), @"y": @(i4_value)}];
    self.colorForBar1 = [self getCPTColorByValue:i4_value_color];
    
    CGFloat i5_value = [self getValueByDividend:info.i5_sum andDivisor:info.i5_recommend];
    CGFloat i5_value_color = [self getValueByDividend:info.i5_sum andDivisor:info.i5_need];
    self.dataForBar2 = @[@{ @"x": @(2.5), @"y": @(i5_value)}];
    self.colorForBar2 = [self getCPTColorByValue:i5_value_color];
    
    CGFloat i6_value = [self getValueByDividend:info.i6_sum andDivisor:info.i6_recommend];
    CGFloat i6_value_color = [self getValueByDividend:info.i6_sum andDivisor:info.i6_need];
    self.dataForBar3 = @[@{ @"x": @(3.5), @"y": @(i6_value)}];
    self.colorForBar3 = [self getCPTColorByValue:i6_value_color];
    
    CGFloat i11_value = [self getValueByDividend:info.i11_sum andDivisor:info.i11_recommend];
    CGFloat i11_value_color = [self getValueByDividend:info.i11_sum andDivisor:info.i11_need];
    self.dataForBar4 = @[@{ @"x": @(4.5), @"y": @(i11_value)}];
    self.colorForBar4 = [self getCPTColorByValue:i11_value_color];
    
    //NSLog(@"i_value_color:%.3f, %.3f, %.3f, %.3f, %.3f", i2_value_color, i4_value_color, i5_value_color, i6_value_color, i11_value_color);
    

    NSString *value1 = [self getVStringFromVNumber:@(i2_value_color)];
    NSString *value2 = [self getVStringFromVNumber:@(i4_value_color)];
    NSString *value3 = [self getVStringFromVNumber:@(i5_value_color)];
    NSString *value4 = [self getVStringFromVNumber:@(i6_value_color)];
    NSString *value5 = [self getVStringFromVNumber:@(i11_value_color)];
    
    NSArray *xAxisLabels         = @[@{@"x"    : @0.5,
                                       @"title": NSLocalizedString(@"热量", nil),
                                       @"value": value1} ,
                                     @{@"x"    : @1.5,
                                       @"title": NSLocalizedString(@"蛋白质", nil),
                                       @"value": value2} ,
                                     @{@"x"    : @2.5,
                                       @"title": NSLocalizedString(@"脂质", nil),
                                       @"value": value3} ,
                                     @{@"x"    : @3.5,
                                       @"title": NSLocalizedString(@"碳水化物", nil),
                                       @"value": value4} ,
                                     @{@"x"    : @4.5,
                                       @"title": NSLocalizedString(@"膳食纤维", nil),
                                       @"value": value5}];
    self.dataForXLable = [NSMutableArray arrayWithArray:xAxisLabels];
}


- (CGFloat)getValueByDividend:(NSString *)dividend andDivisor:(NSString *)divisor{
    CGFloat value = 0;
    if ([divisor floatValue] != 0) {
        value = [dividend floatValue]/[divisor floatValue];
    }
    return value;
}

- (CPTColor *)getCPTColorByValue:(CGFloat)value{
    if (value >= 1.0f) {
        
        return  [CPTColor colorWithCGColor:Color_Green.CGColor];//[[CPTColor greenColor];
    }else{
        if (value >= 0.2f) {
            return [CPTColor colorWithCGColor:Color_Yellow.CGColor];//[CPTColor yellowColor];
        }else{
            return [CPTColor colorWithCGColor:Color_Red.CGColor];//[CPTColor redColor];
        }
    }
}

- (void)reloadUI_NutritionChart{
    //[self.graphHostingView.hostedGraph reloadData];
    [self createChart]; //注意createChart也是UI的操作，而不是数据操作
}


- (void)setupPaddingAndBorderAndBackgroundForGraph:(CPTXYGraph *)newGraph{
    //Paddings
    newGraph.paddingLeft   = 10.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingTop    = 40.0;
    newGraph.paddingBottom = 36.0;
    
    
    //设置内边距：
    newGraph.plotAreaFrame.paddingLeft   = 0.0;
    newGraph.plotAreaFrame.paddingTop    = 0.0;
    newGraph.plotAreaFrame.paddingRight  = 0.0;
    newGraph.plotAreaFrame.paddingBottom = 36.0;
    
    
    /*
    //Border
    newGraph.borderWidth = 1.0;
    newGraph.borderColor = [UIColor redColor].CGColor;

    newGraph.plotAreaFrame.borderWidth = 2.0;
    newGraph.plotAreaFrame.borderColor = [UIColor blueColor].CGColor;
    newGraph.plotAreaFrame.borderLineStyle = nil;
    newGraph.plotAreaFrame.cornerRadius    = 0.0;
    newGraph.plotAreaFrame.masksToBorder   = NO;
    
    //Background
    newGraph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
    newGraph.plotAreaFrame.backgroundColor = [UIColor cyanColor].CGColor;//设置plotAreaFrame的backgroundColor后，之前设置的plotAreaFrame的fill将自动无效。
    
    self.graphHostingView.backgroundColor = [UIColor redColor];
    newGraph.backgroundColor = [UIColor yellowColor].CGColor;//设置self.graphHostingView.hostedGraph的backgroundColor后，之前设置的self.graphHostingView的backgroundColor将自动无效。
    */
}

#pragma mark - 设置画布标题GraphTitle（可设多行）
- (void)setTitleForGraph:(CPTXYGraph *)newGraph{
    // Graph title
    NSString *lineOne = NSLocalizedString(@"已摄入营养素", nil);
    NSString *lineTwo = @"";
    
    BOOL hasAttributedStringAdditions = (&NSFontAttributeName != NULL) &&
    (&NSForegroundColorAttributeName != NULL) &&
    (&NSParagraphStyleAttributeName != NULL);
    
    if ( hasAttributedStringAdditions ) {
        NSMutableAttributedString *graphTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo]];
        
        [graphTitle addAttribute:NSForegroundColorAttributeName
                           value:[UIColor redColor]
                           range:NSMakeRange(0, lineOne.length)];
        
        [graphTitle addAttribute:NSForegroundColorAttributeName
                           value:[UIColor lightGrayColor]
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
    newGraph.titleDisplacement        = CGPointMake(0.0, 0.0);
    newGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTopLeft;
}

- (void)createChart{
#pragma mark - 初始化数据
    // Create barChart from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    self.barChart = newGraph;
    self.graphHostingView.hostedGraph = newGraph;
    
    
    [self setupPaddingAndBorderAndBackgroundForGraph:newGraph];
    //[self setTitleForGraph:newGraph];

    
#pragma mark 设置课件范围X轴:0-16; Y轴0-300
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(0.0)
                                                    length:@(self.dataForBarBG.count)];
    CGFloat yMax = [[[self.dataForBarBG objectAtIndex:0] valueForKey:@"y"] floatValue];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(0.0)
                                                    length:@(yMax)];
    
#pragma mark 设置X轴
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.axisLineStyle               = nil;
    x.majorTickLineStyle          = nil;
    x.minorTickLineStyle          = nil;
    //x.minorTicksPerInterval       = 5;
    x.majorIntervalLength         = @(1.0);
    x.orthogonalPosition = @(0.0);
    
#pragma mark 自定义轴label
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    /*
    NSArray *customTickLocations = @[@0.5, @1.5, @2.5, @3.5, @4.5];
    
    NSArray *xAxisLabels         = @[NSLocalizedString(@"热量", nil),
                                     NSLocalizedString(@"蛋白质", nil),
                                     NSLocalizedString(@"脂质", nil),
                                     NSLocalizedString(@"碳水化物", nil),
                                     NSLocalizedString(@"钠", nil)];
    
    NSNumber *nvalue1 = [[self.dataForBar firstObject] valueForKey:@"y"];
    NSNumber *nvalue2 = [[self.dataForBar1 firstObject] valueForKey:@"y"];
    NSNumber *nvalue3 = [[self.dataForBar2 firstObject] valueForKey:@"y"];
    NSNumber *nvalue4 = [[self.dataForBar3 firstObject] valueForKey:@"y"];
    NSNumber *nvalue5 = [[self.dataForBar4 firstObject] valueForKey:@"y"];
    
    NSString *value1 = [self getVStringFromVNumber:nvalue1];
    NSString *value2 = [self getVStringFromVNumber:nvalue2];
    NSString *value3 = [self getVStringFromVNumber:nvalue3];
    NSString *value4 = [self getVStringFromVNumber:nvalue4];
    NSString *value5 = [self getVStringFromVNumber:nvalue5];
    
    NSArray *xAxisLabels         = @[@{@"title": NSLocalizedString(@"热量", nil),
                                       @"value": value1} ,
                                     @{@"title": NSLocalizedString(@"蛋白质", nil),
                                       @"value": value2} ,
                                     @{@"title": NSLocalizedString(@"脂质", nil),
                                       @"value": value3} ,
                                     @{@"title": NSLocalizedString(@"碳水化物", nil),
                                       @"value": value4} ,
                                     @{@"title": NSLocalizedString(@"钠", nil),
                                       @"value": value5}];
    
    NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
    for (int i = 0; i < customTickLocations.count; i++) {
        NSNumber *tickLocation = [customTickLocations objectAtIndex:i];
        NSString *labText = [xAxisLabels objectAtIndex:i];
    */
    NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[self.dataForXLable count]];
    for (int i = 0; i < self.dataForXLable.count; i++) {
        NSNumber *tickLocation = [[self.dataForXLable objectAtIndex:i] valueForKey:@"x"];
        NSString *labText = [[self.dataForXLable objectAtIndex:i] valueForKey:@"title"];
        NSString *labValue = [[self.dataForXLable objectAtIndex:i] valueForKey:@"value"];
        
        CPTMutableTextStyle *newlabelTextStyle = [x.labelTextStyle mutableCopy];
        newlabelTextStyle.color = XLabelTextColor;
        newlabelTextStyle.fontSize = 12.0f;
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:labText
                                                          textStyle:newlabelTextStyle];
        newLabel.tickLocation = tickLocation;
//        newLabel.offset       = x.labelOffset + x.majorTickLength;
        newLabel.offset       = x.labelOffset + 17;
//        newLabel.rotation     = CPTFloat(M_PI_4);
        [customLabels addObject:newLabel];
        
        
        CPTAxisLabel *newLabelValue = [[CPTAxisLabel alloc] initWithText:labValue
                                                          textStyle:newlabelTextStyle];
        //newLabelValue.tickLocation = [tickLocation decimalValue];
        double dValue = tickLocation.doubleValue + 0.01; //为了不让它覆盖掉之前的lable，所以加0.1，而不是整数
        NSDecimalNumber *result = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:dValue];
        newLabelValue.tickLocation = result;
        
        //        newLabelValue.offset       = x.labelOffset + x.majorTickLength;
        newLabelValue.offset       = x.labelOffset + 2;
        //        newLabelValue.rotation     = CPTFloat(M_PI_4);
        [customLabels addObject:newLabelValue];
    }
    x.axisLabels = customLabels;
    
#pragma mark 设置Y轴
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle               = nil;
    y.majorTickLineStyle          = nil;
    y.minorTickLineStyle          = nil;
    y.axisLabels = nil;
    y.majorIntervalLength         = @(0.0);
    y.orthogonalPosition = @(0.0);
    
    
    //CGFloat barWidthScale = 0.7;
//    NSDecimal barWidth = [[NSDecimalNumber decimalNumberWithString:@"0.5"] decimalValue];
//    NSDecimal barWidth = [[NSDecimalNumber numberWithFloat:0.5] decimalValue];
    NSNumber *barWidth = @(0.417f);// bar is full (50%) width
    CGFloat barCornerRadius = 7.0;
#pragma mark 背景BarChart
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor lightGrayColor]
                                               horizontalBars:NO];
    barPlot.baseValue  = @(0.0);
    barPlot.dataSource = self;
    barPlot.barOffset  = @(0.0f);
    barPlot.barCornerRadius = barCornerRadius;
    barPlot.barBaseCornerRadius = barCornerRadius;
    barPlot.identifier = @"Bar Plot BGBar";
    

    //CPTColor *lightGrayColor = [CPTColor colorWithCGColor:[UIColor lightGrayColor].CGColor];
    CPTColor *barColor = [CPTColor colorWithComponentRed:0xe6/255.0 green:0xe6/255.0 blue:0xe6/255.0 alpha:1.0];
    CPTGradient * areaGradient = [CPTGradient gradientWithBeginningColor:barColor
                                                              endingColor:barColor];
    CPTFill * fill = [CPTFill fillWithGradient:areaGradient];
    barPlot.fill = fill;
    
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = CPTFloat(1.0);
    barLineStyle.lineColor = [CPTColor clearColor];
    barPlot.lineStyle = barLineStyle;
//    barPlot.baseValue  = [[NSDecimalNumber numberWithFloat:0.0] decimalValue];
//    barPlot.barWidthScale = barWidthScale;
    barPlot.barWidth = barWidth;
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];//添加图形到绘图空间
    
    
#pragma mark 第一张BarChart
    barPlot                = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor]
                                                  horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = @(0.0);
    barPlot.barOffset       = @(0.0f);
    barPlot.barCornerRadius = barCornerRadius;
    barPlot.barBaseCornerRadius = barCornerRadius;
    
    barPlot.identifier      = @"Bar Plot 1";
    barPlot.fill = [CPTFill fillWithColor:self.colorForBar];
    barPlot.lineStyle = barLineStyle;
//    barPlot.barWidthScale = barWidthScale;
    barPlot.barWidth = barWidth;
    
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];
    
#pragma mark 第二张BarChart
    barPlot                = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor]
                                                  horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = @(0.0);
    barPlot.barOffset       = @(0.0f);
    barPlot.barCornerRadius = barCornerRadius;
    barPlot.barBaseCornerRadius = barCornerRadius;
    barPlot.identifier      = @"Bar Plot 2";
    barPlot.fill = [CPTFill fillWithColor:self.colorForBar1];
    barPlot.lineStyle = barLineStyle;
//    barPlot.barWidthScale = barWidthScale;
    barPlot.barWidth = barWidth;
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];
    
#pragma mark 第三张BarChart
    barPlot                = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor]
                                                  horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = @(0.0);
    barPlot.barOffset       = @(0.0f);
    barPlot.barCornerRadius = barCornerRadius;
    barPlot.barBaseCornerRadius = barCornerRadius;
    barPlot.identifier      = @"Bar Plot 3";
    barPlot.fill = [CPTFill fillWithColor:self.colorForBar2];
    barPlot.lineStyle = barLineStyle;
//    barPlot.barWidthScale = barWidthScale;
    barPlot.barWidth = barWidth;
    barPlot.lineStyle = barLineStyle;
    
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];
    
#pragma mark 第四张BarChart
    barPlot                = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor]
                                                  horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = @(0.0);
    barPlot.barOffset       = @(0.0f);
    barPlot.barCornerRadius = barCornerRadius;
    barPlot.barBaseCornerRadius = barCornerRadius;
    barPlot.identifier      = @"Bar Plot 4";
    barPlot.fill = [CPTFill fillWithColor:self.colorForBar3];
    barPlot.lineStyle = barLineStyle;
//    barPlot.barWidthScale = barWidthScale;
    barPlot.barWidth = barWidth;
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];
    
#pragma mark 第五张BarChart
    barPlot                = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor]
                                                  horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = @(0.0);
    barPlot.barOffset       = @(0.0f);
    barPlot.barCornerRadius = barCornerRadius;
    barPlot.barBaseCornerRadius = barCornerRadius;
    barPlot.identifier      = @"Bar Plot 5";
    barPlot.fill = [CPTFill fillWithColor:self.colorForBar4];
    barPlot.lineStyle = barLineStyle;
//    barPlot.barWidthScale = barWidthScale;
    barPlot.barWidth = barWidth;
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];
}


- (NSString *)getVStringFromVNumber:(NSNumber *)nvalue{
    if ([nvalue floatValue] > 1.0) {
        return @"√";
    }
    
    NSString *value = [NSString stringWithFormat:@"%.1f%%", [nvalue floatValue] * 100];
    return value;
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
// */


#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot.identifier isEqual:@"Bar Plot BGBar"] ) {
        return self.dataForBarBG.count;
    }else if ( [plot.identifier isEqual:@"Bar Plot 1"] ) {
        return self.dataForBar.count;
    }else if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
        return self.dataForBar1.count;
    }else if ( [plot.identifier isEqual:@"Bar Plot 3"] ) {
        return self.dataForBar2.count;
    }else if ( [plot.identifier isEqual:@"Bar Plot 4"] ) {
        return self.dataForBar3.count;
    }else if ( [plot.identifier isEqual:@"Bar Plot 5"] ) {
        return self.dataForBar4.count;
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
        }else if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
            dic = [self.dataForBar1 objectAtIndex:index];
        }else if ( [plot.identifier isEqual:@"Bar Plot 3"] ) {
            dic = [self.dataForBar2 objectAtIndex:index];
        }else if ( [plot.identifier isEqual:@"Bar Plot 4"] ) {
            dic = [self.dataForBar3 objectAtIndex:index];
        }else if ( [plot.identifier isEqual:@"Bar Plot 5"] ) {
            dic = [self.dataForBar4 objectAtIndex:index];
        }
        
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation://x 轴坐标（柱子位置）：
                num = [dic valueForKey:@"x"];
                break;
                
            case CPTBarPlotFieldBarTip:     //y 轴坐标（柱子长度）：
                num = [dic valueForKey:@"y"];
                if ([num floatValue] > 1) { //超过1的时候，本来设置好的柱状图弧度会变成无效了。
                    num = @(1);
                }
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
