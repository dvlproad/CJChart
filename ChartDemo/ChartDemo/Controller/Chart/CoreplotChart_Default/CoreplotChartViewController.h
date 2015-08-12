//
//  CoreplotChartViewController.h
//  Lee
//
//  Created by lichq on 14-11-19.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CPTScatterPlotViewController.h"
#import "CPTBarChartViewController.h"
#import "CPTPieChartViewController.h"

@interface CoreplotChartViewController : UIViewController<UITabBarDelegate>{
    
}
@property (nonatomic, strong) IBOutlet UIView *chartView;
@property (nonatomic, strong) IBOutlet UITabBar *tabBar;

@end
