//
//  SSJImageViewAddition.h
//  SuiShouJi
//
//  Created by old lang on 17/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (SSJCategory)

- (void)ssj_loadImageWithUrl:(NSURL *)url;

- (void)ssj_loadImageWithUrl:(NSURL *)url completion:(void(^)(NSError *error))completion;

@end
