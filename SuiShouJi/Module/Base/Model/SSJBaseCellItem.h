//
//  SSJBaseCellItem.h
//  MoneyMore
//
//  Created by old lang on 15-3-23.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBaseCellItem : NSObject <NSCopying>

/**
 返回对应cell的行高
 */
@property (nonatomic) CGFloat rowHeight;

/**
 分割线的内凹值，默认UIEdgeInsetsEmpty，此值不会对cell产生影响
 */
@property (nonatomic) UIEdgeInsets separatorInsets;

/**
 cell的点击效果
 */
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;

@end
