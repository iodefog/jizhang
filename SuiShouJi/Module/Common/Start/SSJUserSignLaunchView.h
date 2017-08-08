//
//  SSJUserSignLaunchView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SSJStartLunchItem;
@interface SSJUserSignLaunchView : UIView
typedef void(^SSJSkipBtnBlock)(UIButton *btn);

@property (nonatomic, copy) SSJSkipBtnBlock skipBtnBlock;

- (void)showWith:(SSJStartLunchItem *)item timeout:(NSTimeInterval)timeout completion:(void (^)())completion;
@end
