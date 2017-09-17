//
//  SSJThemeGuideView.h
//  SuiShouJi
//
//  Created by ricky on 2017/9/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJAnimatedGuideViewProtocol.h"
#import "SSJThemeItem.h"

@interface SSJThemeGuideView : UIView<SSJAnimatedGuideViewProtocol>

@property (nonatomic, strong) NSArray <SSJThemeItem *> *themeItems;

@end
