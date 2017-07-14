//
//  SSJWishStartViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishStartViewController.h"

@interface SSJWishStartViewController ()

@end

@implementation SSJWishStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"为心愿存钱";
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"login_bg"];
    }
}

@end
