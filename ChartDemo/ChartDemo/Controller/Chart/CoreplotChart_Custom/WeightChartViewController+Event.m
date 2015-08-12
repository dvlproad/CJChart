//
//  WeightChartViewController+Event.m
//  HealthyDiet
//
//  Created by lichq on 15-1-6.
//  Copyright (c) 2015年 lichq. All rights reserved.
//

#import "WeightChartViewController+Event.h"


@implementation WeightChartViewController (Event)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [picker_birthday dismiss];
}

- (IBAction)chooseBirthday:(id)sender{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (picker_birthday == nil) {
        picker_birthday = [[CJDatePickerToolBarView alloc]initWithNibName:@"CJDatePickerToolBarView" delegate:self];
        picker_birthday.datePicker.datePickerMode = UIDatePickerModeDate;
        picker_birthday.datePicker.maximumDate = [NSDate date];
        picker_birthday.datePicker.minimumDate = [dateFormatter dateFromString:@"1900-01-01"];;
    }
    
    
    picker_birthday.datePicker.date = [dateFormatter dateFromString:@"1989-12-27"];
    
//    [picker_birthday showInView:self.view];
    [picker_birthday showInLocationType:CJPopupViewLocationBottom animationType:CJPopupViewAnimationNone];
}

- (void)confirmDelegate_datePicker:(CJDatePickerToolBarView *)pickerToolBarView{
    NSDate *selDate = pickerToolBarView.datePicker.date;
    NSString *value = [NSString stringWithFormat:@"%@", selDate];
    [[[UIAlertView alloc]initWithTitle:@"所选日期为" message:value delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    
    [pickerToolBarView dismiss];
}

- (void)valueChangeDelegate_datePicker:(CJDatePickerToolBarView *)pickerToolBarView{
    UIDatePicker *m_datePicker = pickerToolBarView.datePicker;
    
    NSDate *date = m_datePicker.date;
    NSDate *maximumDate = m_datePicker.maximumDate;
    NSDate *minimumDate = m_datePicker.minimumDate;
    
    NSTimeZone *zone =[NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localDate =[date dateByAddingTimeInterval: interval];
    
    NSLog(@"1当前选择:%@",localDate);
    
    if ([date compare:minimumDate] == NSOrderedAscending) {
        NSLog(@"当前选择日期太小");
    }else if ([date compare:maximumDate] == NSOrderedDescending) {
        NSLog(@"当前选择日期太大");
    }
}



@end
