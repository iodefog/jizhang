//
//  SSJHomeThemeModifyView.m
//  SuiShouJi
//
//  Created by ricky on 2017/4/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJHomeThemeModifyView.h"
#import "SSJCustomThemeSelectCollectionViewCell.h"
#import "SSJButton.h"

#import "SSJCustomThemeManager.h"


static NSString *const kCellId = @"SSJCustomThemeSelectCollectionViewCell";

@interface SSJHomeThemeModifyView() <UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView  *collectionView;

@property(nonatomic, strong) NSArray *images;

@property(nonatomic, strong) UILabel *fontLab;

@property(nonatomic, strong) SSJButton *blackButton;

@property(nonatomic, strong) SSJButton *whiteButton;

@end

@implementation SSJHomeThemeModifyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.images = @[@"",@"theme_custom1_light",@"theme_custom2_light",@"theme_custom3_dark",@"theme_custom4_dark"];
        [self addSubview:self.collectionView];
        [self addSubview:self.fontLab];
        [self addSubview:self.whiteButton];
        [self addSubview:self.blackButton];

        [self.collectionView registerClass:[SSJCustomThemeSelectCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        self.backgroundColor = [UIColor ssj_colorWithHex:@"353535" alpha:0.6];
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
    self.whiteButton.size = self.blackButton.size = CGSizeMake(24, 24);
    self.whiteButton.left = self.width / 2 + 14;
    self.whiteButton.centerY = self.fontLab.centerY;
    self.blackButton.left = self.whiteButton.right + 34;
    self.blackButton.centerY = self.fontLab.centerY;
}

- (UICollectionView *)collectionView {
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 20;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
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
        _fontLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_fontLab sizeToFit];
    }
    return _fontLab;
}

- (SSJButton *)blackButton {
    if (!_blackButton) {
        _blackButton = [[SSJButton alloc] init];
        _blackButton.contentInset = UIEdgeInsetsMake(6, 6, 6, 6);
        _blackButton.size = CGSizeMake(12, 12);
        _blackButton.cornerRadius = 6.f;
        _blackButton.borderWidth  = 2.f;
        [_blackButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];
        [_blackButton setBackgroundColor:[UIColor blackColor] forState:SSJButtonStateNormal];
        [_blackButton addTarget:self action:@selector(blackBlackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _blackButton;
}

- (SSJButton *)whiteButton {
    if (!_whiteButton) {
        _whiteButton = [[SSJButton alloc] init];
        _whiteButton.contentInset = UIEdgeInsetsMake(6, 6, 6, 6);
        _whiteButton.size = CGSizeMake(12, 12);
        _whiteButton.cornerRadius = 6.f;
        _whiteButton.borderWidth  = 2.f;
        [_whiteButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];
        [_whiteButton setBackgroundColor:[UIColor whiteColor] forState:SSJButtonStateNormal];
        [_whiteButton addTarget:self action:@selector(whiteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _whiteButton;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        if (self.themeSelectCustomImageBlock) {
            self.themeSelectCustomImageBlock();
        }
        [self dismiss]; 
    } else {
        self.seletctTheme = [self.images objectAtIndex:indexPath.item];
        if ([self.seletctTheme isEqualToString:@"background"]) {
            self.selectType = NO;
            [self.blackButton setBorderColor:[UIColor ssj_colorWithHex:@"#EB4762"] forState:SSJButtonStateNormal];
            [self.whiteButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];

            [self.collectionView reloadData];
            [SSJCustomThemeManager changeThemeWithLocalImage:nil type:self.selectType];
        } else {
            if ([self.seletctTheme hasSuffix:@"dark"]) {
                self.selectType = YES;
                [self.whiteButton setBorderColor:[UIColor ssj_colorWithHex:@"#EB4762"] forState:SSJButtonStateNormal];
                [self.blackButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];

            } else {
                self.selectType = NO;
                [self.blackButton setBorderColor:[UIColor ssj_colorWithHex:@"#EB4762"] forState:SSJButtonStateNormal];
                [self.whiteButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];

            }
            [self.collectionView reloadData];
            [SSJCustomThemeManager changeThemeWithDefaultImageName:self.seletctTheme type:self.selectType];
            

        }
        if (self.themeSelectBlock) {
            self.themeSelectBlock(self.seletctTheme,self.selectType);
        }
        
        //友盟统计
        [SSJAnaliyticsManager event:@"more_define_bg_sel_default_pic"];
    }
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJCustomThemeSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    if (indexPath.item == 0) {
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.isFirstCell = YES;
        cell.isSelected = NO;
    } else {
        
        if ([[self.images objectAtIndex:indexPath.item] isEqualToString:self.seletctTheme]) {
            cell.isSelected = YES;
        } else {
            cell.isSelected = NO;
        }
        NSString *imageName = [self.images objectAtIndex:indexPath.item];
        if ([imageName isEqualToString:@"background"]) {
            cell.imageView.image = [UIImage ssj_themeLocalBackGroundImageName:imageName];
        } else {
            cell.imageView.image = [UIImage imageNamed:[self.images objectAtIndex:indexPath.item]];
        }
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
    
    [self sizeToFit];

    [self getCurrentTheme];
    
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

//- (void)setSelectType:(BOOL)selectType {
//    _selectType = selectType;
//    if (!selectType) {
//        self.whiteButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#EB4762"].CGColor;
//        self.blackButton.layer.borderColor = [UIColor clearColor].CGColor;
//    } else {
//        self.blackButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#EB4762"].CGColor;
//        self.whiteButton.layer.borderColor = [UIColor clearColor].CGColor;
//    }
//}

- (void)blackBlackButtonClick:(id)sender{
    self.selectType = NO;
    if (!self.seletctTheme) {
        self.seletctTheme = @"theme_custom3_dark";
        [self.collectionView reloadData];
    }
    [self updateFontType];
    if ([self.seletctTheme isEqualToString:@"background"]) {
        [SSJCustomThemeManager changeThemeWithLocalImage:nil type:self.selectType];
    } else {
        [SSJCustomThemeManager changeThemeWithDefaultImageName:self.seletctTheme type:self.selectType];
    }
}

- (void)whiteButtonClick:(id)sender{
    self.selectType = YES;
    if (!self.seletctTheme) {
        self.seletctTheme = @"theme_custom1_light";
        [self.collectionView reloadData];
    }
    [self updateFontType];
    if ([self.seletctTheme isEqualToString:@"background"]) {
        [SSJCustomThemeManager changeThemeWithLocalImage:nil type:self.selectType];
    } else {
        [SSJCustomThemeManager changeThemeWithDefaultImageName:self.seletctTheme type:self.selectType];
    }
}

- (void)getCurrentTheme {
    SSJThemeModel *currentTheme = [SSJThemeSetting currentThemeModel];
    if ([UIImage ssj_themeLocalBackGroundImageName:@"background"]) {
        self.images = @[@"",@"background",@"theme_custom1_light",@"theme_custom2_light",@"theme_custom3_dark",@"theme_custom4_dark"];
    }
    if (currentTheme.customThemeBackImage.length) {
        if (![currentTheme.customThemeBackImage isEqualToString:@"background"]) {
            NSInteger themeIndex = [[currentTheme.customThemeBackImage stringByReplacingOccurrencesOfString:@"custom" withString:@""] integerValue];
            if ([UIImage ssj_themeLocalBackGroundImageName:@"background"]) {
                self.seletctTheme = [self.images objectAtIndex:themeIndex + 1];
            } else {
                self.seletctTheme = [self.images objectAtIndex:themeIndex];
            }
        } else {
            self.seletctTheme = currentTheme.customThemeBackImage;
        }
        self.selectType = currentTheme.darkOrLight;
        [self updateFontType];
        [self.collectionView reloadData];
    } else {
        self.seletctTheme = nil;
        [self.blackButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];
        [self.whiteButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];
        [self.collectionView reloadData];
    }
}

- (void)updateFontType {
    if (!self.selectType) {
        [self.blackButton setBorderColor:[UIColor ssj_colorWithHex:@"#EB4762"] forState:SSJButtonStateNormal];
        [self.whiteButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];
    } else {
        [self.whiteButton setBorderColor:[UIColor ssj_colorWithHex:@"#EB4762"] forState:SSJButtonStateNormal];
        [self.blackButton setBorderColor:[UIColor clearColor] forState:SSJButtonStateNormal];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
