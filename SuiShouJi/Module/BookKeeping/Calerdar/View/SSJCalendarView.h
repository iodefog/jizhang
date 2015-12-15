//
//  calendarView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCalendarView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

//当前日期必传格式为yyyy-MM-dd
@property(nonatomic,strong) NSDate *currentNSDate;
@property (nonatomic,strong)UICollectionView *calendar;
- (CGFloat)viewHeight;
@end
