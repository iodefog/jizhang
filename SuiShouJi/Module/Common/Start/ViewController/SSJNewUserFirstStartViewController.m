//
//  SSJNewUserStartViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewUserFirstStartViewController.h"

@interface SSJNewUserFirstStartViewController ()

@property (nonatomic, strong) YYAnimatedImageView *gifImageView;

@property (nonatomic, strong) YYImage *gifImage;

@end

@implementation SSJNewUserFirstStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.gifImageView addObserver:self forKeyPath:@"currentIsPlayingAnimation" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.gifImageView];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewConstraints {
    [self.gifImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
    }];
    
    [super updateViewConstraints];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!self.gifImageView.currentIsPlayingAnimation && self.gifImageView.currentAnimatedImageIndex == self.gifImage.animatedImageFrameCount) {
        
    }
}

#pragma mark - Getter
- (YYAnimatedImageView *)gifImageView {
    if (!_gifImageView) {
        _gifImageView = [[YYAnimatedImageView alloc] initWithImage:self.gifImage];
    }
    return _gifImageView;
}

- (YYImage *)gifImage {
    if (!_gifImage) {
        _gifImage = [YYImage imageNamed:@"newuserguide1.gif"];
    }
    return _gifImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
