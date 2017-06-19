//
//  SSJAdviceItem.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
@class SSJChatMessageItem;
@interface SSJAdviceItem : SSJBaseCellItem
@property (nonatomic, strong) NSArray<SSJChatMessageItem *> *messageItems;
@end
