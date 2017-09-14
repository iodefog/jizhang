//
//  SSJNewUserGifGuideView.h
//  SuiShouJi
//
//  Created by ricky on 2017/9/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJAnimatedGuideViewProtocol.h"

@interface SSJNewUserGifGuideView : UIView<SSJAnimatedGuideViewProtocol>

- (instancetype)initWithFrame:(CGRect)frame
                WithImageName:(NSString *)imageName
                        title:(NSString *)title
                     subTitle:(NSString *)subTitle;

@end
