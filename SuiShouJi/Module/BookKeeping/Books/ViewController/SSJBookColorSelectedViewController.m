//
//  SSJBookColorSelectedViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBookColorSelectedViewController.h"
#import "SSJFinancingGradientColorItem.h"
#import "SSJBookColorSelectedCollectionViewCell.h"

static NSString *SSJBookColorSelectedCollectionViewCellId = @"SSJBookColorSelectedCollectionViewCell";
@interface SSJBookColorSelectedViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<SSJFinancingGradientColorItem *> *colorArray;

@property (nonatomic,strong) UILabel *bookNameLabel;

/**<#注释#>*/
@property (nonatomic, strong) SSJBookColorSelectedCollectionViewCell  *lastSelectedCell;

/**<#注释#>*/
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation SSJBookColorSelectedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    [self.view addSubview:self.collectionView];
    [self headView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM);
    self.bookNameLabel.top = self.gradientLayer.top;
    self.bookNameLabel.right = self.gradientLayer.right - 10;
    self.bookNameLabel.width = 15;
    self.bookNameLabel.height = self.gradientLayer.height;
}

#pragma mark - UI
- (void)setUpNav {
    self.title = NSLocalizedString(@"编辑卡片颜色", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
}

- (void)headView {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, SSJSCREENWITH, 170)];
    headView.backgroundColor = [UIColor clearColor];
    [headView.layer addSublayer:self.gradientLayer];
    [headView addSubview:self.bookNameLabel];
    [self.view addSubview:headView];
}

- (void)setBookName:(NSString *)bookName {
    _bookName = bookName;
    self.bookNameLabel.text = bookName;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.colorArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJBookColorSelectedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJBookColorSelectedCollectionViewCellId forIndexPath:indexPath];
    if ([self.bookColorItem isEqual:self.colorArray[indexPath.row]]) {
        cell.colorSelected = YES;
        self.selectedIndex = indexPath.row;
        self.lastSelectedCell = cell;
    } else {
        cell.colorSelected = NO;
    }
    cell.itemColor = self.colorArray[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndex = indexPath.row;
    SSJFinancingGradientColorItem *item = [self.colorArray ssj_safeObjectAtIndex:indexPath.row];
    if (!item) return;
    SSJBookColorSelectedCollectionViewCell *currentCell = (SSJBookColorSelectedCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.lastSelectedCell.colorSelected = NO;
    currentCell.colorSelected = YES;
    self.lastSelectedCell = currentCell;
    [UIView animateWithDuration:0.25 animations:^{
        self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:item.endColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:item.startColor].CGColor];
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

#pragma mark - Event
- (void)rightButtonClicked:(UIButton *)btn {
    if (self.colorSelectedBlock) {
        SSJFinancingGradientColorItem *selectColor = [self.colorArray ssj_safeObjectAtIndex:self.selectedIndex];
        self.colorSelectedBlock(selectColor);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Lazy
-(UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 22;
        flowLayout.minimumLineSpacing = 18;
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.contentInset = UIEdgeInsetsMake(170, 0, 0, 0);
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SSJBookColorSelectedCollectionViewCell class] forCellWithReuseIdentifier:SSJBookColorSelectedCollectionViewCellId];
    }
    return _collectionView;
}

- (UILabel *)bookNameLabel {
    if (!_bookNameLabel) {
        _bookNameLabel = [[UILabel alloc] init];
        _bookNameLabel.text = NSLocalizedString(@"账本名称", nil);
        _bookNameLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _bookNameLabel.textColor = [UIColor whiteColor];
        _bookNameLabel.numberOfLines = 0;
    }
    return _bookNameLabel;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        CGRect itemRect = CGRectMake((SSJSCREENWITH - 80) * 0.5, 25, 80, 110);
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = itemRect;
        CAShapeLayer *sharpLayer = [CAShapeLayer layer];
        sharpLayer.path = [UIBezierPath bezierPathWithRoundedRect:_gradientLayer.bounds cornerRadius:10].CGPath;
        _gradientLayer.mask = sharpLayer;
        _gradientLayer.colors = _gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:self.bookColorItem.endColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:self.bookColorItem.startColor].CGColor];
    }
    return _gradientLayer;
}

- (NSArray<SSJFinancingGradientColorItem *> *)colorArray {
    return [SSJFinancingGradientColorItem defualtColors];
}

@end
