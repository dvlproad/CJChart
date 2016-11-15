//
//  CJChartData.m
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import "CJChartData.h"

@implementation CJChartData

- (instancetype)init {
    return nil;
}

- (instancetype)initWithXShowCountLeast:(NSInteger)xShowCountLeast xShowCountDefault:(NSInteger)xShowCountDefault {
    self = [super init];
    if (self) {
        _xShowCountLeast = xShowCountLeast;
        _xShowCountDefault = xShowCountDefault;
        
        [self checkXShowCountDefault];
    }
    return self;
}

- (void)setXShowCountDefault:(NSInteger)xShowCountDefault {
    _xShowCountDefault = xShowCountDefault;
    
    [self checkXShowCountDefault];
}

- (void)setXShowCountLeast:(NSInteger)xShowCountLeast {
    _xShowCountLeast = xShowCountLeast;
    
    [self checkXShowCountDefault];
}

- (void)checkXShowCountDefault {
    if (_xShowCountDefault < _xShowCountLeast) {
        NSLog(@"设置的默认显示个数%zd太小，故自动设置使用最小显示个数%zd", _xShowCountDefault, _xShowCountLeast);
        _xShowCountDefault = _xShowCountLeast;
    }
    NSLog(@"最终X轴的显示个数为%ld", _xShowCountDefault);
}


@end
