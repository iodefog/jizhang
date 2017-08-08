//
//  SSJHeaderBannerImageView.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHeaderBannerImageView.h"
#import "SSJHeaderBannerCollectionViewCell.h"
#import "SSJAdWebViewController.h"
#import "SSJBannerItem.h"

#import "SSJLoginVerifyPhoneViewController.h"

static NSString *const kHeadBannerCellID = @"SSJHeaderBannerCollectionViewCellID";

@interface SSJHeaderBannerImageView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
/**
 <#注释#>
 */
//@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation SSJHeaderBannerImageView



- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
//        [self addSubview:self.closeButton];
    }
    return self;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[SSJHeaderBannerCollectionViewCell class] forCellWithReuseIdentifier:kHeadBannerCellID];
        _collectionView.bounces = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

//- (UIButton *)closeButton
//{
//    if (!_closeButton) {
//        _closeButton = [[UIButton alloc] init];
//        [_closeButton setImage:[UIImage imageNamed:@"banner_cha"] forState:UIControlStateNormal];
//        [_closeButton sizeToFit];
//        [_closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _closeButton;
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = CGRectMake(0, 0, SSJSCREENWITH , kBannerHeight);
//    self.closeButton.rightTop = CGPointMake(SSJSCREENWITH - 20, 10);
}

- (void)setBannerItemArray:(NSArray *)bannerItemArray
{
    NSMutableArray *array = [NSMutableArray array];
    if (bannerItemArray.count > 1) {
        for (NSInteger i = 0; i<100; i++) {
            [array addObjectsFromArray:bannerItemArray];
        }
        _bannerItemArray = [array copy];
    }else{
        _bannerItemArray = bannerItemArray;
    }
    if (_bannerItemArray.count > 0) {
        [self.collectionView reloadData];
    }
}

- (void)closeButtonClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeBanner)]) {
        [self.delegate closeBanner];
    }
}


#pragma mark -UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bannerItemArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJHeaderBannerCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kHeadBannerCellID forIndexPath:indexPath];
    SSJBannerItem *item = self.bannerItemArray[indexPath.item];
    [cell setBannerImage:item.bannerImageUrl];
    return cell;
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.bannerItemArray.count == 1) {
        return CGSizeMake(SSJSCREENWITH, kBannerHeight - 10);
    }else{
        return CGSizeMake(285, kBannerHeight - 10);
    }
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBannerItem *item = [self.bannerItemArray ssj_safeObjectAtIndex:indexPath.row];
    //是账单
    if ([item.bannerTarget containsString:@"http://jz.youyuwo.com/5/zd"]) {
        if (!SSJIsUserLogined()) {
            __weak typeof(self) weakSelf = self;
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"请登录后再查看2016账单吧！" action:[SSJAlertViewAction actionWithTitle:@"关闭" handler:^(SSJAlertViewAction *action) {
            }],[SSJAlertViewAction actionWithTitle:@"立即登录" handler:^(SSJAlertViewAction *action) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(pushToViewControllerWithVC:)]) {
                    SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] init];
                    [weakSelf.delegate pushToViewControllerWithVC:loginVC];
                }
            }],nil];
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(pushToViewControllerWithUrl:title:)]) {
            [self.delegate pushToViewControllerWithUrl:[NSString stringWithFormat:@"%@?cuserId=%@",item.bannerTarget,SSJUSERID()] title:item.bannerName];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pushToViewControllerWithUrl:title:)]) {
            [self.delegate pushToViewControllerWithUrl:item.bannerTarget title:item.bannerName];
        }

    }

    
    }


@end
