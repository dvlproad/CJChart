//
//  NutritionChartViewController.h
//  HealthyDiet
//
//  Created by lichq on 15-1-9.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CorePlot-CocoaTouch.h>
#import "QCPTTheme.h"   //自定义的Coreplot主题

#import "ADNInfo.h"

@interface NutritionChartViewController : UIViewController<CPTPlotDataSource, CPTAxisDelegate>{
    
}
@property(nonatomic, strong) NSString *uid;

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, readwrite, strong) CPTXYGraph *barChart;
@property (nonatomic, readwrite, strong) NSMutableArray *dataForBarBG;
@property (nonatomic, readwrite, strong) NSArray *dataForBar;
@property (nonatomic, readwrite, strong) NSMutableArray *dataForXLable;

@property (nonatomic, strong) CPTColor *colorForBar;
@property (nonatomic, readwrite, strong) NSArray *dataForBar1;
@property (nonatomic, strong) CPTColor *colorForBar1;
@property (nonatomic, readwrite, strong) NSArray *dataForBar2;
@property (nonatomic, strong) CPTColor *colorForBar2;
@property (nonatomic, readwrite, strong) NSArray *dataForBar3;
@property (nonatomic, strong) CPTColor *colorForBar3;
@property (nonatomic, readwrite, strong) NSArray *dataForBar4;
@property (nonatomic, strong) CPTColor *colorForBar4;



@end
