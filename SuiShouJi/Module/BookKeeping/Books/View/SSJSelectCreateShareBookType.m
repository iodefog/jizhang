//
//  SSJSelectCreateShareBookType.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSelectCreateShareBookType.h"
#import "SSJSelectCreateShareBookTypeCollectionViewCell.h"
static NSString * SSJSelectCreateShareBookTypeCellIdentifier = @"SSJSelectCreateShareBookType";

@interface SSJSelectCreateShareBookType ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) UILabel *subTitleLab;
@end

@implementation SSJSelectCreateShareBookType

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        [self addSubview:self.titleLab];
        [self addSubview:self.subTitleLab];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[SSJSelectCreateShareBookTypeCollectionViewCell class] forCellWithReuseIdentifier:SSJSelectCreateShareBookTypeCellIdentifier];
        [self appearance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appearance) name:SSJThemeDidChangeNotification object:nil];
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLab.centerX = self.width * 0.5;
    self.subTitleLab.centerX = self.width * 0.5;
    self.titleLab.top = 23;
    self.subTitleLab.top = CGRectGetMaxY(self.titleLab.frame) + 10;
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.subTitleLab.frame) + 10, self.width, self.height - (CGRectGetMaxY(self.subTitleLab.frame) + 10));
}



-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(280, 260);
}


#pragma mark - Action
- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.bottom = keyWindow.height;
    
    self.centerX = keyWindow.width / 2;
    
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.center = keyWindow.center;
    } timeInterval:0.25 fininshed:NULL];
    
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    [self.collectionView reloadData];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:NULL];
}


#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismiss];
    if (self.selectCreateShareBookBlock) {
        self.selectCreateShareBookBlock(indexPath.item);
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self titles].count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJSelectCreateShareBookTypeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJSelectCreateShareBookTypeCellIdentifier forIndexPath:indexPath];
    [cell setImage:[self.images ssj_safeObjectAtIndex:indexPath.item] title:[self.titles ssj_safeObjectAtIndex:indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.width - 80, 40);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 20, 5, 20);
}

#pragma mark - Lazy
-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 20;
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
    }
    return _collectionView;
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _titleLab.text = @"共享账本";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UILabel *)subTitleLab{
    if (!_subTitleLab) {
        _subTitleLab = [[UILabel alloc]init];
        _subTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _subTitleLab.text = @"共同记账，账本共享";
        [_subTitleLab sizeToFit];
    }
    return _subTitleLab;
}

- (NSArray *)titles{
    return @[@"新建账本",@"暗号加入"];
}

- (NSArray *)images{
    return @[@"bk_new_sharebook_normal",@"bk_new_sharebook_anhao"];
}

- (void)appearance {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.subTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
//    self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        self.collectionView.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
