//
//  WeightChartViewController.h
//  HealthyDiet
//
//  Created by lichq on 15-1-6.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CorePlot-CocoaTouch.h>

#import "WeightFMDBFileManager.h"

#import <CJDatePickerToolBarView.h>
#import <CJPopupAction/UIView+CJPopupInView.h>

#import "CJChartData+Complete.h"

@interface WeightChartViewController : UIViewController<CPTPlotDataSource, CPTScatterPlotDelegate, CPTAxisDelegate, CPTPlotSpaceDelegate, CPTScatterPlotDelegate, UITextFieldDelegate>{//CPTScatterPlotDelegate是为了调用点击各个数据点响应操作
//    CGFloat curValue;
//    CGFloat tarValue;
    
    
    
    BOOL shouldAddWeight;
    
    CJDatePickerToolBarView *picker_birthday;
}
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, readwrite, strong) CPTXYGraph *lineGraph;

@property (nonatomic, readwrite, strong) CJChartData *chartDataModel; /**< 图标数据 */

@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSMutableArray *datas;


@end
