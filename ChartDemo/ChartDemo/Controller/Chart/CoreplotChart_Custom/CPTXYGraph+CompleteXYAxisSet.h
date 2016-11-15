//
//  CPTXYGraph+CompleteXYAxisSet.h
//  ChartDemo
//
//  Created by 李超前 on 2016/11/15.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <CorePlot-CocoaTouch.h>

#import "CoreplotUtil.h"

//坐标轴与边界距离(待完善)
#define offset_axisConstraints_X    -60 //这里是固定x坐标轴在最下边（距离可视下边界有多少个像素距离）
#define offset_axisConstraints_Y    -80 //这里是固定y坐标轴在最右边（距离可视右边界有多少个像素距离）（未设置的时候，值是null）

@interface CPTXYGraph (CompleteXYAxisSet)

- (void)completeXAxisSettingWithFixedXAxisByAbsolutePosition:(BOOL)fixedXAxisByAbsolutePosition;
- (void)completeYAxisSettingWithFixedYAxisByAbsolutePosition:(BOOL)fixedYAxisByAbsolutePosition;

- (void)completeXAxisTitle:(NSString *)title;
- (void)completeYAxisTitle:(NSString *)title;

@end
