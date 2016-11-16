//
//  CPTAxis+Complete.h
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <CorePlot-CocoaTouch.h>
#import "CJChartData.h"

static CGFloat standValue_Y = 55.0;

@interface CPTAxis (Complete)

- (void)completeCoordinateYLocations:(NSSet *)locations;

- (void)completeCoordinateXLocations:(NSSet *)locations withChartData:(CJChartData *)chartDataModel;

@end
