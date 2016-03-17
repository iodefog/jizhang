//
//  SSJStartView.h
//  SuiShouJi
//
//  Created by old lang on 16/3/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJStartView : UIView

- (void)showWithUrl:(NSURL *)url duration:(NSTimeInterval)duration finish:(void (^)())finish;

@end
