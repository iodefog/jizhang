//
//  SSJScrollalbleAnnounceView.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJHeadLineItem.h"

@interface SSJScrollalbleAnnounceView : UIView

@property(nonatomic, strong) SSJHeadLineItem *item;

@property (nonatomic, copy) void (^headLineClickedBlock)(SSJHeadLineItem *item);

- (void)updateAppearanceAfterThemeChanged;

@end
