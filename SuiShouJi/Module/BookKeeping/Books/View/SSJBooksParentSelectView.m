
//
//  SSJBooksParentSelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksParentSelectView.h"
#import "SSJBooksParentSelectCell.h"

static NSString * SSJBooksParentSelectCellIdentifier = @"SSJBooksParentSelectCellIdentifier";

@interface SSJBooksParentSelectView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) UIImageView *waveView;

@end

@implementation SSJBooksParentSelectView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        [self addSubview:self.waveView];
        [self addSubview:self.titleLab];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[SSJBooksParentSelectCell class] forCellWithReuseIdentifier:SSJBooksParentSelectCellIdentifier];
        [self sizeToFit];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearance) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLab.center = CGPointMake(self.width / 2, 40);
    self.waveView.leftTop = CGPointMake(0, 0);
    self.waveView.size = CGSizeMake(self.width, 80);
    self.collectionView.size = CGSizeMake(self.width, self.height - self.waveView.bottom);
    self.collectionView.leftTop = CGPointMake(0, self.waveView.bottom);
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width - 40, 390);
}

- (UIImageView *)waveView{
    if (!_waveView) {
        _waveView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, 80)];
        _waveView.image = [[UIImage ssj_themeImageWithName:@"bk_wave"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 32, 0) resizingMode:UIImageResizingModeStretch];
    }
    return _waveView;
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.text = @"请选择账本收支类型";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 20;
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _collectionView;
}

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
//    SSJBooksParentSelectCell * cell = (SSJBooksParentSelectCell *)[collectionView cellForItemAtIndexPath:indexPath];
    switch (indexPath.item) {
        case 0:
            [SSJAnaliyticsManager event:@"book_type_richang"];
            break;
 
        case 1:
            [SSJAnaliyticsManager event:@"book_type_shengyi"];
            break;

        case 2:
            [SSJAnaliyticsManager event:@"book_type_jiehun"];
            break;

        case 3:
            [SSJAnaliyticsManager event:@"book_type_zhuangxiu"];
            break;

        case 4:
            [SSJAnaliyticsManager event:@"book_type_lvxing"];
            break;

        default:
            break;
    }
//    cell.isSelected = YES;
    if (self.parentSelectBlock) {
        self.parentSelectBlock(indexPath.item);
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self titles].count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    SSJBooksParentSelectCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJBooksParentSelectCellIdentifier forIndexPath:indexPath];
//    cell.image = [self.images ssj_safeObjectAtIndex:indexPath.item];
//    cell.title = [self.titles ssj_safeObjectAtIndex:indexPath.item];
//    cell.isSelected = NO;
//    return cell;
    return [UICollectionViewCell new];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.width - 40, 40);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 20, 5, 20);
}

- (NSArray *)titles{
    return @[@"日常账本",@"生意账本",@"结婚账本",@"装修装本",@"旅行账本"];
}

- (NSArray *)images{
    return @[@"bk_moren",@"bk_shengyi",@"bk_jiehun",@"bk_zhuangxiu",@"bk_lvxing"];
}

#pragma mark - Private
- (void)updateAppearance {
    self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.waveView.image = [[UIImage ssj_themeImageWithName:@"bk_wave"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 32, 0) resizingMode:UIImageResizingModeStretch];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
