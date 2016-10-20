//
//  SSJMineSyncButton.h
//  SuiShouJi
//
//  Created by ricky on 16/5/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMineSyncButton : UIView

@property (nonatomic, copy) BOOL (^shouldSyncBlock)();

- (void)updateAfterThemeChange;

@end
