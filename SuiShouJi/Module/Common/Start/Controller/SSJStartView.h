//
//  SSJStartView.h
//  SuiShouJi
//
//  Created by old lang on 16/3/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SSJStartViewDisplayPhase) {
    SSJStartViewDisplayPhaseDefault,
    SSJStartViewDisplayPhaseServer,
    SSJStartViewDisplayPhaseTree
};

@interface SSJStartView : UIView

@property (nonatomic, readonly) SSJStartViewDisplayPhase displayPhase;

- (void)showServerImageWithUrl:(NSURL *)url duration:(NSTimeInterval)duration finish:(void (^)())finish;

- (void)showTreeImage:(UIImage *)image duration:(NSTimeInterval)duration finish:(void (^)())finish;

@end
