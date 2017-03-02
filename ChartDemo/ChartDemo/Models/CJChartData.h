//
//  CJChartData.h
//  ChartDemo
//
//  Created by lichq on 15-1-6.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJDate.h"
#import "CJChartPlotData.h"

@interface CJChartData : NSObject

//x轴显示个数
@property (nonatomic, assign) NSInteger xShowCountLeast;    //x轴上最少显示单位的个数,即放大到最大也得至少显示的个数，而更多的单位可通过移动或缩放来查看
@property (nonatomic, assign) NSInteger xShowCountDefault;  //x轴上初始默认显示单位的个数（不应该比kXShowCountMin小，之后随着缩放操作xShowCount会随时变化）


@property (nonatomic, assign) CGFloat xMin;
@property (nonatomic, assign) CGFloat xMax;
@property (nonatomic, strong) NSMutableArray<CJDate *> *xDatas;
//默认所有点显示完后，最后还要有多少个单位占位，即需要在原来的所有点上额外加上多少个空点，用来占位，占最后几位 //并且这里不娶2.0整数，是为了在绘制网格线的时候，不让最后一个点成为主/副刻度，从而出现网格线
@property (nonatomic, assign) NSInteger xPlaceholderUnitCountAtBegin;   /**< 开头多添加几条网格线 */
@property (nonatomic, assign) NSInteger xPlaceholderUnitCountAtLast;    /**< 结尾多添加几条网格线 */

@property (nonatomic, assign) CGFloat yMin;
@property (nonatomic, assign) CGFloat yMax;
@property (nonatomic, strong) NSMutableArray<CJChartPlotData *> *yPlotDatas;
@property (nonatomic, assign) NSInteger yMinWhenEmpty; /**< 无数据时候，y轴上显示的最小值 */
@property (nonatomic, assign) NSInteger yMaxWhenEmpty; /**< 无数据时候，y轴上显示的最大值 */

/**
 *  唯一的初始化方法
 *
 *  @param xShowCountLeast      x轴上至少显示的个数(无论放大或缩小)
 *  @param xShowCountDefault    xShowCountDefault
 */
- (instancetype)initWithXShowCountLeast:(NSInteger)xShowCountLeast xShowCountDefault:(NSInteger)xShowCountDefault;

@end
