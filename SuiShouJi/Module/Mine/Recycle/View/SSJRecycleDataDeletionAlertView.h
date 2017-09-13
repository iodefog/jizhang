//
//  SSJRecycleDataDeletionAlertView.h
//  SuiShouJi
//
//  Created by old lang on 2017/9/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJRecycleDataDeletionAlertView : UIView

@property (nonatomic, copy) NSString *message;

+ (instancetype)alertView;

- (void)show;

- (void)dismiss;

@end
