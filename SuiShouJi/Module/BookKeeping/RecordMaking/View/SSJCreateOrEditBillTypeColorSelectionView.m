//
//  SSJCreateOrEditBillTypeColorSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreateOrEditBillTypeColorSelectionView.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCreateOrEditBillTypeColorSelectionCell
#pragma mark -
static const CGSize kColorLumpSize = {40, 25};
static const CGFloat kZoomScale = 1.25;
static const NSTimeInterval kDuration = 0.25;

@interface SSJCreateOrEditBillTypeColorSelectionCell : UICollectionViewCell

@property (nonatomic, strong) UIView *colorLump;

@end

@implementation SSJCreateOrEditBillTypeColorSelectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.colorLump];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.colorLump mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(kColorLumpSize);
        make.center.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [UIView animateWithDuration:0.25 animations:^{
        if (selected) {
            self.colorLump.transform = CGAffineTransformMakeScale(kZoomScale, kZoomScale);
        } else {
            self.colorLump.transform = CGAffineTransformIdentity;
        }
    }];
}

- (UIView *)colorLump {
    if (!_colorLump) {
        _colorLump = [[UIView alloc] init];
        _colorLump.clipsToBounds = YES;
        _colorLump.layer.cornerRadius = 4;
    }
    return _colorLump;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCreateOrEditBillTypeColorSelectionView
#pragma mark -
static NSString *const kCellId = @"kCellId";
static const NSUInteger kColorLumpCountPerRow = 5;

@interface SSJCreateOrEditBillTypeColorSelectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic) BOOL showed;

@end

@implementation SSJCreateOrEditBillTypeColorSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.hidden = YES;
        _selectedIndex = NSNotFound;
        
        [self addSubview:self.backView];
        [self addSubview:self.collectionView];
        [self updateAppearanceAccordingToTheme];
    }
    return self;
}

- (void)updateConstraints {
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self setupCollectionViewConstraint];
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat horizontalSpace = (self.width - kColorLumpSize.width * kColorLumpCountPerRow) / (kColorLumpCountPerRow + 1);
    CGFloat verticalSpace = 26;
    CGFloat itemWidth = horizontalSpace + kColorLumpSize.width;
    CGFloat itemHeight = kColorLumpSize.height + verticalSpace;
    
    [self.layout invalidateLayout];
    self.layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.layout.sectionInset = UIEdgeInsetsMake(verticalSpace * 0.5, horizontalSpace * 0.5, verticalSpace * 0.5, horizontalSpace * 0.5);
}

- (void)setColors:(NSArray<UIColor *> *)colors {
    _colors = colors;
    [self.collectionView reloadData];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex != NSNotFound && selectedIndex >= self.colors.count) {
        SSJPRINT(@"selectedIndex必须小于self.colors.count");
        return;
    }
    
    if (_selectedIndex == selectedIndex) {
        return;
    }
    
    _selectedIndex = selectedIndex;
    if (selectedIndex == NSNotFound) {
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
    } else {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)show {
    if (self.showed) {
        return;
    }
    
    self.showed = YES;
    self.hidden = NO;
    [self setupCollectionViewConstraint];
    [UIView animateWithDuration:kDuration animations:^{
        self.backView.alpha = SSJMaskAlpha;
        [self layoutIfNeeded];
    }];
}

- (void)dismiss {
    if (!self.showed) {
        return;
    }
    
    self.showed = NO;
    [self setupCollectionViewConstraint];
    [UIView animateWithDuration:kDuration animations:^{
        self.backView.alpha = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    
    if (self.dismissHandler) {
        self.dismissHandler(self);
    }
}

- (void)updateAppearanceAccordingToTheme {
    self.collectionView.backgroundColor = SSJ_SECONDARY_FILL_COLOR;
}

- (void)setupCollectionViewConstraint {
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.showed) {
            make.top.mas_equalTo(self);
        } else {
            make.bottom.mas_equalTo(self.mas_top);
        }
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(290);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colors.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJCreateOrEditBillTypeColorSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.colorLump.backgroundColor = _colors[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath.item;
    if (self.selectColorAction) {
        self.selectColorAction(self);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SSJCreateOrEditBillTypeColorSelectionCell class] forCellWithReuseIdentifier:kCellId];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc]init];
        [_layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
    }
    return _layout;
}

@end
