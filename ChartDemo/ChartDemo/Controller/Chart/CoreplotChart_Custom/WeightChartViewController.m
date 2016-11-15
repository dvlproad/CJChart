//
//  WeightChartViewController.m
//  HealthyDiet
//
//  Created by lichq on 15-1-6.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "WeightChartViewController.h"


#import "QCPTTheme.h"
#import "NSString+Category.h"

static CPTTextStyle *yPositiveStyle = nil;
static CPTTextStyle *yNegativeStyle = nil;
static dispatch_once_t yPositiveOnce;
static dispatch_once_t yNegativeOnce;


//边框属性
//绘图区plotArea的边框属性
#define border_Width_plotArea   0.0
#define border_Color_plotArea   [UIColor blackColor].CGColor


//坐标轴与边界距离(待完善)
#define offset_axisConstraints_X    -60 //这里是固定x坐标轴在最下边（距离可视下边界有多少个像素距离）
#define offset_axisConstraints_Y    -80 //这里是固定y坐标轴在最右边（距离可视右边界有多少个像素距离）（未设置的时候，值是null）


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


//x轴显示个数
static NSInteger kXShowCountMin = 7;       //x轴上最少显示多少个单位,即放大到最大也得至少显示的个数，而更多的单位可通过移动或缩放来查看
static NSInteger kXShowCountDefault = 10;  //x轴上初始默认显示多少个单位（不应该比kXShowCountMin小）

//网格线设置
//开头结尾多添加几条网格线
#define UnitCount_Placeholder_Last 2 //默认所有点显示完后，最后还要有多少个单位占位，即需要在原来的所有点上额外加上多少个空点，用来占位，占最后几位 //并且这里不娶2.0整数，是为了在绘制网格线的时候，不让最后一个点成为主/副刻度，从而出现网格线
#define UnitCount_Placeholder_Begin 2
//去掉最开头、最结尾的网格线，其实是显示不到而已
#define globalXRange_NoShowAtBeginAndLast   0.1
#define globalYRange_NoShowAtBeginAndLast   0.1

static CGFloat standValue_Y = 55.0;

#define Text_Color_isGreaterThanOrEqualTo_Y [CPTColor blackColor]   //y轴轴标签值大于指定值时候的文字颜色
#define Text_Color_isLessThan_Y             [CPTColor blackColor]     //y轴轴标签值小于指定值时候的文字颜色

#define Text_Color_Default_X                [CPTColor blackColor]     //x轴轴标签默认的文字牙呢


//画布标题设置：GraphTitle
#define GraphTitle_titleDisplacement  CGPointMake(0.0, 3.0) //画布标题在设置的区域上的什么点展示
#define GraphTitle_color    [UIColor blackColor] //画布标题颜色
#define GraphTitle_fontSize 14.0    //画布标题文字大小
        
@interface WeightChartViewController () {
    
}

//通过绝对位置固定坐标轴时，由于是使用绝对位置，所以当视图移动的时候，坐标轴也会随着绝对位置在视图上的移动而移动
@property (nonatomic, assign) BOOL fixedXAxisByAbsolutePosition;   /**< 通过绝对位置固定X轴 */
@property (nonatomic, assign) BOOL fixedYAxisByAbsolutePosition;   /**< 通过绝对位置固定Y轴 */
@property (nonatomic, assign) BOOL customXAxis; /**< 自定义X轴 */
@property (nonatomic, assign) BOOL customYAxis; /**< 自定义Y轴 */

@property (nonatomic, assign) NSInteger xShowCountDefault;  /**< 初始时候，默认显示的个数（之后随着缩放操作xShowCount会随时变化） */

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
        ADWInfo *info = [[ADWInfo alloc]init];
        info.uid = [[dic valueForKey:kADWKeyUID] intValue];
        info.date = [dic valueForKey:kADWKeyDate];
        info.wid = [dic valueForKey:kADWKeyWID];
        info.weight = [dic valueForKey:kADWKeyWeight];
        info.modified = [dic valueForKey:kADWKeyModified];
        
//        [tempData addObject:info];
        [QSqliteUtilADW insertInfo:info];
    }
#endif
    
    
    ADWInfo *info = [[ADWInfo alloc]init];
    info.uid = self.uid;
    info.date = @"2016-08-29";
    info.wid = @"10001";
    info.weight = @"72";
    info.modified = @"1013513515";
    [ADWFMDBUtil insertInfo:info];
    
    ADWInfo *info2 = [[ADWInfo alloc]init];
    info2.uid = self.uid;
    info2.date = @"2016-09-04";
    info2.wid = @"10002";
    info2.weight = @"70";
    info2.modified = @"1013513516";
    [ADWFMDBUtil insertInfo:info2];
    
    ADWInfo *info3 = [[ADWInfo alloc]init];
    info3.uid = self.uid;
    info3.date = @"2016-09-09";
    info3.wid = @"10003";
    info3.weight = @"65";
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

- (void)setXShowCountDefault:(NSInteger)xShowCountDefault {
    if (xShowCountDefault < kXShowCountMin) {
        NSLog(@"设置的显示个数%zd太小，故自动设置使用默认个数%zd", xShowCountDefault, kXShowCountMin);
        _xShowCountDefault = kXShowCountMin;
    } else {
        _xShowCountDefault = xShowCountDefault;
    }
}

//TODO: 同时自动生成set和get方法
//- (NSInteger)xShowCountDefault {
//    if (self.xShowCountDefault == 0) {
//        return kXShowCountMin;
//    }
//    return self.xShowCountDefault;
//}

/** 更新体重的UI */
- (void)reloadUIForWeight {
    /* 1、获取数据的开头日期和结尾日期 */
    NSDate *dateBegin = [NSDate date];
    NSDate *dateEnd = [NSDate date];
    if ([self.datas count] != 0) {
        ADWInfo *info = [self.datas objectAtIndex:0];
        dateBegin = [info.date standDate];
    }
    
    /* 2、获取坐标轴上显示的开头日期和结尾日期 */
    //①、判断：如果现有坐标刻度(X轴坐标)小于最小应有值，这里应默认将其扩大，以使得不会产生一个坐标里面只有一个刻度的效果
    NSInteger dayDistance = [dateEnd dayDistanceFromDate:dateBegin];
    NSLog(@"天数差为%ld", dayDistance);
    if (dayDistance < kXShowCountMin) {
        dateBegin = [dateEnd dateDistances:-kXShowCountMin+1 type:eDistanceDay];
    }
    
    //②、增加：开始日期提前一点，结束日期延后一点，以使得能保证所有的数据都不会显示在边界上，而造成不好的效果
    NSDate *showDateBegin = [dateBegin dateDistances:-UnitCount_Placeholder_Begin type:eDistanceDay];
    NSDate *showDateEnd = [dateEnd dateDistances:UnitCount_Placeholder_Last type:eDistanceDay];

    
    self.xShowCountDefault = kXShowCountDefault;
    NSLog(@"最终X轴的显示个数为%ld", self.xShowCountDefault);
    
    [self reloadUIByShowDateBegin:showDateBegin showDateEnd:showDateEnd];
}

- (void)reloadUIByShowDateBegin:(NSDate *)showDateBegin showDateEnd:(NSDate *)showDateEnd {
    //获取两个坐标轴各自的最大值、最小值，以使得能确定坐标轴的范围，
    //横轴上通过日期数据(开始日期以及结束日期)，来获取该坐标轴的最大值、最小值，以使得之后能确定坐标轴的范围。
    //纵轴上通过用户体重值数据，来获取该坐标轴的最大值、最小值，以使得之后能确定坐标轴的范围。
    //同时横轴上将日期数据Y转为XY数据，以作之后轴标签数据、纵轴上用户体重数据（也是日期Y）也改为XY形式的数据，以作之后坐标系上的店的数据
    [self getXDataByShowDateBegin:showDateBegin showDateEnd:showDateEnd];
    [self getYDataAndPlotDataFromData:self.datas byShowDateBegin:showDateBegin];
    
    
    self.fixedXAxisByAbsolutePosition = YES;
    self.fixedYAxisByAbsolutePosition = YES;
    self.customXAxis = YES;
    self.customYAxis = YES;
    [self createCPTXYGraph];
    //    [self.graphHostingView.hostedGraph reloadData];//刷新画板
}

- (void)getXDataByShowDateBegin:(NSDate *)dateBegin showDateEnd:(NSDate *)dateEnd{
    self.chatDataModel = [[CJChartData alloc] init];
    self.chatDataModel.xDatas = [dateEnd findAllDateFromDate:dateBegin];
    self.chatDataModel.xMin = 0;
    self.chatDataModel.xMax = [self.chatDataModel.xDatas count] - 1;//注意这里记得减去1否则个数不正确，因为这里是从0开始算
}

//取出dataModels中每个dataModel的日期，结合自己设定的初始日期设置X；取出其值，设置为Y
- (void)getYDataAndPlotDataFromData:(NSArray *)datas byShowDateBegin:(NSDate *)showDateBegin {
    NSMutableArray *dataForPlot = [[NSMutableArray alloc]init];
    
    if (datas.count == 0) {
        self.chatDataModel.yPlotDatas = dataForPlot;
        self.chatDataModel.yMin = standValue_Y - 5;
        self.chatDataModel.yMax = standValue_Y + 6;
        
    }else{
        ADWInfo *tmpInfo = datas[0];
        CGFloat yMinValue = [tmpInfo.weight floatValue];
        CGFloat yMaxValue = [tmpInfo.weight floatValue];
        for (ADWInfo *info in datas) {
            NSDate *date = [info.date standDate];
            NSInteger xValue = [date dayDistanceFromDate:showDateBegin];
            CGFloat yValue = [info.weight floatValue];
            
            CJChartPlotData *chartPlotData = [[CJChartPlotData alloc] init];
            chartPlotData.x = xValue;
            chartPlotData.y = yValue;
            
            yMinValue = yValue < yMinValue ? yValue : yMinValue;
            yMaxValue = yValue > yMaxValue ? yValue : yMaxValue;
            
            [dataForPlot addObject:chartPlotData];
        }
        
        self.chatDataModel.yPlotDatas = dataForPlot;
        self.chatDataModel.yMin = floorf(yMinValue/5) * 5 - 5;   //floorf 向下取整
        self.chatDataModel.yMax = floorf(yMaxValue/5) * 5 + 6;
    }
}


- (void)createCPTXYGraph {
#pragma mark 创建基于XY轴图CPTXYGraph，并对XY轴图进行设置
#pragma mark ———————-———————1.添加主题，标题，设置与屏幕边缘之间的空隙
    CPTXYGraph *xyGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    [self setThemeToXYGraph:xyGraph];
    [self setTitleForXYGraph:xyGraph];           //画布Graph的标题title
    [self setupPaddingAndBorderAndBackgroundForGraph:xyGraph];//画布Graph的内边距padding、边框border
    
    
    self.lineGraph = xyGraph;
    self.graphHostingView.hostedGraph     = xyGraph;
    self.graphHostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    self.graphHostingView.allowPinchScaling = YES;
    
    
    
#pragma mark ———————-———————2.设置可视空间CPTXYPlotSpace
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *)xyGraph.defaultPlotSpace;
    [self setCommonSettingXYPlotSpace:xyPlotSpace];
    [self setXYRangeAndXYGlobalRangeForXYPlotSpace:xyPlotSpace];
    [xyPlotSpace setDelegate:self];//用来设置缩放操作.注意：这里需要等到设置完plotSpace的xyRange和globalXYRange之后，才能设置setDelegate。否则会出现坐标轴为空的原因是否是delegate方法中有部分数据需要这里的range呢？
    
#pragma mark ———————-———————3.设置两个轴 CPTXYAxis
    // Axes设置x,y轴属性，如原点，量度间隔，标签，刻度，颜色等
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)xyGraph.axisSet;//获取XYGraph的轴的集合,其中包括xAxis和yAxis
    CPTXYAxis *xAxis = xyAxisSet.xAxis;
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    [self setupCoordinateXAxis:xAxis];
    [self setupCoordinateYAxis:yAxis];
    
    [self setTitleForXAxis:xAxis byCurrentXRange:xyPlotSpace.xRange];
    [self setTitleForYAxis:yAxis];
    
    if (self.customXAxis) {
        xAxis.delegate             = self;//需要实现CPTAxisDelegate协议,以此来定制主刻度显示标签
    }
    if (self.customYAxis) {
        yAxis.delegate             = self;//需要实现CPTAxisDelegate协议,以此来定制主刻度显示标签
    }
    
#pragma mark 添加曲线图CPTScatterPlot
    [self addScatterPlotForGraph:xyGraph];
}

/** 添加画布Graph的主题Theme */
- (void)setThemeToXYGraph:(CPTXYGraph *)xyGraph {
    //CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    CPTTheme *theme = [[QCPTTheme alloc]init];  //自定义coreplot主题
    [xyGraph applyTheme:theme];                //Graph theme
}

/** 设置画布Graph的内边距padding、边框border */
- (void)setupPaddingAndBorderAndBackgroundForGraph:(CPTXYGraph *)xyGraph{
    xyGraph.paddingLeft   = 10.0;
    xyGraph.paddingTop    = 10.0;
    xyGraph.paddingRight  = 10.0;
    xyGraph.paddingBottom = 10.0;
    
    xyGraph.plotAreaFrame.paddingTop = 20.0;
    xyGraph.plotAreaFrame.paddingRight = 20.0;
    xyGraph.plotAreaFrame.paddingLeft = 50.0 ;
    xyGraph.plotAreaFrame.paddingBottom = 40.0 ;
    
    /*
     xyGraph.borderWidth = 1.0;
     xyGraph.borderColor = [UIColor redColor].CGColor;
     
     xyGraph.plotAreaFrame.borderWidth = 2.0;
     xyGraph.plotAreaFrame.borderColor = [UIColor greenColor].CGColor;
     */
}

/** 设置画布Graph的标题GraphTitle（可设多行） */
- (void)setTitleForXYGraph:(CPTXYGraph *)xyGraph {
    NSString *lineOne = NSLocalizedString(@"体重趋势图", nil);
    NSString *lineTwo = @"";
    
    BOOL hasAttributedStringAdditions = (&NSFontAttributeName != NULL) &&
    (&NSForegroundColorAttributeName != NULL) &&
    (&NSParagraphStyleAttributeName != NULL);
    
    if ( hasAttributedStringAdditions ) {
        NSMutableAttributedString *graphTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo]];
        
        [graphTitle addAttribute:NSForegroundColorAttributeName
                           value:GraphTitle_color
                           range:NSMakeRange(0, lineOne.length)];
        
        [graphTitle addAttribute:NSForegroundColorAttributeName
                           value:[UIColor lightGrayColor]
                           range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        
        NSMutableParagraphStyle *paragraphStyle =[[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment = CPTTextAlignmentCenter;
        [graphTitle addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:NSMakeRange(0, graphTitle.length)];
        
        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:GraphTitle_fontSize];
        [graphTitle addAttribute:NSFontAttributeName
                           value:titleFont
                           range:NSMakeRange(0, lineOne.length)];
        
        titleFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        [graphTitle addAttribute:NSFontAttributeName
                           value:titleFont
                           range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        
        xyGraph.attributedTitle = graphTitle;
    }else {
        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
        titleStyle.color         = [CPTColor whiteColor];
        titleStyle.fontName      = @"Helvetica-Bold";
        titleStyle.fontSize      = GraphTitle_fontSize;
        titleStyle.textAlignment = CPTTextAlignmentCenter;
        
        xyGraph.title          = [NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo];
        xyGraph.titleTextStyle = titleStyle;
    }
    xyGraph.titleDisplacement        = GraphTitle_titleDisplacement;
    xyGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTopLeft;
}

- (void)setCommonSettingXYPlotSpace:(CPTXYPlotSpace *)xyPlotSpace {
    //设置移动时的停止动画这些参数（保持默认即可变化不大）
    xyPlotSpace.momentumAnimationCurve = CPTAnimationCurveCubicIn;
    xyPlotSpace.bounceAnimationCurve = CPTAnimationCurveBackIn;
    xyPlotSpace.momentumAcceleration = 20000.0;
    [xyPlotSpace setAllowsMomentumX:YES];
}

/** 设置显示和移动范围 */
- (void)setXYRangeAndXYGlobalRangeForXYPlotSpace:(CPTXYPlotSpace *)xyPlotSpace {
    //①、设置轴的显示范围
    if (self.xShowCountDefault == 0) {
        self.xShowCountDefault = kXShowCountMin;
        NSLog(@"请提前设置self.xShowCountDefault");
    }
    CGFloat showXMin = self.chatDataModel.xMax-self.xShowCountDefault;//只显示最近的几天 所以min是 self.xMax-UnitCount_X_Default 天
    CGFloat showXMax = self.chatDataModel.xMax;
    
    CGFloat showYMin = self.chatDataModel.yMin;
    CGFloat showYMax = self.chatDataModel.yMax-0.1;
    
    xyPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(showXMin) length:@(showXMax - showXMin)];
    xyPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(showYMin) length:@(showYMax - showYMin)];
    
    
    //②、设置轴的滑动范围。（能实现1、去掉最开头、最结尾的网格线（其实是显示不到而已），所以这里的最大值与最小值都有一个0.1的处理；2、坐标只按照X轴横向滑动，其实只是让Y轴最大滑动范围与Y轴的量度范围(初始显示区域)一样，以使得Y轴不能滑动而已）
    CGFloat globalXMin = self.chatDataModel.xMin + 0.1;
    CGFloat globalXMax = self.chatDataModel.xMax - 0.1;
    xyPlotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:@(globalXMin) length:@(globalXMax - globalXMin)];
    xyPlotSpace.globalYRange = xyPlotSpace.yRange;
    
    
    xyPlotSpace.allowsUserInteraction = YES;  //是否允许拖动
    //    [self.graphHostingView setAllowPinchScaling:NO];//禁止缩放：（两指捏扩动作,默认允许）
    
    //TODO
    self.globalXRange = xyPlotSpace.globalXRange;
    self.currentXRange = xyPlotSpace.xRange;
    self.globalYRange = xyPlotSpace.yRange;
}

/*
 - (CPTPlotRange *)getPlotRangeWithMin:(CGFloat)min max:(CGFloat)max {
 return [CPTPlotRange plotRangeWithLocation:@(min) length:@(max - min)];
 }
 */

/** 根据当前x轴范围，设置标题及其位置（位置的计算是用来“实现固定轴标题”的目的的，轴标题的固定是需要考虑缩放等的变化的） */
- (void)setTitleForXAxis:(CPTXYAxis *)xAxis byCurrentXRange:(CPTPlotRange *)xRange {
    xAxis.title = @"时间";
    xAxis.titleDirection = CPTSignNegative;
    xAxis.titleOffset += offset_axisConstraints_X + adn_titleOffset_X;
    xAxis.titleLocation = [CoreplotUtil calculateTitleLocationByCurRange:xRange];//固定轴标题
}

- (void)setTitleForYAxis:(CPTXYAxis *)yAxis {
    yAxis.title = @"体重(Kg)";
    yAxis.titleDirection = CPTSignNegative;
    //yAxis.titleLocation = CPTDecimalFromDouble(self.yMax + adn_titleLocation_Y);//设置标题位置
    yAxis.titleOffset += offset_axisConstraints_Y + adn_titleOffset_Y;
    yAxis.titleLocation = @(self.chatDataModel.yMax + adn_titleLocation_Y);//设置标题位置
}


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




#pragma mark - 设置坐标轴（有时候要求固定坐标轴位置，即使是在缩放的时候）
- (void)setupCoordinateXAxis:(CPTXYAxis *)xAxis {
    //针对该坐标想要固定的点在该轴上的位置相对view是否始终不变(会改变的情况：比如轴原点位置改变，轴缩放）的情况可有设置orthogonalPosition和设置axisConstraints两种不同方法，其中设置axisConstraints是最强方法，且注意使用axisConstraints后，原本orthogonalPosition将会自动变成永远无效，所以使用axisConstraints的时候，可不设置orthogonalPosition
    //方法：设置轴位置
    //方法①：始终不变，则可直接使用orthogonalPosition“固定”（其实只是设置而已）。
    //方法②：会改变，则应该使用axisConstraints真正固定
    if (self.fixedXAxisByAbsolutePosition) {//通过绝对位置，设置x轴的原点位置
        xAxis.orthogonalPosition = @(66);
    } else {                                //通过相对位置位置，设置x轴的原点位置
        xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:offset_axisConstraints_X];
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
    
    lineStyle.lineWidth         = 10.0;  //线条宽度
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
    
    
    xAxis.plotArea.borderWidth = border_Width_plotArea;
    xAxis.plotArea.borderColor = border_Color_plotArea;
    
    
    
}

- (void)setupCoordinateYAxis:(CPTXYAxis *)yAxis {
    if (self.fixedYAxisByAbsolutePosition) {//通过绝对位置，设置y轴的原点位置
        yAxis.orthogonalPosition = @(self.chatDataModel.xDatas.count-10.0);
    } else {                                //通过相对位置位置，设置y轴的原点位置
        yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:offset_axisConstraints_Y];
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


//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//



//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
#pragma mark - 给折现上的点添加值（plot添加值的折现  index点的位置 ）//参考饼状图CPTPieChartViewController的绘制
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx{
    CJChartPlotData *chartPlotData = [self.chatDataModel.yPlotDatas objectAtIndex:idx];
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
    return self.chatDataModel.yPlotDatas.count;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    CJChartPlotData *chartPlotData = [self.chatDataModel.yPlotDatas objectAtIndex:index];
    
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
        
        CJDate *myDate = [self.chatDataModel.xDatas objectAtIndex:[location integerValue]];
        
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
    NSInteger maxTickShowNumber = kXShowCountMin; //设置坐标轴最多展示多少个刻度
    if ([locations count] > maxTickShowNumber) { //如果locations的个数超过自己规定的个数(这里设为7个)
        gapNum = [locations count]/maxTickShowNumber;
        NSLog(@"gapNum = %zd", gapNum);
    }
    return gapNum;
}


- (NSInteger)getGapDistanceForMonthAtLocations:(NSSet *)locations {
    NSInteger gapNum = 1;
    NSInteger maxTickShowNumber = kXShowCountMin; //设置坐标轴最多展示多少个刻度
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
            if (newRange.lengthDouble < kXShowCountMin) {//这里是通过newRange.length来判断。不是通过locations.length来判断。实际上两者是等价的。只不过是这里取不到locations.length而已
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
