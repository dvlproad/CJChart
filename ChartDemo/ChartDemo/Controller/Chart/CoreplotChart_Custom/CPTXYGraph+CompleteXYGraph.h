//
//  CPTXYGraph+CompleteXYGraph.h
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <CorePlot-CocoaTouch.h>

@interface CPTXYGraph (CompleteXYGraph)

/** 设置画布Graph的内边距padding、边框border */
- (void)completeGraphPaddingAndBorder;

/** 设置画布Graph的标题GraphTitle（可设多行） */
- (void)completeGraphTitle:(NSString *)title subTitle:(NSString *)subTitle;


@end
