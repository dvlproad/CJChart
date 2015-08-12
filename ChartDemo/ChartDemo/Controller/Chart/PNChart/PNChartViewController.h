//
//  PNChartViewController.h
//  Lee
//
//  Created by lichq on 14-11-18.
//  Copyright (c) 2014年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PNChart.h>

@interface PNChartViewController : UIViewController{
    
}
@property (nonatomic, weak) IBOutlet PNLineChart *chart_Line;
@property (nonatomic, weak) IBOutlet PNBarChart *chart_Bar;


@end
