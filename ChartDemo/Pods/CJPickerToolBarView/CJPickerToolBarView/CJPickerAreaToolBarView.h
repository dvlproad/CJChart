//
//  CJPickerAreaToolBarView.h
//  CJPickerToolBarViewDemo
//
//  Created by lichq on 6/20/15.
//  Copyright (c) 2015 ciyouzen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CJPickerAreaToolBarView;
@protocol CJPickerAreaToolBarViewDelegate <NSObject>
@optional
- (void)confirmDelegate_pickerArea:(CJPickerAreaToolBarView *)pickerToolBarView;
- (void)valueChangeDelegate_pickerArea:(CJPickerAreaToolBarView *)pickerToolBarView;


@end



@interface CJPickerAreaToolBarView : UIView<UIPickerViewDataSource, UIPickerViewDelegate, CJPickerAreaToolBarViewDelegate>{
    
}
//@property (nonatomic, strong) void(^block)(void);
@property(nonatomic, strong) id<CJPickerAreaToolBarViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *selecteds;
@property (nonatomic, strong) NSArray *selecteds_default;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSArray *dicArray;

+ (NSMutableArray *)getDatasByDatasC_0:(NSArray *)m_datasC_0 dicArray:(NSArray *)m_dicArray;

- (id)initWithNibNameDefaultAndDelegate:(id<CJPickerAreaToolBarViewDelegate>)delegate;
- (id)initWithNibName:(NSString *)nibName delegate:(id<CJPickerAreaToolBarViewDelegate>)delegate;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end
