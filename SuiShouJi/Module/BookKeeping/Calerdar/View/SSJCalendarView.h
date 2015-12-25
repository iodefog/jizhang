//
//  calendarView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCalendarView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

//当前选中的年份和月份
@property (nonatomic)long year;
@property (nonatomic)long month;
@property (nonatomic) long day;
@property (nonatomic)long selectedYear;
@property (nonatomic)long selectedMonth;
@property (nonatomic,strong)UICollectionView *calendar;

//选中日期的回调
typedef void (^DateSelectedBlock)(long year , long month ,long day);

@property (nonatomic, copy) DateSelectedBlock DateSelectedBlock;

- (CGFloat)viewHeight;

@end
