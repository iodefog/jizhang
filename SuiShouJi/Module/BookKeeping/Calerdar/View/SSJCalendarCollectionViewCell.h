//
//  SJJCalendarCollectionViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCalendarCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)NSString *currentDay;
@property(nonatomic,strong)UILabel *dateLabel;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL iscurrentDay;
@property(nonatomic) BOOL selectable;
@end
