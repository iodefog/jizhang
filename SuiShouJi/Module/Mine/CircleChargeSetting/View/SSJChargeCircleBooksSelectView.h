//
//  SSJChargeCircleBooksSelectView.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/29.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBooksTypeItem.h"

@interface SSJChargeCircleBooksSelectView : UIView

@property (nonatomic, strong) NSArray *booksArr;

- (void)showWithSelectBooksId:(NSString *)booksId;

- (void)dismiss;

@property (nonatomic, copy) void(^didSelectBooksItem)(SSJBooksTypeItem *booksItem);

@property (nonatomic, copy) void(^dismissBlock)();

@end
