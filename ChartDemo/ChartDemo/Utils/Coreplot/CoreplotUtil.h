//
//  CoreplotUtil.h
//  Lee
//
//  Created by lichq on 15/4/9.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CorePlot-CocoaTouch.h"


//在默认的距离上再偏移多少 adn: after_default_num   adr: after_default__ratio
#define adr_titleLocation_X -0.0    //注意：不要删掉：这里使用减去10%，而不使用减去具体数字（比如double subDouble = 5.0），是为了使得不仅在滑动的时候能让轴标签固定，也能在缩放的时候使得轴标签固定。



@interface CoreplotUtil : NSObject

+ (NSDecimalNumber *)calculateTitleLocationByCurRange:(CPTPlotRange *)curRange;

@end
