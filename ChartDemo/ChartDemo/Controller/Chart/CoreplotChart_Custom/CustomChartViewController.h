//
//  CustomChartViewController.h
//  Lee
//
//  Created by lichq on 15/4/9.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightChartViewController.h"
#import "NutritionChartViewController.h"
#import "CPTPieChartViewController.h"

@interface CustomChartViewController : UIViewController<UITabBarDelegate>{
    
}
@property (nonatomic, strong) IBOutlet UIView *chartView;
@property (nonatomic, strong) IBOutlet UITabBar *tabBar;

@end
