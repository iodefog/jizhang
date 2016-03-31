//
//  SSJFundingDetailListHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFundingDetailListItem.h"

@interface SSJFundingDetailListHeaderView : UITableViewHeaderFooterView

@property(nonatomic, strong) SSJFundingDetailListItem *item;

//点击记录按钮的回调
typedef void (^SectionHeaderClickedBlock)();

@property (nonatomic, copy) SectionHeaderClickedBlock SectionHeaderClickedBlock;
@end
