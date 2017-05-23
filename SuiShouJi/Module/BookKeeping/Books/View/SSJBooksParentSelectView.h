//
//  SSJBooksParentSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

SSJ_DEPRECATED

@interface SSJBooksParentSelectView : UIView

@property (nonatomic, copy) void(^parentSelectBlock)(NSInteger selectParent);

- (void)show;

- (void)dismiss;

@end
