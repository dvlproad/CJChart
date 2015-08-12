//
//  CJPickerWeightToolBarView.h
//  CJPickerToolBarViewDemo
//
//  Created by lichq on 6/20/15.
//  Copyright (c) 2015 ciyouzen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CJPickerWeightToolBarView;
@protocol CJPickerWeightToolBarViewDelegate <NSObject>
@optional
- (void)confirmDelegate_pickerView:(CJPickerWeightToolBarView *)pickerToolBarView;
- (void)valueChangeDelegate_pickerView:(CJPickerWeightToolBarView *)pickerToolBarView;


@end



@interface CJPickerWeightToolBarView : UIView<UIPickerViewDataSource, UIPickerViewDelegate, CJPickerWeightToolBarViewDelegate>{
    
}
//@property (nonatomic, strong) void(^block)(void);
@property(nonatomic, strong) id<CJPickerWeightToolBarViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) NSMutableArray *selecteds;
@property (nonatomic, strong) NSArray *selecteds_default;

- (id)initWithNibNameDefaultAndDelegate:(id<CJPickerWeightToolBarViewDelegate>)delegate;
- (id)initWithNibName:(NSString *)nibName delegate:(id<CJPickerWeightToolBarViewDelegate>)delegate;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end
