//
//  SSJAnimatedGuideViewProtocol.h
//  SuiShouJi
//
//  Created by ricky on 2017/9/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSJAnimatedGuideViewProtocol<NSObject>;

@required

- (void)startAnimating;

@property (nonatomic) BOOL isNormalState;

@end
