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
#import <CJPopupView/UIView+CJPopupInView.h>

#import "CJChartData.h"

@interface WeightChartViewController : UIViewController<CPTPlotDataSource, CPTAxisDelegate, CPTPlotSpaceDelegate, CPTScatterPlotDelegate, UITextFieldDelegate>{//CPTScatterPlotDelegate是为了调用点击各个数据点响应操作
//    CGFloat curValue;
//    CGFloat tarValue;
    
    
    
    BOOL shouldAddWeight;
    
    CJDatePickerToolBarView *picker_birthday;
}
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, readwrite, strong) CPTXYGraph *lineGraph;

@property (nonatomic, readwrite, strong) CJChartData *chatDataModel; /**< x轴数据 */

@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSMutableArray *datas;


@end
