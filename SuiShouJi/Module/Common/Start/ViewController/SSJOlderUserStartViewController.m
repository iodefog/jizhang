//
//  SSJOlderUserStartViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJOlderUserStartViewController.h"
#import "SSJNewUserGifGuideView.h"

@interface SSJOlderUserStartViewController ()

@property (nonatomic, strong) SSJNewUserGifGuideView *guideView;

@end

@implementation SSJOlderUserStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.guideView];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.guideView.frame = self.view.bounds;
}

- (SSJNewUserGifGuideView *)guideView {
    if (!_guideView) {
        _guideView = [[SSJNewUserGifGuideView alloc] initWithFrame:CGRectZero WithImageName:@"" title:@"老司机记账数据丢不得!" subTitle:@"导入记账老数据,换app更舒心"];
    }
    return _guideView;
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
