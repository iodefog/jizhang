//
//  SSJBooksTransferSelectView.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBooksItem.h"


@interface SSJBooksTransferSelectView : UIView

// 类型,1是转入.0是转出
typedef NS_ENUM(NSInteger, SSJBooksTransferViewType) {
    SSJBooksTransferViewTypeTransferOut = 0,
    SSJBooksTransferViewTypeTransferIn = 1
};

@property (nonatomic, strong) __kindof SSJBaseCellItem <SSJBooksItemProtocol> *booksTypeItem;

@property (nonatomic, strong) NSNumber *chargeCount;

- (instancetype)initWithFrame:(CGRect)frame type:(SSJBooksTransferViewType)type;

@property (nonatomic, copy) void(^transferInSelectButtonClick)();


@end
