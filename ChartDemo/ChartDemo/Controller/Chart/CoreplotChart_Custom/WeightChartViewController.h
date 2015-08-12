//
//  WeightChartViewController.h
//  HealthyDiet
//
//  Created by lichq on 15-1-6.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CorePlot-CocoaTouch.h>

#import "NSDate+Category.h"
#import "NSDate+FindAllDate.h"

#import "CoreplotUtil.h"

#import "ADWFMDBUtil.h"

#import <CJDatePickerToolBarView.h>
#import <UIView+CJPopupView.h>

@interface WeightChartViewController : UIViewController<CPTPlotDataSource, CPTAxisDelegate, CPTPlotSpaceDelegate, CPTScatterPlotDelegate, UITextFieldDelegate>{//CPTScatterPlotDelegate是为了调用点击各个数据点响应操作
//    CGFloat curValue;
//    CGFloat tarValue;
    
    CPTPlotRange *xPlotRange;
    CPTPlotRange *yPlotRange;
    CPTPlotRange *xPlotRangeCurrent;//为了限制缩放的最小距离
    
    BOOL shouldAddWeight;
    
    CJDatePickerToolBarView *picker_birthday;
}
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, readwrite, strong) CPTXYGraph *lineGraph;

@property (nonatomic, readwrite, strong) NSMutableArray *dataForXLable;
@property (nonatomic, assign) CGFloat xMin;
@property (nonatomic, assign) CGFloat xMax;

@property (nonatomic, readwrite, strong) NSMutableArray *dataForPlot;
@property (nonatomic, assign) CGFloat yMin;
@property (nonatomic, assign) CGFloat yMax;

@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSMutableArray *datas;


- (void)getInfoL_WeightChart;
- (void)reShowUI_WeightChart;

@end
