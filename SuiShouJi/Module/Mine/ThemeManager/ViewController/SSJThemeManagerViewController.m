//
//  SSJThemeManagerViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/7/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeManagerViewController.h"
#import "SSJThemeManagerCollectionViewCell.h"

static NSString *const kCellId = @"SSJThemeManagerCollectionViewCell";

@interface SSJThemeManagerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *themeSelectView;

@property(nonatomic, strong) UICollectionViewFlowLayout *layout;

@property(nonatomic, strong) NSMutableArray *items;

@property(nonatomic, strong) UIButton *rightButton;
@end

@implementation SSJThemeManagerViewController{
    BOOL editeModel;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"已下载皮肤";
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    editeModel = NO;
    [self.view addSubview:self.themeSelectView];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getAllThemes];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJThemeModel *item = [self.items ssj_safeObjectAtIndex:indexPath.item];
    SSJThemeManagerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    cell.deleteThemeBlock = ^(){
        [weakSelf getAllThemes];
    };
    if ([item.ID isEqualToString:SSJCurrentThemeID()]) {
        cell.inUse = YES;
    }else{
        cell.inUse = NO;
    }
    if ([item.ID isEqualToString:SSJDefaultThemeID]) {
        cell.canEdite = NO;
    }else{
        cell.canEdite = YES;
    }
    cell.editeModel = editeModel;
    cell.item = item;
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float cellWidth = (self.view.width - 45) / 3;
    float imageRatio = 220.f / 358;
    float imageHeight = cellWidth / imageRatio;
    float cellHeight = imageHeight + 40;
    return CGSizeMake(cellWidth, cellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(27 - SSJ_NAVIBAR_BOTTOM, 10, 0, 10);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.width, 50);
}

#pragma mark - Event
-(void)rightButtonClicked:(id)sender{
    editeModel = !editeModel;
    self.rightButton.selected = !self.rightButton.isSelected;
    [self.themeSelectView reloadData];
}

#pragma mark - Getter
- (UICollectionViewFlowLayout *)layout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 25;
    layout.minimumInteritemSpacing = 12;
    return layout;
}

- (UICollectionView *)themeSelectView {
    if (!_themeSelectView) {
        _themeSelectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10 + SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height) collectionViewLayout:self.layout];
        _themeSelectView.delegate = self;
        _themeSelectView.dataSource = self;
        _themeSelectView.alwaysBounceVertical = YES;
        _themeSelectView.showsHorizontalScrollIndicator = NO;
        _themeSelectView.showsVerticalScrollIndicator = NO;
        _themeSelectView.backgroundColor = [UIColor whiteColor];
        _themeSelectView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
        [_themeSelectView registerClass:[SSJThemeManagerCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
    }
    return _themeSelectView;
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
        [_rightButton setTitleColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].naviBarTintColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].naviBarTintColor] forState:UIControlStateSelected];
        _rightButton.contentHorizontalAlignment = NSTextAlignmentRight;
        [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_rightButton setTitle:@"完成" forState:UIControlStateSelected];
        [_rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.selected = NO;
    }
    return _rightButton;
}

#pragma mark - Private
-(void)getAllThemes{
    self.items = [NSMutableArray arrayWithArray:[SSJThemeSetting allThemeModels]];
    [self.items removeObjectAtIndex:0];
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
