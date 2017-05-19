//
//  SSJSelectCreateShareBookType.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJSelectCreateShareBookType : UIView
@property (nonatomic, copy) void(^selectCreateShareBookBlock)(NSInteger selectParent);

- (void)show;

- (void)dismiss;

@end
