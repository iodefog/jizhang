//
//  SSJHomeThemeModifyView.m
//  SuiShouJi
//
//  Created by ricky on 2017/4/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJHomeThemeModifyView.h"
#import "SSJCustomThemeSelectCollectionViewCell.h"

static NSString *const kCellId = @"SSJCustomThemeSelectCollectionViewCell";

@interface SSJHomeThemeModifyView() <UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView  *collectionView;

@property(nonatomic, strong) NSMutableArray *images;

@property(nonatomic, strong) UILabel *fontLab;

@end

@implementation SSJHomeThemeModifyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.images = [NSMutableArray arrayWithArray:@[@"",@"theme_custom1",@"theme_custom2",@"theme_custom3",@"theme_custom4"]];
        [self addSubview:self.collectionView];
        [self addSubview:self.fontLab];
        [self.collectionView registerClass:[SSJCustomThemeSelectCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        self.backgroundColor = [UIColor ssj_colorWithHex:@"353535" alpha:0.6];
        [self sizeToFit];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(SSJSCREENWITH, 126);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.size = CGSizeMake(self.width, self.height - 41);
    self.collectionView.leftBottom = CGPointMake(0, self.height);
    self.fontLab.rightTop = CGPointMake(self.width / 2 - 20, 18);
}

- (UICollectionView *)collectionView {
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 20;
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (UILabel *)fontLab {
    if (!_fontLab) {
        _fontLab = [[UILabel alloc] init];
        _fontLab.textColor = [UIColor whiteColor];
        _fontLab.text = @"字体颜色";
        _fontLab.font = [UIFont systemFontOfSize:13];
        [_fontLab sizeToFit];
    }
    return _fontLab;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        if (self.themeSelectCustomImageBlock) {
            self.themeSelectCustomImageBlock();
        }
    } else {
        self.seletctTheme = [self.images objectAtIndex:indexPath.item];
        if (self.themeSelectBlock) {
            self.themeSelectBlock(self.seletctTheme);
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJCustomThemeSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    if (indexPath.item == 0) {
        cell.isFirstCell = YES;
    } else {
        cell.imageName = [self.images objectAtIndex:indexPath.item];
        cell.isFirstCell = NO;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(65, 65);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    
    
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor clearColor] alpha:1 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
        
        self.left = 0;
    } timeInterval:0 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        [self removeFromSuperview];
    } timeInterval:0.25 fininshed:NULL];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
