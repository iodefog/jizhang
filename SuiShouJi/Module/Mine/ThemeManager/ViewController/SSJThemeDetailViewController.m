//
//  SSJThemeDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeDetailViewController.h"
#import "SSJDownLoadProgressButton.h"

@interface SSJThemeDetailViewController ()
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIImageView *themeIcon;
@property(nonatomic, strong) UILabel *themeTitleLabel;
@property(nonatomic, strong) UILabel *themeSizeLabel;
@property(nonatomic, strong) UILabel *themePriceLabel;
@property(nonatomic, strong) SSJDownLoadProgressButton *themeDownLoadButton;
@property(nonatomic, strong) UIView *seperatorLine;
@property(nonatomic, strong) UILabel *themeDescLabel;
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation SSJThemeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.themeIcon];
    [self.scrollView addSubview:self.themeTitleLabel];
    [self.scrollView addSubview:self.themeSizeLabel];
    [self.scrollView addSubview:self.themePriceLabel];
    [self.scrollView addSubview:self.themeDownLoadButton];
    [self.scrollView addSubview:self.seperatorLine];
    [self.scrollView addSubview:self.themeDescLabel];
    [self.scrollView addSubview:self.collectionView];
    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.scrollView.leftTop = CGPointMake(0, 10);
    self.themeIcon.leftTop = CGPointMake(20, 20);
    self.themeTitleLabel.leftTop = CGPointMake(self.themeIcon.right + 16, self.themeIcon.top + 10);
    self.themeSizeLabel.leftTop = CGPointMake(self.themeIcon.right + 16, self.themeTitleLabel.bottom + 12);
    self.themePriceLabel.leftBottom = CGPointMake(self.themeIcon.right + 16, self.themeIcon.bottom - 10);
    self.themeDownLoadButton.top = self.themeIcon.bottom + 20;
    self.themeDownLoadButton.centerX = self.view.width / 2;
    self.seperatorLine.leftTop = CGPointMake(0, self.themeDownLoadButton.bottom + 20);
    self.themeDescLabel.leftTop = CGPointMake(20, self.seperatorLine.bottom + 20);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 5)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

-(UIImageView *)themeIcon{
    if (!_themeIcon) {
        _themeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        _themeIcon.layer.cornerRadius = 4.f;
        _themeIcon.layer.masksToBounds = YES;
        _themeIcon.image = [UIImage imageNamed:self.item.themeThumbImageUrl];
    }
    return _themeIcon;
}

-(UILabel *)themeTitleLabel{
    if (!_themeTitleLabel) {
        _themeTitleLabel = [[UILabel alloc]init];
        _themeTitleLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        _themeTitleLabel.font = [UIFont systemFontOfSize:18];
        _themeTitleLabel.text = self.item.themeTitle;
        [_themeTitleLabel sizeToFit];
    }
    return _themeTitleLabel;
}

-(UILabel *)themeSizeLabel{
    if (!_themeSizeLabel) {
        _themeSizeLabel = [[UILabel alloc]init];
        _themeSizeLabel.textColor = [UIColor ssj_colorWithHex:@"#929292"];
        _themeSizeLabel.font = [UIFont systemFontOfSize:15];
        _themeSizeLabel.text = self.item.themeSize;
        [_themeSizeLabel sizeToFit];
    }
    return _themeSizeLabel;
}

-(UILabel *)themePriceLabel{
    if (!_themePriceLabel) {
        _themePriceLabel = [[UILabel alloc]init];
        _themePriceLabel.textColor = [UIColor ssj_colorWithHex:@"#eb4a64"];
        _themePriceLabel.font = [UIFont systemFontOfSize:15];
        _themePriceLabel.text = @"免费";
        [_themePriceLabel sizeToFit];
    }
    return _themePriceLabel;
}

-(SSJDownLoadProgressButton *)themeDownLoadButton{
    if (!_themeDownLoadButton) {
        _themeDownLoadButton = [[SSJDownLoadProgressButton alloc]initWithFrame:CGRectMake(0, 0, self.view.width - 56, 45)];
        _themeDownLoadButton.maskColor = @"#eb4a64";
        [_themeDownLoadButton setTitle:@"下载" forState:UIControlStateNormal];
        [_themeDownLoadButton setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:UIControlStateNormal];
        _themeDownLoadButton.layer.cornerRadius = 2.f;
        _themeDownLoadButton.layer.borderWidth = 1.f;
        _themeDownLoadButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#eb4a64"].CGColor;
    }
    return _themeDownLoadButton;
}

-(UIView *)seperatorLine{
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 1 / [UIScreen mainScreen].scale)];
        _seperatorLine.backgroundColor = SSJ_DEFAULT_SEPARATOR_COLOR;
    }
    return _seperatorLine;
}

-(UILabel *)themeDescLabel{
    if (!_themeDescLabel) {
        _themeDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 56)];
        _themeDescLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        _themeDescLabel.font = [UIFont systemFontOfSize:15];
        _themeDescLabel.text = self.item.themeDesc;
        [_themeDescLabel sizeToFit];
    }
    return _themeDescLabel;
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
