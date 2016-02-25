//
//  SSJImaageBrowseViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJImaageBrowseViewController.h"

@interface SSJImaageBrowseViewController ()
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIButton *changeImageButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIButton *comfirmButton;
@property (nonatomic,strong) UIView *bottomBackGroundView;
@property (nonatomic,strong) UIImageView *imageBrowser;
@end

@implementation SSJImaageBrowseViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imageBrowser];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.bottomBackGroundView];
    [self.view addSubview:self.comfirmButton];
    [self.view addSubview:self.deleteButton];
    [self.view addSubview:self.changeImageButton];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.imageBrowser.frame = self.view.frame;
    self.backButton.size = CGSizeMake(30, 30);
    self.backButton.leftTop = CGPointMake(10, 10);
    self.bottomBackGroundView.size = CGSizeMake(self.view.width, 100);
    self.bottomBackGroundView.bottom = self.view.height;
    self.comfirmButton.size = CGSizeMake(30, 30);
    self.comfirmButton.center = self.bottomBackGroundView.center;
    self.changeImageButton.size = CGSizeMake(40, 40);
    self.changeImageButton.rightTop = CGPointMake(self.comfirmButton.left - 40, self.bottomBackGroundView.top + 10);
    self.deleteButton.size = CGSizeMake(40, 40);
    self.deleteButton.leftTop = CGPointMake(self.comfirmButton.right + 40, self.bottomBackGroundView.top + 10);
}

#pragma mark - Getter
-(UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc]init];
        [_backButton setTitle:@"<" forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton ssj_setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];

    }
    return _backButton;
}

-(UIButton *)changeImageButton{
    if (!_changeImageButton) {
        _changeImageButton = [[UIButton alloc]init];
        _changeImageButton.contentLayoutType = SSJButtonLayoutTypeImageTopTitleBottom;
        [_changeImageButton setTitle:@"替换" forState:UIControlStateNormal];
        [_changeImageButton ssj_setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];

    }
    return _changeImageButton;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        _deleteButton.contentLayoutType = SSJButtonLayoutTypeImageTopTitleBottom;
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton ssj_setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

-(UIButton *)comfirmButton{
    if (!_comfirmButton) {
        _comfirmButton = [[UIButton alloc]init];
        [_comfirmButton setTitle:@"OK" forState:UIControlStateNormal];
        [_comfirmButton ssj_setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];

    }
    return _comfirmButton;
}

-(UIView *)bottomBackGroundView{
    if (!_bottomBackGroundView) {
        _bottomBackGroundView = [[UIView alloc]init];
        _bottomBackGroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _bottomBackGroundView;
}

-(UIImageView *)imageBrowser{
    if (!_imageBrowser) {
        _imageBrowser = [[UIImageView alloc]init];
    }
    return _imageBrowser;
}

-(void)backButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

#pragma mark - Setter
-(void)setImage:(UIImage *)image{
    _image = image;
    self.imageBrowser.image = image;
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
