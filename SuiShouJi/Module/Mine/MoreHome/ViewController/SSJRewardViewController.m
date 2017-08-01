//
//  SSJRewardViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRewardViewController.h"
#import "SSJRewardRankView.h"
#import "SSJPopView.h"

#import "TPKeyboardAvoidingScrollView.h"
#import "SSJMakeWishMoneyCollectionViewCell.h"

#import "NSString+MoneyDisplayFormat.h"

#import "SSJRewardRankService.h"

static NSString *wishMoneyCellId = @"SSJMakeWishMoneyCollectionViewCellId";
@interface SSJRewardViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate,SSJBaseNetworkServiceDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UICollectionView *moneyCollectionView;

/**排行榜*/
@property (nonatomic, strong) SSJRewardRankView *rewardRankView;

/**支付方式popview*/
@property (nonatomic, strong) SSJPopView *payMethodPopView;

@property (nonatomic, strong) UIImageView *topImg;

@property (nonatomic, strong) UILabel *slognL;

@property (nonatomic, strong) UIView *topBg;

@property (nonatomic, strong) UILabel *rewarkAmountTextL;

@property (nonatomic, strong) UITextField *rewarkAmountTextF;

@property (nonatomic, strong) UIView *bottomBg;

@property (nonatomic, strong) UILabel *rewarkNoteTextL;

@property (nonatomic, strong) UITextField *rewarkNotetTextF;

@property (nonatomic, strong) UIButton *goRewarkBtn;

@property (nonatomic, strong) UIButton *changePayMethodBtn;

/**心愿列表数据源*/
@property (nonatomic, strong) NSArray *rewarkMoneyDataArray;

/**支付方式*/
@property (nonatomic, assign) SSJMethodOfPayment payMethod;

@property (nonatomic, strong) SSJRewardRankService *rewarkService;

@property (nonatomic, strong) SSJRewardRankService *rewarkResultService;

@end

@implementation SSJRewardViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"打赏支持";

    [self setUpUI];
    [self initNormalData];
    [self.view setNeedsUpdateConstraints];
    [self signalBind];
    [self appearanceWithTheme];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)setUpUI {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topImg];
    [self.scrollView addSubview:self.slognL];
    
    [self.scrollView addSubview:self.topBg];
    [self.topBg addSubview:self.rewarkAmountTextL];
    [self.topBg addSubview:self.rewarkAmountTextF];
    [self.topBg addSubview:self.moneyCollectionView];
    
    [self.scrollView addSubview:self.bottomBg];
    [self.bottomBg addSubview:self.rewarkNoteTextL];
    [self.bottomBg addSubview:self.rewarkNotetTextF];
    
    [self.scrollView addSubview:self.goRewarkBtn];
    [self.scrollView addSubview:self.changePayMethodBtn];
    
//    [self.view addSubview:self.bottomBtn];
//    [self.bottomBtn addSubview:self.closeImgView];
//
//    [self.view addSubview:self.rewardRankView];
    
    [SSJ_KEYWINDOW addSubview:self.rewardRankView];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.bottomBtn removeFromSuperview];
    [self.rewardRankView removeFromSuperview];
}
#pragma mark - Layout
- (void)updateViewConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
    }];
    
    [self.topImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    
    [self.slognL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topImg.mas_bottom).offset(19);
        make.width.height.greaterThanOrEqualTo(0);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    
    [self.topBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.top.mas_equalTo(self.slognL.mas_bottom).offset(31);
        make.height.mas_equalTo(115);
    }];
    
    [self.rewarkAmountTextL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.width.lessThanOrEqualTo(@40);
        make.height.mas_equalTo(60);
    }];
    
    [self.rewarkAmountTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rewarkAmountTextL.mas_right);
        make.top.height.mas_equalTo(self.rewarkAmountTextL);
        make.right.mas_equalTo(-15);
    }];
    
    [self.moneyCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rewarkAmountTextL.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.topBg);
    }];
    
    [self.bottomBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topBg.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.topBg);
        make.bottom.mas_equalTo(self.rewarkNotetTextF).offset(28);
    }];
    
    [self.rewarkNoteTextL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(15);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    [self.rewarkNotetTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rewarkNoteTextL);
        make.top.mas_equalTo(self.rewarkNoteTextL.mas_bottom).offset(10);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(44);
    }];
    
    [self.goRewarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomBg.mas_bottom).offset(20);
        make.left.right.mas_equalTo(self.bottomBg);
        make.height.mas_equalTo(44);
    }];
    
    [self.changePayMethodBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goRewarkBtn.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.scrollView);
        make.width.greaterThanOrEqualTo(0);
    }];
  
    [super updateViewConstraints];
}

#pragma mark - Private
- (void)initNormalData {
    self.rewarkMoneyDataArray = @[@"5.20",@"13.14",@"52.0"];
}

- (void)signalBind {
    RACSignal *signal = [RACSignal combineLatest:@[RACObserve(self, rewarkAmountTextF.text)] reduce:^id(NSString *money) {
        return @(money.length && [money doubleValue] > 0);
    }];
    RAC(self.goRewarkBtn,enabled) = signal;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.rewarkService.payUrl.length && self.rewarkService.tradeNo.length) {
        //查询支付结果
        [self.rewarkResultService resultOfPayWithTradeNo:self.rewarkService.tradeNo];
    }
}
#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self appearanceWithTheme];
}

- (void)appearanceWithTheme {
    self.rewarkAmountTextF.textColor = self.rewarkNoteTextL.textColor = self.rewarkNotetTextF.textColor = self.rewarkAmountTextF.textColor = self.rewarkAmountTextL.textColor = self.slognL.textColor = SSJ_MAIN_COLOR;

    [self.moneyCollectionView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];

    [self.rewardRankView updateAppearance];
    
    self.rewarkAmountTextF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入打赏金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    
    [self.goRewarkBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [self.goRewarkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.goRewarkBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:SSJButtonDisableAlpha] forState:UIControlStateSelected];
    
    UIColor *backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor];

//    [self.bottomBtn setBackgroundImage:[UIImage ssj_imageWithColor:backgroundColor size:CGSizeZero] forState:UIControlStateNormal];
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.bottomBg.backgroundColor = self.topBg.backgroundColor =SSJ_DEFAULT_BACKGROUND_COLOR;
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.bottomBg.backgroundColor = self.topBg.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
    }
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if (![service.returnCode isEqualToString:@"1"]) return;
    if (service == self.rewarkService) {
        if (self.rewarkService.payUrl.length) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.rewarkService.payUrl] options:@{} completionHandler:nil];
        }
    } else if (service == self.rewarkResultService) {
        if ([self.rewarkResultService.payResultStatus isEqualToString:@"1"]) {
            [CDAutoHideMessageHUD showMessage:@"支付成功"];
        } else {
            [CDAutoHideMessageHUD showMessage:@"未支付成功"];
        }
    }
    
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.width - 120)/self.rewarkMoneyDataArray.count, 25);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *amount = [self.rewarkMoneyDataArray ssj_safeObjectAtIndex:indexPath.row];
    self.rewarkAmountTextF.text = amount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rewarkMoneyDataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJMakeWishMoneyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:wishMoneyCellId forIndexPath:indexPath];
    cell.layer.cornerRadius = 6;
    cell.layer.masksToBounds = YES;
    cell.amontStr = [self.rewarkMoneyDataArray ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.rewarkAmountTextF == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
    }
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - Lazy
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
    }
    return _scrollView;
}

- (SSJRewardRankView *)rewardRankView {
    if (!_rewardRankView) {
        _rewardRankView = [[SSJRewardRankView alloc] initWithFrame:CGRectMake(0, SSJSCREENHEIGHT - SSJ_NAVIBAR_BOTTOM, SSJSCREENWITH, SSJSCREENHEIGHT) backgroundView:self.backgroundView.image];
    }
    return _rewardRankView;
}

- (UIImageView *)topImg {
    if (!_topImg) {
        _topImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rewark_top_img"]];
    }
    return _topImg;
}

- (UIView *)topBg {
    if (!_topBg) {
        _topBg = [[UIView alloc] init];
        _topBg.layer.cornerRadius = 6;
        _topBg.layer.masksToBounds = YES;
    }
    return _topBg;
}

- (UILabel *)slognL {
    if (!_slognL) {
        _slognL = [[UILabel alloc] init];
        _slognL.text = @"谢谢你的爱，小鱼会继续努力哒~";
        _slognL.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
        _slognL.textColor = [UIColor whiteColor];
    }
    return _slognL;
}

- (UILabel *)rewarkAmountTextL {
    if (!_rewarkAmountTextL) {
        _rewarkAmountTextL = [[UILabel alloc] init];
        _rewarkAmountTextL.text = @"金额";
        _rewarkAmountTextL.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _rewarkAmountTextL;
}

- (UITextField *)rewarkAmountTextF {
    if (!_rewarkAmountTextF) {
        _rewarkAmountTextF = [[UITextField alloc] init];
        _rewarkAmountTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _rewarkAmountTextF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _rewarkAmountTextF.keyboardType = UIKeyboardTypeDecimalPad;
        _rewarkAmountTextF.textAlignment = NSTextAlignmentRight;
        _rewarkAmountTextF.delegate = self;
    }
    return _rewarkAmountTextF;
}

- (UICollectionView *)moneyCollectionView {
    if (!_moneyCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 15;
        flowLayout.minimumLineSpacing = 15;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _moneyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _moneyCollectionView.delegate = self;
        _moneyCollectionView.dataSource = self;
        _moneyCollectionView.backgroundColor = [UIColor clearColor];
        [_moneyCollectionView registerClass:[SSJMakeWishMoneyCollectionViewCell class] forCellWithReuseIdentifier:wishMoneyCellId];
        [_moneyCollectionView ssj_setBorderWidth:1];
        [_moneyCollectionView ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _moneyCollectionView;
}

- (UIView *)bottomBg {
    if (!_bottomBg) {
        _bottomBg = [[UIView alloc] init];
        _bottomBg.layer.cornerRadius = 6;
        _bottomBg.layer.masksToBounds = YES;
    }
    return _bottomBg;
}

- (UILabel *)rewarkNoteTextL {
    if (!_rewarkNoteTextL) {
        _rewarkNoteTextL = [[UILabel alloc] init];
        _rewarkNoteTextL.text = @"留言：";
        _rewarkNoteTextL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _rewarkNoteTextL;
}

- (UITextField *)rewarkNotetTextF {
    if (!_rewarkNotetTextF) {
        _rewarkNotetTextF = [[UITextField alloc] init];
        _rewarkNotetTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _rewarkNotetTextF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _rewarkNotetTextF.delegate = self;
    }
    return _rewarkNotetTextF;
}

- (UIButton *)goRewarkBtn {
    if (!_goRewarkBtn) {
        _goRewarkBtn = [[UIButton alloc] init];
        _goRewarkBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_goRewarkBtn setTitle:@"许下心愿" forState:UIControlStateNormal];
        _goRewarkBtn.layer.cornerRadius = 6;
        _goRewarkBtn.layer.masksToBounds = YES;
        @weakify(self);
        [[_goRewarkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.view endEditing:YES];
            [self.rewarkService payWithMethod:self.payMethod payMoney:self.rewarkAmountTextF.text memo:self.rewarkNotetTextF.text];
        }];
    }
    return _goRewarkBtn;
}

- (UIButton *)changePayMethodBtn {
    if (!_changePayMethodBtn) {
        _changePayMethodBtn = [[UIButton alloc] init];
        _changePayMethodBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        NSString *oldStr = @"使用微信付款，更换";
        NSString *tarStr = @"更换";
        NSMutableAttributedString *attStr = [oldStr attributeStrWithTargetStr:oldStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
        [attStr addAttribute:NSForegroundColorAttributeName value:SSJ_MAIN_COLOR range:[oldStr rangeOfString:tarStr]];
        [_changePayMethodBtn setAttributedTitle:attStr forState:UIControlStateNormal];
        _changePayMethodBtn.layer.cornerRadius = 6;
        _changePayMethodBtn.layer.masksToBounds = YES;
        
        @weakify(self);
        [[_changePayMethodBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.payMethodPopView showWithSelectedIndex:self.payMethod];
        }];
    }
    return _changePayMethodBtn;
}


- (SSJPopView *)payMethodPopView {
    if (!_payMethodPopView) {
        _payMethodPopView = [[SSJPopView alloc] initWithFrame:CGRectMake(0, 0, 280, 165)];
        _payMethodPopView.title = @"请选择支付方式";
        [_payMethodPopView setTitles:@[@"支付宝",@"微信"] andImages:@[@"pay_method_alipay",@"pay_method_weixin"]];
        @weakify(self);
        _payMethodPopView.didSelectAtIndexBlock = ^(NSInteger selectIndex) {
            @strongify(self);
            self.payMethod = selectIndex;
            //更新文字
            NSString *oldStr = selectIndex == SSJMethodOfPaymentAlipay ? @"使用微信付款，更换" : @"使用支付宝付款，更换";
            NSString *tarStr = @"更换";
            NSMutableAttributedString *attStr = [oldStr attributeStrWithTargetStr:oldStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
            [attStr addAttribute:NSForegroundColorAttributeName value:SSJ_MAIN_COLOR range:[oldStr rangeOfString:tarStr]];
            [self.changePayMethodBtn setAttributedTitle:attStr forState:UIControlStateNormal];
        };
    }
    return _payMethodPopView;
}

- (SSJRewardRankService *)rewarkService {
    if (!_rewarkService) {
        _rewarkService = [[SSJRewardRankService alloc] initWithDelegate:self];
    }
    return _rewarkService;
}

- (SSJRewardRankService *)rewarkResultService {
    if (!_rewarkResultService) {
        _rewarkResultService = [[SSJRewardRankService alloc] initWithDelegate:self];
    }
    return _rewarkResultService;
}


@end
