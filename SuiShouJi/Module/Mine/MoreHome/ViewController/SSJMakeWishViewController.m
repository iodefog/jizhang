//
//  SSJMakeWishViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMakeWishViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface SSJMakeWishViewController ()
#define ITEM_SIZE_WIDTH 50
#define ITEM_SPACE (SSJSCREENWITH - 30 - ITEM_SIZE_WIDTH * 4) / 5

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
/**topImg*/
@property (nonatomic, strong) UIImageView *topImg;

@property (nonatomic, strong) UILabel *slognL;

@property (nonatomic, strong) UIImageView *cameraImg;

@property (nonatomic, strong) UILabel *wishTitleL;

@property (nonatomic, strong) UITextField *wishNameTextF;

/**bg*/
@property (nonatomic, strong) UIView *topBg;

/**心愿列表*/
@property (nonatomic, strong) UITableView *wishListTableView;

@property (nonatomic, strong) UILabel *wishAmountL;

@property (nonatomic, strong) UITextField *wishAmountTextF;

@property (nonatomic, strong) UICollectionView *moneyCollectionView;

/**bottomBg*/
@property (nonatomic, strong) UIView *bottomBg;

@property (nonatomic, strong) UIButton *makeWishBtn;
@end

@implementation SSJMakeWishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"许下心愿";
    [self setUpUI];
    [self appearanceWithTheme];
    [self signalBind];
}

- (void)setUpUI {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topImg];
    [self.topImg addSubview:self.slognL];
    [self.topImg addSubview:self.cameraImg];
    
    [self.scrollView addSubview:self.wishAmountL];
    [self.scrollView addSubview:self.bottomBg];
    [self.bottomBg addSubview:self.wishAmountTextF];
    [self.bottomBg addSubview:self.moneyCollectionView];

    [self.scrollView addSubview:self.wishTitleL];
    [self.scrollView addSubview:self.topBg];
    [self.topBg addSubview:self.wishNameTextF];
    [self.topBg addSubview:self.wishListTableView];
    
    [self.scrollView addSubview:self.makeWishBtn];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    self.topImg.frame = CGRectMake(0, 0, self.view.width, 150);
    self.slognL.center = self.topImg.center;
    self.cameraImg.rightTop = CGPointMake(self.view.width - 15, 15);
    self.wishTitleL.leftTop = CGPointMake(15, 25);
    self.topBg.frame = CGRectMake(15, CGRectGetMaxY(self.wishTitleL.frame)+10, self.view.width - 30, 44);
    
    self.wishAmountL.leftTop = CGPointMake(15, CGRectGetMaxY(self.wishTitleL.frame) + 85);
    self.bottomBg.frame = CGRectMake(15, CGRectGetMaxY(self.wishAmountL.frame)+10, self.view.width - 30, 44);
    self.makeWishBtn.frame = CGRectMake(15, SSJSCREENHEIGHT - 115, self.view.width - 30, 44);
}
//[self.iconView sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(data.iconUrl)] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
#pragma mark - Private
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self appearanceWithTheme];
}

- (void)appearanceWithTheme {
    self.wishNameTextF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入心愿" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    self.wishAmountTextF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"完成心愿所需金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

    [self.makeWishBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [self.makeWishBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:SSJButtonDisableAlpha] forState:UIControlStateSelected];
}

- (void)signalBind {
    RACSignal *signal = [RACSignal combineLatest:@[self.wishNameTextF.rac_textSignal,self.wishAmountTextF.rac_textSignal] reduce:^id(NSString *name, NSString *money) {
        return @(name.length && money.length);
    }];
    RAC(self.makeWishBtn,enabled) = signal;
    @weakify(self);
    [RACObserve(self.wishNameTextF, becomeFirstResponder) subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]) {
            [UIView animateWithDuration:0.1 animations:^{
//                self.topBg.height
            }];
        } else {
            
        }
    }];
    
    [RACObserve(self.wishAmountTextF, becomeFirstResponder) subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]) {
            
        } else {
            
        }
    }];
}

#pragma mark - Lazy
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
    }
    return _scrollView;
}

- (UIImageView *)topImg {
    if (!_topImg) {
        _topImg = [[UIImageView alloc] init];
        _topImg.image = [UIImage imageNamed:@"calendar_shareheader"];
    }
    return _topImg;
}

- (UILabel *)slognL {
    if (!_slognL) {
        _slognL = [[UILabel alloc] init];
        _slognL.text = @"许下心愿  为心愿存钱";
        _slognL.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_1];
        _slognL.textColor = [UIColor whiteColor];
        [_slognL sizeToFit];
    }
    return _slognL;
}

- (UIImageView *)cameraImg {
    if (!_cameraImg) {
        _cameraImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wish_bg_camera"]];
    }
    return _cameraImg;
}

-(UILabel *)wishTitleL {
    if (!_wishTitleL) {
        _wishTitleL = [[UILabel alloc] init];
        _wishTitleL.text = @"我的心愿";
        _wishTitleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _wishTitleL;
}

- (UITextField *)wishNameTextF {
    if (!_wishNameTextF) {
        _wishNameTextF = [[UITextField alloc] init];
        _wishNameTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _wishNameTextF;
}

- (UIView *)topBg {
    if (!_topBg) {
        _topBg = [[UIView alloc] init];
    }
    return _topBg;
}

- (UITableView *)wishListTableView {
    if (!_wishListTableView) {
        _wishListTableView = [[UITableView alloc] init];
        
    }
    return _wishListTableView;
}

- (UILabel *)wishAmountL {
    if (!_wishAmountL) {
        _wishAmountL = [[UILabel alloc] init];
        _wishTitleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _wishAmountL;
}

- (UITextField *)wishAmountTextF {
    if (!_wishAmountTextF) {
        _wishAmountTextF = [[UITextField alloc] init];
        _wishAmountTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _wishAmountTextF;
}

- (UICollectionView *)moneyCollectionView {
    if (!_moneyCollectionView) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = ITEM_SPACE;
        flowLayout.minimumLineSpacing = ITEM_SPACE;
        flowLayout.itemSize = CGSizeMake(ITEM_SIZE_WIDTH, ITEM_SIZE_WIDTH);
        flowLayout.sectionInset = UIEdgeInsetsMake(ITEM_SPACE, ITEM_SPACE, ITEM_SPACE, ITEM_SPACE);
        _moneyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    }
    return _moneyCollectionView;
}

- (UIView *)bottomBg {
    if (!_bottomBg) {
        _bottomBg = [[UIView alloc] init];
    }
    return _bottomBg;
}

- (UIButton *)makeWishBtn {
    if (!_makeWishBtn) {
        _makeWishBtn = [[UIButton alloc] init];
        _makeWishBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _makeWishBtn;
}
@end
