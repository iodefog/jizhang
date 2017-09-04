//
//  SSJColorSelectViewControllerViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJColorSelectViewController.h"
#import "SSJGradientColorSelectCollectionViewCell.h"
#import "SSJFinancingColorSelectHeader.h"


@interface SSJColorSelectViewController ()

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) SSJFinancingColorSelectHeader *headerView;

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UILabel *amountLabel;

@property (nonatomic,strong) UIView *rightbuttonView;

@end

@implementation SSJColorSelectViewController{
    NSArray *_colorArray;
    SSJFinancingGradientColorItem *_selectColor;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"编辑卡片颜色";
        _colorArray = [SSJFinancingGradientColorItem defualtColors];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.fundingItem) {
        _selectColor = _colorArray[0];
    }else{
        _selectColor = [SSJFinancingGradientColorItem gradientColorWithStartColor:self.fundingItem.startColor EndColor:self.fundingItem.endColor];
    }
    for (SSJFinancingGradientColorItem *item in _colorArray) {
        if ([_selectColor isEqual:item]) {
            item.isSelected = YES;
        } else {
            item.isSelected = NO;
        }
    }
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.collectionView];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(comfirmButtonClick:)];
    self.navigationItem.rightBarButtonItem  = rightBarButton;
    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews{
    _headerView.top = SSJ_NAVIBAR_BOTTOM;
    _headerView.size = CGSizeMake(self.view.width, 110);
    self.collectionView.frame = CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.bottom);
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _colorArray.count;
}

- (NSInteger)numberOfSections{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJGradientColorSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorSelectCollectionViewCell" forIndexPath:indexPath];
    cell.itemColor = _colorArray[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJGradientColorSelectCollectionViewCell *cell = (SSJGradientColorSelectCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    _selectColor = cell.itemColor;
    for (SSJFinancingGradientColorItem *item in _colorArray) {
        NSInteger index = [_colorArray indexOfObject:item];
        if (index == indexPath.item) {
            item.isSelected = YES;
        } else {
            item.isSelected = NO;
        }
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.headerView.item = _selectColor;
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (self.view.width - 96) / 4;
    return CGSizeMake(itemWidth, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 15, 10, 15);
}

#pragma mark - Getter
-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 22;
        flowLayout.minimumLineSpacing = 18;
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJGradientColorSelectCollectionViewCell class]  forCellWithReuseIdentifier:@"ColorSelectCollectionViewCell"];
    }
    return _collectionView;
}

-(SSJFinancingColorSelectHeader *)headerView{
    if (!_headerView) {
        _headerView = [[SSJFinancingColorSelectHeader alloc]init];
//        _headerView.backgroundColor = [UIColor ssj_colorWithHex:_selectColor];
        _headerView.fundName = self.fundingItem.fundingName;
        _headerView.fundBalance = [NSString stringWithFormat:@"%.2f",self.fundingItem.fundingAmount];
        _headerView.item = _selectColor;
    }
    return _headerView;
}

#pragma mark - Private
-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

-(void)comfirmButtonClick:(id)sender{
    if (self.colorSelectedBlock) {
        self.colorSelectedBlock(_selectColor);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateAppearanceAfterThemeChanged {
    _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];

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
