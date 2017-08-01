//
//  SSJRewardRankView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRewardRankView.h"
#import "SSJRewardRankViewCell.h"


#import "SSJRankListItem.h"
#import "SSJRewardRankService.h"
static CGFloat btnHeight = 64;
@interface SSJRewardRankView ()<UITableViewDelegate,UITableViewDataSource,SSJBaseNetworkServiceDelegate>

@property (nonatomic, strong) SSJRewardRankService *rankService;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

/**<#注释#>*/
@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, strong) UIButton *bottomBtn;

@property (nonatomic, strong) UIImageView *closeImgView;
@end


@implementation SSJRewardRankView

- (instancetype)initWithFrame:(CGRect)frame backgroundView:(UIImage *)bgImage {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundView];
        self.backgroundView.image = bgImage;
        [self addSubview:self.tableView];
        [self addSubview:self.bottomBtn];
        [self.bottomBtn addSubview:self.closeImgView];
        [self updateAppearance];
        [self.rankService requestRankList];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    
    self.bottomBtn.size = CGSizeMake(SSJSCREENWITH, btnHeight);
    self.bottomBtn.top = 0;
    self.bottomBtn.left = 0;
    
    self.tableView.frame = CGRectMake(0, self.bottomBtn.height, self.width, SSJSCREENHEIGHT - self.bottomBtn.height);
    self.closeImgView.centerY = self.bottomBtn.height * 0.5 + 10;
    
    self.closeImgView.left = 15;
}

#pragma mark - Theme
- (void)updateAppearance {
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
     self.closeImgView.tintColor = self.bottomBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
    [self.bottomBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    UIColor *backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [self.bottomBtn setBackgroundImage:[UIImage ssj_imageWithColor:backgroundColor size:CGSizeZero] forState:UIControlStateNormal];
    UIColor *titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTitleColor];
    [self.bottomBtn setTitleColor:titleColor forState:UIControlStateNormal];
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}


#pragma mark - Event
- (void)bottomBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat top = 0;
    if (btn.selected) {
        top = 0;
        transform = CGAffineTransformMakeRotation(M_PI);
        self.closeImgView.hidden = NO;
    } else {
        top = SSJSCREENHEIGHT - btnHeight;
        CGAffineTransform transform = CGAffineTransformIdentity;
        self.closeImgView.hidden = YES;
    }
    
    @weakify(self);
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        self.top = top;
        btn.imageView.transform = transform;
    }];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:SSJ_KEYWINDOW];
    CGFloat centerX = SSJSCREENWITH * 0.5;
    CGFloat centerY = self.centerY + translation.y;
    self.center = CGPointMake(centerX,centerY);
    [recognizer setTranslation:CGPointZero inView:self];
    
    CGFloat top = 0;
    __block CGAffineTransform transform = CGAffineTransformIdentity;
    if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if(self.top >= SSJSCREENHEIGHT * 0.5) {
            top = SSJSCREENHEIGHT - btnHeight;
            self.bottomBtn.selected = NO;
            transform = CGAffineTransformIdentity;
            self.closeImgView.hidden = YES;
        }else{
            top = 0;
            self.bottomBtn.selected = YES;
            transform = CGAffineTransformMakeRotation(M_PI);
            self.closeImgView.hidden = NO;
        }
        @weakify(self);
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self);
            self.top = top;
            self.bottomBtn.imageView.transform = transform;
            
        }];
    }
}



#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataArray ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJRewardRankViewCell *cell = [SSJRewardRankViewCell cellWithTableView:tableView];
    cell.cellItem = [self.dataArray ssj_objectAtIndexPath:indexPath];
    [cell isNotShowSelfRank:(self.dataArray.count > 1 && indexPath.section == 0)];
    return cell;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    self.dataArray = self.rankService.listArray;
    [self.tableView reloadData];
}


#pragma mark - Lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.rowHeight = 80;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView ssj_clearExtendSeparator];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] init];
    }
    return _backgroundView;
}

- (SSJRewardRankService *)rankService {
    if (!_rankService) {
        _rankService = [[SSJRewardRankService alloc] initWithDelegate:self];
    }
    return _rankService;
}

- (UIButton *)bottomBtn {
    if (!_bottomBtn) {
        _bottomBtn = [[UIButton alloc] init];
        _bottomBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_bottomBtn setTitle:@"打赏榜" forState:UIControlStateNormal];
        [_bottomBtn setImage:[[UIImage imageNamed:@"founds_selectbutton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        
        [_bottomBtn setTitleEdgeInsets:UIEdgeInsetsMake(16, 8, 0, 35)];
        [_bottomBtn setImageEdgeInsets:UIEdgeInsetsMake(16, 70, 0, -35)];
        [_bottomBtn ssj_setBorderWidth:1];
        [_bottomBtn ssj_setBorderStyle:SSJBorderStyleTop|SSJBorderStyleBottom];
        
        UIPanGestureRecognizer *panReg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_bottomBtn addGestureRecognizer:panReg];
        
        [_bottomBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _bottomBtn;
}

- (UIImageView *)closeImgView {
    if (!_closeImgView) {
        _closeImgView = [[UIImageView alloc] init];
        _closeImgView.image = [[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _closeImgView.size = CGSizeMake(18, 18);
        self.closeImgView.hidden = YES;
    }
    return _closeImgView;
}

@end
