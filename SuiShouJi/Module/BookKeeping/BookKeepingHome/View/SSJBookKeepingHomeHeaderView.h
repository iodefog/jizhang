//
//  SSJBookKeepingHomeHeaderView.h
//  SuiShouJi
//
//  Created by ricky on 16/10/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBookKeepingHomeListItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJBookKeepingHomeHeaderView : UITableViewHeaderFooterView

@property (nonatomic,strong) UILabel *incomeLabel;

@property (nonatomic,strong) UILabel *expenditureLabel;

@property (nonatomic,strong) UIButton *categoryImageButton;

@property(nonatomic, strong) UIView *dotView;

@property(nonatomic, strong) SSJBookKeepingHomeListItem *item;

@property(nonatomic) BOOL isAnimating;

-(void)shake ;

-(void)animatedShowCellWithDistance:(float)distance delay:(float)delay completion:(void (^ __nullable)())completion;

NS_ASSUME_NONNULL_END

@end
