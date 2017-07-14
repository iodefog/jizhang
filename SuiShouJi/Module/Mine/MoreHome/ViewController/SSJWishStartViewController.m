//
//  SSJWishStartViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishStartViewController.h"

@interface SSJWishStartViewController ()

@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation SSJWishStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"为心愿存钱";
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"login_bg"];
    }
}


#pragma mark - Lazy
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"过往再美\n未来也是要靠智慧和钱生活的\n\n在这里，和一百万人一起\n为心愿存钱，一步步实现自己的小心愿";
    }
    return _tipLabel;
}
@end
