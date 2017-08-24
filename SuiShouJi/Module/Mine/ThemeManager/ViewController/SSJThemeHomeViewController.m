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
#import "SSJThemeDetailViewController.h"
#import "SSJThemeService.h"
#import "MMDrawerController.h"
#import "SSJThemeManagerViewController.h"
#import "SSJBookKeepingHomeViewController.h"

@interface SSJThemeHomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) UILabel *hintLabel;
@property(nonatomic, strong) UICollectionView *themeSelectView;
@property(nonatomic, strong) UICollectionViewFlowLayout *layout;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) SSJThemeService *service;
@end

static NSString *const kCellId = @"SSJThemeHomeCollectionViewCell";

static NSString *const kHeaderId = @"SSJThemeCollectionHeaderView";

@implementation SSJThemeHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"主题皮肤";
        self.hidesBottomBarWhenPushed = YES;
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
//    [self.view addSubview:self.hintLabel];
    [self.view addSubview:self.themeSelectView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkNetwork];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"管理" style:UIBarButtonItemStylePlain target:self action:@selector(managerButtonClicked:)];
    if ([SSJThemeSetting allThemeModels].count - 1) {
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.themeSelectView.size = CGSizeMake(self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM);
    self.themeSelectView.leftTop = CGPointMake(0, SSJ_NAVIBAR_BOTTOM);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.service cancel];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJThemeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.item];
    SSJThemeHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    cell.themeChangeBlock = ^(){
        UITabBarController *tabVC = (UITabBarController *)((MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController).centerViewController;
        tabVC.selectedIndex = 0;
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    };
    cell.item = item;
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJThemeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.item];
    return CGSizeMake((self.view.width - 45) / 3, item.cellHeight);
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJThemeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.item];
    if ([item.themeId isEqualToString:@"-1"]) {
        UITabBarController *tabVC = (UITabBarController *)((MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController).centerViewController;
        UINavigationController *firstNav = [tabVC.viewControllers objectAtIndex:0];
        SSJBookKeepingHomeViewController *homeVc = [firstNav.viewControllers objectAtIndex:0];
        homeVc.needEditeThemeModel = YES;
        tabVC.selectedIndex = 0;
        [SSJAnaliyticsManager event:@"more_define_bg"];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        SSJThemeDetailViewController *themeDetailVc = [[SSJThemeDetailViewController alloc]init];
        themeDetailVc.item = item;
        [self.navigationController pushViewController:themeDetailVc animated:YES];

    }
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service{
    if ([service.returnCode isEqualToString:@"1"]) {
        [self getThemeStatusForThemes:self.service.themes];
    }else{
        [self getThemeFromLocal];
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error{
    [self getThemeFromLocal];

}

#pragma mark - Getter
-(UILabel *)hintLabel{
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc]init];
        _hintLabel.textAlignment = NSTextAlignmentLeft;
        _hintLabel.backgroundColor = [UIColor whiteColor];
        _hintLabel.text = @"  温馨提示，换肤请在WiFi环境下进行，否则会较消耗流量哦。";
        _hintLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _hintLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
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
        _themeSelectView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
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

-(SSJThemeService *)service{
    if (!_service) {
        _service = [[SSJThemeService alloc]initWithDelegate:self];
    }
    return _service;
}

#pragma mark - Event
- (void)managerButtonClicked:(id)sender{
    SSJThemeManagerViewController *managerVc = [[SSJThemeManagerViewController alloc]init];
    [self.navigationController pushViewController:managerVc animated:YES];
}

#pragma mark - Private
-(void)getThemeFromLocal{
    NSArray *themes = [SSJThemeSetting allThemeModels];
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (SSJThemeModel *model in themes) {
        SSJThemeItem *item = [[SSJThemeItem alloc]init];
        item.themeId = model.ID;
        item.themeTitle = model.name;
        item.themeImageUrl = model.previewUrlStr;
        item.themeThumbImageUrl = model.thumbUrlStr;
        item.themeSize = model.size;
        item.images = model.previewUrlArr;
        item.themeDesc = model.desc;
        float imageRatio = 220.f / 358;
        float imageHeight = (SSJSCREENWITH - 45) / 3 / imageRatio;
        item.cellHeight = imageHeight + 25 + [item.themeTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]}].height + 26;
        [tempArr addObject:item];
        SSJThemeItem *itemCustom = [[SSJThemeItem alloc]init];
        itemCustom.themeId = @"-1";
        itemCustom.themeTitle = @"自定义背景";
        if (![tempArr containsObject:itemCustom]) {
            [tempArr insertObject:itemCustom atIndex:0];
        }
    }
    [self getThemeStatusForThemes:tempArr];
}

-(void)checkNetwork{
    //检测网络状态
    if ([SSJNetworkReachabilityManager isReachable]) {
        [self.service requestThemeList];
    }else{
        [self getThemeFromLocal];
    };
    
}

-(void)getThemeStatusForThemes:(NSArray *)themes{
    //获取主题的状态
    for (SSJThemeItem *theme in themes) {
        if ([theme.themeId isEqualToString:@"0"]) {
            if ([theme.themeId isEqualToString:[SSJThemeSetting currentThemeModel].ID]) {
                theme.themeStatus = themeStatusInuse;
            }else {
                theme.themeStatus = themeStatusHaveDownloaded;
            }
        }else{
            if ([theme.themeId isEqualToString:[SSJThemeSetting currentThemeModel].ID]) {
                theme.themeStatus = themeStatusInuse;
            }else if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:theme.themeId]]) {
                if ([[SSJThemeSetting ThemeModelForModelId:theme.themeId].version integerValue] < [theme.version integerValue]) {
                    theme.themeStatus = themeStatusNeedToUpdate;
                    
                }else{
                    theme.themeStatus = themeStatusHaveDownloaded;
                }
            }else{
                theme.themeStatus = themeStatusNotDownloaded;
            }
        }
        //获取主题是否正在下载
        if ([[SSJThemeDownLoaderManger sharedInstance].downLoadingArr containsObject:theme.themeId]) {
            theme.isDownLoading = YES;
        }else{
            theme.isDownLoading = NO;
        }
        
        //计算每个cell的高度
        float imageRatio = 220.f / 358;
        float imageHeight = (SSJSCREENWITH - 45) / 3 / imageRatio;
        theme.cellHeight = imageHeight + 25 + [theme.themeTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]}].height + 26;
    }
    self.items = themes;
    [self.themeSelectView reloadData];
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
