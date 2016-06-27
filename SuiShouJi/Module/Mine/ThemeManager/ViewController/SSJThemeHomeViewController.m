//
//  SSJThemeHomeViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeHomeViewController.h"
#import "SSJNetworkReachabilityManager.h"
#import "SSJThemeHomeCollectionViewCell.h"
#import "SSJThemeCollectionHeaderView.h"

@interface SSJThemeHomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) UILabel *hintLabel;
@property(nonatomic, strong) UICollectionView *themeSelectView;
@property(nonatomic, strong) UICollectionViewFlowLayout *layout;
@end

static NSString *const kCellId = @"SSJThemeHomeCollectionViewCell";

static NSString *const kHeaderId = @"SSJThemeHomeCollectionViewCell";


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
    [self.view addSubview:self.themeSelectView];

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
    self.themeSelectView.size = CGSizeMake(self.view.width, self.view.height - self.hintLabel.bottom);
    self.themeSelectView.leftTop = CGPointMake(0, self.hintLabel.bottom);
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 5;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJThemeHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.width - 45) / 3, 245);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(17, 10, 0, 10);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.width, 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SSJThemeCollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId forIndexPath:indexPath];
    header.title = @"个性主题派";
    return header;
}

#pragma mark - Private
-(void)checkNetwork{
    //检测网络状态
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

- (UICollectionView *)themeSelectView {
    if (!_themeSelectView) {
        _themeSelectView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.layout];
        _themeSelectView.delegate = self;
        _themeSelectView.dataSource = self;
        _themeSelectView.alwaysBounceVertical = YES;
        _themeSelectView.showsHorizontalScrollIndicator = NO;
        _themeSelectView.showsVerticalScrollIndicator = NO;
        _themeSelectView.backgroundColor = [UIColor whiteColor];
        [_themeSelectView registerClass:[SSJThemeHomeCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        [_themeSelectView registerClass:[SSJThemeCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId];
    }
    return _themeSelectView;
}

- (UICollectionViewFlowLayout *)layout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 25;
    layout.minimumInteritemSpacing = 12;
    return layout;
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
