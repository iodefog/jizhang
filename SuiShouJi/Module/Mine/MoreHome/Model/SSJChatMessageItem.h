//
//  SSJChatMessageItem.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJChatMessageItem : SSJBaseCellItem
/**
 cell高度
 */
//@property (nonatomic, assign) CGFloat replyCellHeight;//回复高度
//@property (nonatomic, assign) CGFloat cCellHeight;//建议高度
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, copy) NSString *creplyContent;//回复内容
@property (nonatomic, copy) NSString *creplyDate;//回复时间
@property (nonatomic, copy) NSString *caddDate;//建议时间
@property (nonatomic, copy) NSString *cContent;//建议内容

@property (nonatomic, strong) NSDate *date;//时间
@property (nonatomic, copy) NSString *content;//内容
@property (nonatomic, copy) NSString *dateStr;
/**
 <#注释#>
 */
@property (nonatomic, assign) BOOL isHiddenTime;
/**
 是我还是系统
 */
@property (nonatomic, assign) BOOL isSystem;
@end
