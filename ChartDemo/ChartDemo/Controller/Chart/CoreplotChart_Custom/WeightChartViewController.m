//
//  WeightChartViewController.m
//  HealthyDiet
//
//  Created by lichq on 15-1-6.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "WeightChartViewController.h"

#import "CPTXYGraph+CompleteXYGraph.h"
#import "CPTXYGraph+CompleteXYPlotSpace.h"
#import "CPTXYGraph+CompleteXYAxisSet.h"

#import "CPTScatterPlot+Complete.h"

#import "CPTAxis+Complete.h"

#import "QCPTTheme.h"
#import "CJChartAxisSetting.h"

#import "CJScatterPlotDataSource.h"


//边框属性
//绘图区plotArea的边框属性
#define border_Width_plotArea   4.0
#define border_Color_plotArea   [UIColor redColor].CGColor

//网格线设置
//去掉最开头、最结尾的网格线，其实是显示不到而已
#define globalXRange_NoShowAtBeginAndLast   0.1
#define globalYRange_NoShowAtBeginAndLast   0.1

        
@interface WeightChartViewController () {
    
}
@property (nonatomic, strong) CJScatterPlotDataSource *scatterPlotDataSource;

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
    
    
//    ADWInfo *info = [[ADWInfo alloc] initWithXDateString:@"2017-03-02" yValueString:@"66"];
//    info.uid = self.uid;
//    info.wid = @"10009";
//    info.modified = @"1013513515";
//    [WeightFMDBFileManager insertInfo:info];
}



- (IBAction)addWeight:(id)sender{
    
}


/** 获取本地数据库中的体重数据 */
- (void)getLocalInfoForWeight {
    self.datas = [WeightFMDBFileManager selectInfoArrayWhereUID:self.uid];
    NSLog(@"self.datas = %@", self.datas);
}

/** 更新体重的UI */
- (void)reloadUIForWeight {
    self.chartDataModel = [[CJChartData alloc] initWithXShowCountLeast:3 xShowCountDefault:10];
    self.chartDataModel.xPlaceholderUnitCountAtBegin = 2;
    self.chartDataModel.xPlaceholderUnitCountAtLast = 2;
    self.chartDataModel.yMinWhenEmpty = standValue_Y - 5;
    self.chartDataModel.yMaxWhenEmpty = standValue_Y + 6;
    [self.chartDataModel completeChartDataByData:self.datas];
    
    
    self.chartAxisSetting = [[CJChartAxisSetting alloc] init];
//    self.chartAxisSetting.fixedXAxisByAbsolutePosition = YES;
//    self.chartAxisSetting.fixedYAxisByAbsolutePosition = YES;
    
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
    yAxis.plotArea.borderWidth = 1;
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
    CPTScatterPlot *scatterPlot  = [[CPTScatterPlot alloc] init];
    [scatterPlot completeScatterPlot:@"Blue Plot"];
    
    self.scatterPlotDataSource = [[CJScatterPlotDataSource alloc] initWithChartData:self.chartDataModel];
    scatterPlot.dataSource = self.scatterPlotDataSource; //曲线图的数据源
    
    scatterPlot.delegate = self;  //曲线图的委托，比如实现各个数据点响应操作的CPTScatterPlotDelegate委托
    
    [newGraph addPlot:scatterPlot];
}





//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//



//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

#pragma mark - CPTScatterPlotDelegate
/** 点击各个数据点响应操作 */
- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx{
    
//    NSDecimalNumber *deNumber = [NSDecimalNumber decimalNumberWithDecimal:plot.areaBaseValue];//NSDecimal转为NSDecimalNumber
//    NSLog(@"idx = %zd, %f, %f, %@, %@", idx, plot.labelOffset, [deNumber floatValue], NSStringFromCGRect(plot.contentsRect), NSStringFromCGPoint(plot.position));
    //plot.plotArea.axisSet;
    //TODO怎么获取所点击的坐标点的位置
    
}
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<//




#pragma mark -

#pragma mark - CPTAxisDelegate (X轴、Y轴标签设置)
- (BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    //NSLog(@"dataForXLable->%d ?=? %d<-locationsCount", self.dataForXLable.count, locations.count);
    //注locations只代表主刻度上的那些location
    if (axis.coordinate == CPTCoordinateY) {    //Y轴标签设置
        [axis completeCoordinateYLocations:locations];
        
        return NO;
        
    } else  {   //X轴标签设置
        [axis completeCoordinateXLocations:locations withChartData:self.chartDataModel];
        return NO;//因为在这里我们自己设置了轴标签的描绘，所以这个方法返回 NO 告诉系统不需要使用系统的标签描绘设置了。
    }
}






#pragma mark - CPTPlotSpaceDelegate
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
