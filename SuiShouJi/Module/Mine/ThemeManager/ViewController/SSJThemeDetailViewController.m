//
//  SSJThemeDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeDetailViewController.h"
#import "SSJDownLoadProgressButton.h"
#import "SSJThemeImageCollectionViewCell.h"
#import "MMDrawerController.h"
#import "SSJThemeDownLoadCompleteService.h"
#import "SSJNetworkReachabilityManager.h"

@interface SSJThemeDetailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
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

static NSString *const kCellId = @"SSJThemeImageCollectionViewCell";


@implementation SSJThemeDetailViewController{
    NSArray *_images;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"主题详情";
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _images = @[@"defualtHome",@"defualtReport",@"defualtFund",@"defualtMine",@"defualtLogin"];
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
    self.scrollView.leftTop = CGPointMake(0, SSJ_NAVIBAR_BOTTOM + 10);
    self.themeIcon.leftTop = CGPointMake(20, 30);
    self.themeTitleLabel.leftTop = CGPointMake(self.themeIcon.right + 16, self.themeIcon.top + 10);
    self.themeSizeLabel.leftTop = CGPointMake(self.themeIcon.right + 16, self.themeTitleLabel.bottom + 12);
    self.themePriceLabel.leftBottom = CGPointMake(self.themeIcon.right + 16, self.themeIcon.bottom - 10);
    self.themeDownLoadButton.top = self.themeIcon.bottom + 20;
    self.themeDownLoadButton.centerX = self.view.width / 2;
    self.seperatorLine.leftTop = CGPointMake(0, self.themeDownLoadButton.bottom + 20);
    self.themeDescLabel.leftTop = CGPointMake(10, self.seperatorLine.bottom + 20);
    self.collectionView.leftTop = CGPointMake(0, self.themeDescLabel.bottom + 20);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[SSJThemeDownLoaderManger sharedInstance].downLoadingArr containsObject:self.item.themeId]) {
        __weak typeof(self) weakSelf = self;
        [self.themeDownLoadButton.button setTitle:@"" forState:UIControlStateNormal];
        [[SSJThemeDownLoaderManger sharedInstance] addProgressHandler:^(float progress) {
            weakSelf.themeDownLoadButton.downloadProgress = progress;
        } forID:self.item.themeId];
    }else{
        [self updateThemeStatus];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([self.item.themeId isEqualToString:@"0"]) {
        return _images.count;
    }
    return self.item.images.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJThemeImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    if ([self.item.themeId isEqualToString:@"0"]) {
        cell.imageName = [_images ssj_safeObjectAtIndex:indexPath.item];
    }else{
        cell.imageUrl = [self.item.images ssj_safeObjectAtIndex:indexPath.item][@"imgUrl"];
    }
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(150, 270);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

#pragma mark - Event
-(void)themeDownLoadButtonClicked:(id)sender{
    if([((UIButton *)sender).titleLabel.text isEqualToString:@"下载"] && ![[SSJThemeDownLoaderManger sharedInstance].downLoadingArr containsObject:self.item.themeId]) {
        if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusReachableViaWiFi) {
            [self downloadTheme];
        } else {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
            UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [((UIButton *)sender) setTitle:@"" forState:UIControlStateNormal];
                [self downloadTheme];
            }];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL message:[NSString stringWithFormat:@"您现在处于非WIFI网络状态，该皮肤将耗费%@流量，是否下载？",self.item.themeSize] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:cancelAction];
            [alert addAction:comfirmAction];
            [SSJVisibalController().navigationController presentViewController:alert animated:YES completion:NULL];
        }
    }else if ([((UIButton *)sender).titleLabel.text isEqualToString:@"启用"]){
        [SSJThemeSetting switchToThemeID:self.item.themeId];
        [SSJAnaliyticsManager event:@"open_skin" extra:self.item.themeTitle];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)downloadTheme {
    __weak typeof(self) weakSelf = self;
    [[SSJThemeDownLoaderManger sharedInstance] downloadThemeWithItem:self.item success:^(SSJThemeItem *item){
        [SSJThemeSetting switchToThemeID:weakSelf.item.themeId];
        [SSJAnaliyticsManager event:@"download_skin" extra:item.themeTitle];
        SSJThemeDownLoadCompleteService *downloadCompleteService = [[SSJThemeDownLoadCompleteService alloc]initWithDelegate:nil];
        [downloadCompleteService downloadCompleteThemeWithThemeId:item.themeId];
        [SSJAnaliyticsManager event:@"open_skin" extra:item.themeTitle];
        UITabBarController *tabVC = (UITabBarController *)((MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController).centerViewController;
        tabVC.selectedIndex = 0;
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"下载失败"];
        [weakSelf.themeDownLoadButton.button setTitle:@"下载" forState:UIControlStateNormal];
    }];
    [[SSJThemeDownLoaderManger sharedInstance] addProgressHandler:^(float progress) {
        if (progress == 1) {
            [weakSelf.themeDownLoadButton.button setTitle:@"启用" forState:UIControlStateNormal];
        }else{
            [weakSelf.themeDownLoadButton.button setTitle:@"" forState:UIControlStateNormal];
        }
        weakSelf.themeDownLoadButton.downloadProgress = progress;
    } forID:self.item.themeId];
}

#pragma mark - Getter
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.contentSize = CGSizeMake(self.view.width, 700);
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
        if ([self.item.themeId isEqualToString:@"0"]) {
            self.themeIcon.image = [UIImage imageNamed:@"defualtThumbImage"];
        }else{
            [_themeIcon sd_setImageWithURL:[NSURL URLWithString:self.item.themeThumbImageUrl] placeholderImage:[UIImage imageNamed:@"noneThumbImage"]];
        }
    }
    return _themeIcon;
}

-(UILabel *)themeTitleLabel{
    if (!_themeTitleLabel) {
        _themeTitleLabel = [[UILabel alloc]init];
        _themeTitleLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        _themeTitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _themeTitleLabel.text = self.item.themeTitle;
        [_themeTitleLabel sizeToFit];
    }
    return _themeTitleLabel;
}

-(UILabel *)themeSizeLabel{
    if (!_themeSizeLabel) {
        _themeSizeLabel = [[UILabel alloc]init];
        _themeSizeLabel.textColor = [UIColor ssj_colorWithHex:@"#929292"];
        _themeSizeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _themeSizeLabel.text = self.item.themeSize;
        [_themeSizeLabel sizeToFit];
    }
    return _themeSizeLabel;
}

-(UILabel *)themePriceLabel{
    if (!_themePriceLabel) {
        _themePriceLabel = [[UILabel alloc]init];
        _themePriceLabel.textColor = [UIColor ssj_colorWithHex:@"#EE4F4F"];
        _themePriceLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _themePriceLabel.text = @"免费";
        [_themePriceLabel sizeToFit];
    }
    return _themePriceLabel;
}

-(SSJDownLoadProgressButton *)themeDownLoadButton{
    if (!_themeDownLoadButton) {
        _themeDownLoadButton = [[SSJDownLoadProgressButton alloc]initWithFrame:CGRectMake(0, 0, self.view.width - 56, 45)];
        _themeDownLoadButton.maskColor = @"#EE4F4F";
        if (_item.themeStatus == 0) {
            [_themeDownLoadButton.button setTitle:@"下载" forState:UIControlStateNormal];
        }else if (_item.themeStatus == 1) {
            [_themeDownLoadButton.button setTitle:@"启用" forState:UIControlStateNormal];
        }else if (_item.themeStatus == 2) {
            [_themeDownLoadButton.button setTitle:@"使用中" forState:UIControlStateNormal];
        }
        [_themeDownLoadButton.button setTitleColor:[UIColor ssj_colorWithHex:@"#EE4F4F"] forState:UIControlStateNormal];
        [_themeDownLoadButton.button addTarget:self action:@selector(themeDownLoadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _themeDownLoadButton.layer.cornerRadius = 2.f;
        _themeDownLoadButton.layer.borderWidth = 1.f;
        _themeDownLoadButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#EE4F4F"].CGColor;
    }
    return _themeDownLoadButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 270) collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[SSJThemeImageCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.alwaysBounceVertical = NO;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    return layout;
}

-(UILabel *)themeDescLabel{
    if (!_themeDescLabel) {
        _themeDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width - 10, 56)];
        _themeDescLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        _themeDescLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _themeDescLabel.text = self.item.themeDesc;
        _themeDescLabel.numberOfLines = 0;
        [_themeDescLabel sizeToFit];
    }
    return _themeDescLabel;
}

-(UIView *)seperatorLine{
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 1 / [UIScreen mainScreen].scale)];
        _seperatorLine.backgroundColor = SSJ_DEFAULT_SEPARATOR_COLOR;
    }
    return _seperatorLine;
}

-(void)updateThemeStatus{
    
    //刷新主题的状态
    if ([self.item.themeId isEqualToString:@"0"]) {
        if ([self.item.themeId isEqualToString:[SSJThemeSetting currentThemeModel].ID]) {
            [self.themeDownLoadButton.button setTitle:@"使用中" forState:UIControlStateNormal];
            [self.themeDownLoadButton.button setTitleColor:[UIColor ssj_colorWithHex:@"#cccccc"] forState:UIControlStateNormal];
            self.themeDownLoadButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#cccccc"].CGColor;
            [self.themeDownLoadButton.button setTintColor:[UIColor ssj_colorWithHex:@"#a7a7a7"]];
        }else {
            [self.themeDownLoadButton.button setTitle:@"启用" forState:UIControlStateNormal];
            self.themeDownLoadButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#EE4F4F"].CGColor;
            [self.themeDownLoadButton.button setTintColor:[UIColor ssj_colorWithHex:@"#EE4F4F"]];
        }
    }else{
        if ([self.item.themeId isEqualToString:[SSJThemeSetting currentThemeModel].ID]) {
            [self.themeDownLoadButton.button setTitle:@"使用中" forState:UIControlStateNormal];
            [self.themeDownLoadButton.button setTitleColor:[UIColor ssj_colorWithHex:@"#cccccc"] forState:UIControlStateNormal];
            self.themeDownLoadButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#cccccc"].CGColor;
            [self.themeDownLoadButton.button setTintColor:[UIColor ssj_colorWithHex:@"#a7a7a7"]];
        }else if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:self.item.themeId]]) {
            [self.themeDownLoadButton.button setTitle:@"启用" forState:UIControlStateNormal];
            self.themeDownLoadButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#EE4F4F"].CGColor;
            [self.themeDownLoadButton.button setTintColor:[UIColor ssj_colorWithHex:@"#EE4F4F"]];
        }else{
            [self.themeDownLoadButton.button setTitle:@"下载" forState:UIControlStateNormal];
            self.themeDownLoadButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#EE4F4F"].CGColor;
            [self.themeDownLoadButton.button setTintColor:[UIColor ssj_colorWithHex:@"#EE4F4F"]];
        }
    }
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
