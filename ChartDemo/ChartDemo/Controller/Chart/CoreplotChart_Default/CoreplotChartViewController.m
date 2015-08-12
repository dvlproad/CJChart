//
//  CoreplotChartViewController.m
//  Lee
//
//  Created by lichq on 14-11-19.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import "CoreplotChartViewController.h"

@interface CoreplotChartViewController ()

@end

@implementation CoreplotChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Coreplot", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CPTScatterPlotViewController *vc1 = [[CPTScatterPlotViewController alloc]initWithNibName:@"CPTScatterPlotViewController" bundle:nil];
    CPTBarChartViewController *vc2 = [[CPTBarChartViewController alloc]initWithNibName:@"CPTBarChartViewController" bundle:nil];
    CPTPieChartViewController *vc3 = [[CPTPieChartViewController alloc]initWithNibName:@"CPTPieChartViewController" bundle:nil];
    [self addChildViewController:vc1];
    [self addChildViewController:vc2];
    [self addChildViewController:vc3];
    
    vc1.view.tag = 1000;
    vc2.view.tag = 1001;
    vc3.view.tag = 1002;
    [self.chartView addSubview:vc1.view];
    [self.chartView addSubview:vc2.view];
    [self.chartView addSubview:vc3.view];
    
    //UITabBarItem *item = (UITabBarItem *)[self.tabBar viewWithTag:1000];//item = nil;
    UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
    [self.tabBar setSelectedItem:item];
    
    UIView *view = [self.chartView viewWithTag:item.tag];
    [self.chartView bringSubviewToFront:view];
    
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    UIView *view = [self.chartView viewWithTag:item.tag];
    [self.chartView bringSubviewToFront:view];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
