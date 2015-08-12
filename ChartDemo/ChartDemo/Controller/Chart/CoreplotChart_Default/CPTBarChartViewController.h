//
//  CPTBarChartViewController.h
//  Lee
//
//  Created by lichq on 14-11-24.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CorePlot-CocoaTouch.h"

#import "QCPTTheme.h"   //自定义的Coreplot主题

@interface CPTBarChartViewController : UIViewController<CPTPlotDataSource>{
    
}
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, readwrite, strong) CPTXYGraph *barChart;
//@property (nonatomic, readwrite, strong) NSMutableArray *dataForXLable;
@property (nonatomic, readwrite, strong) NSMutableArray *dataForBarBG;
@property (nonatomic, readwrite, strong) NSMutableArray *dataForBar;
@property (nonatomic, strong) CPTColor *colorForBarBG;
@property (nonatomic, strong) CPTColor *colorForBar;

@property (nonatomic, readwrite, strong) NSTimer *timer;

-(void)timerFired;

- (void)reloadChartUI;

@end
