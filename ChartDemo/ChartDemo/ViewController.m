//
//  ViewController.m
//  ChartDemo
//
//  Created by lichq on 8/6/15.
//  Copyright (c) 2015 ciyouzen. All rights reserved.
//

#import "ViewController.h"

#import "PNChartViewController.h"       //图表PNChart
#import "CoreplotChartViewController.h" //图表Coreplot
#import "CustomChartViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pnchart:(id)sender{
    PNChartViewController *vc = [[PNChartViewController alloc]initWithNibName:@"PNChartViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)coreplot_defalut:(id)sender{
    CoreplotChartViewController *vc = [[CoreplotChartViewController alloc]initWithNibName:@"CoreplotChartViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)coreplot_custom:(id)sender{
    CustomChartViewController *vc = [[CustomChartViewController alloc]initWithNibName:@"CustomChartViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
