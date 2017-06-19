//
//  SSJImageViewAddition.m
//  SuiShouJi
//
//  Created by old lang on 17/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJImageViewAddition.h"
#import "SSJImageAddition.h"
#import "SSJViewAddition.h"

@implementation UIImageView (SSJCategory)

- (void)ssj_loadImageWithUrl:(NSURL *)url {
    [self ssj_loadImageWithUrl:url completion:NULL];
}

- (void)ssj_loadImageWithUrl:(NSURL *)url completion:(void(^)(NSError *error))completion {
    [self ssj_showLoadingIndicator];
    [UIImage ssj_loadUrl:url compeltion:^(NSError *error, UIImage *image) {
        [self ssj_hideLoadingIndicator];
        if (!error) {
            self.image = image;
        }
        if (completion) {
            completion(error);
        }
    }];
}

@end
