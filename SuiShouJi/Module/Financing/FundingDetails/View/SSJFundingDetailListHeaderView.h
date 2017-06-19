//
//  SSJFundingDetailListHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJFundingDetailListHeaderView : UIView

@property(nonatomic, strong) SSJBaseCellItem *item;

//点击按钮的回调
typedef void (^SectionHeaderClickedBlock)();

@property (nonatomic, copy) SectionHeaderClickedBlock SectionHeaderClickedBlock;
@end
