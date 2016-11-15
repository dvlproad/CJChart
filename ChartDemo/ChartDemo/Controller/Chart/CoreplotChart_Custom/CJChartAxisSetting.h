//
//  CJChartAxisSetting.h
//  ChartDemo
//
//  Created by 李超前 on 2016/11/15.
//  Copyright © 2016年 ciyouzen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJChartAxisSetting : NSObject {
    
}
//通过绝对位置固定坐标轴时，由于是使用绝对位置，所以当视图移动的时候，坐标轴也会随着绝对位置在视图上的移动而移动
@property (nonatomic, assign) BOOL fixedXAxisByAbsolutePosition;   /**< 通过绝对位置固定X轴 */
@property (nonatomic, assign) BOOL fixedYAxisByAbsolutePosition;   /**< 通过绝对位置固定Y轴 */

@end
