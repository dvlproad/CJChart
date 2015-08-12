//
//  CPTScatterPlotViewController.h
//  Lee
//
//  Created by lichq on 14-11-19.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CorePlot-CocoaTouch.h"

@interface CPTScatterPlotViewController : UIViewController<CPTPlotDataSource, CPTAxisDelegate>{
    
}
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, readwrite, strong) CPTXYGraph *lineGraph;

@property (nonatomic, readwrite, strong) NSMutableArray *dataForPlot;

@end
