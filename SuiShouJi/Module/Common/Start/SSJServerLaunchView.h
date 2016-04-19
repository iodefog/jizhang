//
//  SSJServerLaunchView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJServerLaunchView : UIView

@property (nonatomic, readonly) BOOL isCompleted;

- (void)downloadImgWithUrl:(NSString *)imgUrl completion:(void (^)())completion;

- (void)downloadImgWithUrl:(NSString *)imgUrl timeout:(NSTimeInterval)timeout completion:(void (^)())completion;

@end
