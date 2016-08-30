//
//  SSJColorSelectViewControllerViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJColorSelectViewController.h"
#import "SSJColorSelectCollectionViewCell.h"

@interface SSJColorSelectViewController ()
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *amountLabel;
@property (nonatomic,strong) UIView *rightbuttonView;

@end

@implementation SSJColorSelectViewController{
    NSArray *_colorArray;
    NSString *_selectColor;
}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"选择颜色";
        _colorArray = @[@"#fc7a60",@"#b1c23e",@"#25b4dd",@"#5a98de",@"#8bb84a",@"#a883db",@"#20cac0",@"#faa94a",@"#ef6161",@"#f16189",@"#ba2e8b",@"#3260b5",@"#d96421",@"#ba4747",@"#bda337"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.fundingColor || self.fundingColor.length == 0) {
        _selectColor = _colorArray[0];
    }else{
        _selectColor = self.fundingColor;
    }
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.collectionView];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(comfirmButtonClick:)];
    self.navigationItem.rightBarButtonItem  = rightBarButton;
    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews{
    _headerView.top = SSJ_NAVIBAR_BOTTOM + 10;
    _headerView.size = CGSizeMake(self.view.width, 63);
    _nameLabel.left = 10;
    _nameLabel.centerY = self.headerView.height / 2;
    _amountLabel.right = self.headerView.width - 10;
    _amountLabel.centerY = self.headerView.height / 2;
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
    SSJColorSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorSelectCollectionViewCell" forIndexPath:indexPath];
    cell.itemColor = _colorArray[indexPath.row];
    if ([cell.itemColor isEqualToString:_selectColor]) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJColorSelectCollectionViewCell *cell = (SSJColorSelectCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    _selectColor = cell.itemColor;
    [UIView animateWithDuration:0.25 animations:^{
        self.headerView.backgroundColor = [UIColor ssj_colorWithHex:_selectColor];
    }];
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (self.view.width - 120) / 5;
    return CGSizeMake(itemWidth, itemWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - Getter
-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 25;
        flowLayout.minimumLineSpacing = 25;
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJColorSelectCollectionViewCell class]  forCellWithReuseIdentifier:@"ColorSelectCollectionViewCell"];
    }
    return _collectionView;
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
        _headerView.backgroundColor = [UIColor ssj_colorWithHex:_selectColor];
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.text = self.fundingName;
        _nameLabel.font = [UIFont systemFontOfSize:18];
        _nameLabel.textColor = [UIColor whiteColor];
        [_nameLabel sizeToFit];
        _amountLabel = [[UILabel alloc]init];
        _amountLabel.font = [UIFont systemFontOfSize:18];
        _amountLabel.textColor = [UIColor whiteColor];
        _amountLabel.text = [NSString stringWithFormat:@"%.2f",self.fundingAmount];
        [_amountLabel sizeToFit];
        [_headerView addSubview:_nameLabel];
        [_headerView addSubview:_amountLabel];
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
