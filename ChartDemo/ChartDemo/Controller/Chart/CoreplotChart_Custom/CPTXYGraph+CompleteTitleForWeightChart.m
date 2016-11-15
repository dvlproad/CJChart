//
//  CPTXYGraph+CompleteTitleForWeightChart.m
//  ChartDemo
//
//  Created by 李超前 on 2016/11/15.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CPTXYGraph+CompleteTitleForWeightChart.h"

//画布标题设置：GraphTitle
#define GraphTitle_titleDisplacement    CGPointMake(0.0, 3.0) //画布标题在设置的区域上的什么点展示
#define GraphTitle_color                [UIColor blackColor] //画布标题颜色
#define GraphTitle_fontSize             14.0    //画布标题文字大小

@implementation CPTXYGraph (CompleteTitleForWeightChart)

/** 设置画布Graph的标题GraphTitle（可设多行） */
- (void)completeGraphTitle:(NSString *)title subTitle:(NSString *)subTitle {
    CPTXYGraph *xyGraph = self;
    
    NSString *lineOne = title;
    NSString *lineTwo = subTitle;
    
    BOOL hasAttributedStringAdditions = (&NSFontAttributeName != NULL) &&
    (&NSForegroundColorAttributeName != NULL) &&
    (&NSParagraphStyleAttributeName != NULL);
    
    if ( hasAttributedStringAdditions ) {
        NSMutableAttributedString *graphTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo]];
        
        [graphTitle addAttribute:NSForegroundColorAttributeName
                           value:GraphTitle_color
                           range:NSMakeRange(0, lineOne.length)];
        
        [graphTitle addAttribute:NSForegroundColorAttributeName
                           value:[UIColor lightGrayColor]
                           range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        
        NSMutableParagraphStyle *paragraphStyle =[[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment = CPTTextAlignmentCenter;
        [graphTitle addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:NSMakeRange(0, graphTitle.length)];
        
        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:GraphTitle_fontSize];
        [graphTitle addAttribute:NSFontAttributeName
                           value:titleFont
                           range:NSMakeRange(0, lineOne.length)];
        
        titleFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        [graphTitle addAttribute:NSFontAttributeName
                           value:titleFont
                           range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        
        xyGraph.attributedTitle = graphTitle;
    }else {
        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
        titleStyle.color         = [CPTColor whiteColor];
        titleStyle.fontName      = @"Helvetica-Bold";
        titleStyle.fontSize      = GraphTitle_fontSize;
        titleStyle.textAlignment = CPTTextAlignmentCenter;
        
        xyGraph.title          = [NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo];
        xyGraph.titleTextStyle = titleStyle;
    }
    xyGraph.titleDisplacement        = GraphTitle_titleDisplacement;
    xyGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTopLeft;
}

@end
