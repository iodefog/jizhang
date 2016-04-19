//
//  SSJBookkeepingTreeView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJBookkeepingTreeCheckInModel;

@interface SSJBookkeepingTreeView : UIView

- (void)setTreeImg:(UIImage *)treeImg;

- (void)setCheckTimes:(NSInteger)checkTimes;

- (void)startRainWithGifData:(NSData *)data completion:(void (^)())completion;

@end
