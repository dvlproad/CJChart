//
//  CJPickerWeightToolBarView.m
//  CJPickerToolBarViewDemo
//
//  Created by lichq on 6/20/15.
//  Copyright (c) 2015 ciyouzen. All rights reserved.
//

#import "CJPickerWeightToolBarView.h"

@implementation CJPickerWeightToolBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithNibNameDefaultAndDelegate:(id<CJPickerWeightToolBarViewDelegate>)delegate{
    self = [[CJPickerWeightToolBarView alloc]initWithNibName:@"CJPickerWeightToolBarView" delegate:self];
    return self;
}

- (id)initWithNibName:(NSString *)nibName delegate:(id<CJPickerWeightToolBarViewDelegate>)delegate{
    self = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return [self.datas count];
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [[self.datas objectAtIndex:component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[self.datas objectAtIndex:component] objectAtIndex:row];
}



#pragma mark - ValueChange_PickerView
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSArray *datasC = [self.datas objectAtIndex:component];
    NSString *string = [datasC objectAtIndex:row];
    [self.selecteds replaceObjectAtIndex:component withObject:string];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(valueChangeDelegate_pickerView:)]) {
        [self.delegate valueChangeDelegate_pickerView:self];
    }
}

#pragma mark - 选择确认_PickerView
- (IBAction)confirm_pickerView:(id)sender{
    //self.block();
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmDelegate_pickerView:)]) {
        [self.delegate confirmDelegate_pickerView:self];
    }
}


#pragma mark - 设置初始默认值
- (void)setSelecteds_default:(NSArray *)selecteds_default{
    if (selecteds_default.count != self.datas.count) {
        NSLog(@"ERROR: 默认值个数不正确 应该是%zd个，而不是%zd个", self.datas.count, selecteds_default.count);
        return;
    }
    
    self.selecteds = [[NSMutableArray alloc] initWithArray:selecteds_default];
    
    for (int indexC = 0; indexC < self.datas.count; indexC++) {
        NSArray *datasC = [self.datas objectAtIndex:indexC];
        NSString *selected_default = [selecteds_default objectAtIndex:indexC];
        if ([datasC containsObject:selected_default] == NO) {
            NSLog(@"ERROR: %@ noContain", [NSString stringWithFormat:@"%s:%d", __func__, __LINE__]);
            continue;
        }
        NSInteger indexR = [datasC indexOfObject:selected_default];
        [self.pickerView selectRow:indexR inComponent:indexC animated:NO];
    }
    
}



#pragma mark - animation
- (void)showInView:(UIView *)view{
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
    
}

- (void)dismiss{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         
                     }];
}




@end
