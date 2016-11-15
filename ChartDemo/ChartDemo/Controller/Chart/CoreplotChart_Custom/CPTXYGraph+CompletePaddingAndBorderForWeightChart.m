//
//  CPTXYGraph+CompletePaddingAndBorderForWeightChart.m
//  ChartDemo
//
//  Created by 李超前 on 2016/11/15.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CPTXYGraph+CompletePaddingAndBorderForWeightChart.h"

@implementation CPTXYGraph (CompletePaddingAndBorderForWeightChart)

- (void)completeGraphPaddingAndBorder {
    CPTXYGraph *xyGraph = self;
    
    xyGraph.paddingLeft   = 10.0;
    xyGraph.paddingTop    = 10.0;
    xyGraph.paddingRight  = 10.0;
    xyGraph.paddingBottom = 10.0;
    
    xyGraph.plotAreaFrame.paddingTop = 20.0;
    xyGraph.plotAreaFrame.paddingRight = 20.0;
    xyGraph.plotAreaFrame.paddingLeft = 50.0 ;
    xyGraph.plotAreaFrame.paddingBottom = 40.0 ;
    
    /*
     xyGraph.borderWidth = 1.0;
     xyGraph.borderColor = [UIColor redColor].CGColor;
     
     xyGraph.plotAreaFrame.borderWidth = 2.0;
     xyGraph.plotAreaFrame.borderColor = [UIColor greenColor].CGColor;
     */
}

@end
