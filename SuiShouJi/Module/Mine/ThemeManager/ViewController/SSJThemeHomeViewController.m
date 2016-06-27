//
//  SSJThemeHomeViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeHomeViewController.h"
#import "SSJNetworkReachabilityManager.h"

@interface SSJThemeHomeViewController ()
@property(nonatomic, strong) UILabel *hintLabel;
@property(nonatomic, strong) UICollectionView *themeSelectView;
@end

@implementation SSJThemeHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"主题皮肤";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkNetwork];
    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    [self.view addSubview:self.hintLabel];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.hintLabel.width = self.view.width;
    self.hintLabel.height = 32;
    self.hintLabel.leftTop = CGPointMake(0, 10);
}

#pragma mark - Private
-(void)checkNetwork{
    if ([SSJNetworkReachabilityManager isReachable]) {
        NSLog(@"yes");
    }else{
        NSLog(@"no");
    };
}

#pragma mark - Getter
-(UILabel *)hintLabel{
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc]init];
        _hintLabel.textAlignment = NSTextAlignmentLeft;
        _hintLabel.backgroundColor = [UIColor whiteColor];
        _hintLabel.text = @"  温馨提示，换肤请在WiFi环境下进行，否则会较消耗流量哦。";
        _hintLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _hintLabel.font = [UIFont systemFontOfSize:14];
    }
    return _hintLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
