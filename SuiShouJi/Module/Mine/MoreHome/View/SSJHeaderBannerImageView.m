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
@interface SSJHeaderBannerImageView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@end
@implementation SSJHeaderBannerImageView
static NSString *const kHeadBannerCellID = @"SSJHeaderBannerCollectionViewCellID";


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
    }
    return self;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[SSJHeaderBannerCollectionViewCell class] forCellWithReuseIdentifier:kHeadBannerCellID];
        _collectionView.bounces = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = CGRectMake(0, 0, SSJSCREENWITH , kBannerHeight);
}

- (void)setBannerItemArray:(NSArray *)bannerItemArray
{
    NSMutableArray *array = [NSMutableArray array];
    if (bannerItemArray.count > 1) {
        for (NSInteger i = 0; i<100; i++) {
            [array addObjectsFromArray:bannerItemArray];
        }
        _bannerItemArray = [array copy];
    }
    _bannerItemArray = bannerItemArray;
    if (_bannerItemArray.count > 0) {
        [self.collectionView reloadData];
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
        return CGSizeMake(SSJSCREENWITH, kBannerHeight);
    }else{
        return CGSizeMake(285, kBannerHeight);
    }
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBannerItem *item = self.bannerItemArray[indexPath.item];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushToViewControllerWithUrl:)]) {
        [self.delegate pushToViewControllerWithUrl:item.bannerUrl];
    }
}


@end
