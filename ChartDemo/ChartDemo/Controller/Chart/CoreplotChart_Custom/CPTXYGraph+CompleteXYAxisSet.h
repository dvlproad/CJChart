//
//  CPTXYGraph+CompleteXYAxisSet.h
//  ChartDemo
//
//  Created by 李超前 on 2016/11/15.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <CorePlot-CocoaTouch.h>

#import "CoreplotUtil.h"

@interface CPTXYGraph (CompleteXYAxisSet)

- (void)completeXAxisSettingWithFixedXAxisByAbsolutePosition:(BOOL)fixedXAxisByAbsolutePosition;
- (void)completeYAxisSettingWithFixedYAxisByAbsolutePosition:(BOOL)fixedYAxisByAbsolutePosition;

- (void)completeXAxisTitle:(NSString *)title;
- (void)completeYAxisTitle:(NSString *)title;

@end
