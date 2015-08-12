//
//  CPTPieChartViewController.h
//  Lee
//
//  Created by lichq on 14-11-24.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CorePlot-CocoaTouch.h>

@interface CPTPieChartViewController : UIViewController<CPTPieChartDataSource, CPTPieChartDelegate>{
    
}
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, readwrite, strong) CPTXYGraph *pieChart;

@property (nonatomic, readwrite, strong) NSArray *dataForChart;
@property (nonatomic, readwrite, strong) NSTimer *timer;

-(void)timerFired;

@end
