//
//  SSJBaseCollectionViewController.h
//  SuiShouJi
//
//  Created by cdd on 15/10/27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJBaseCollectionViewController : SSJBaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, assign) BOOL showDragView;  //是否显示下拉加载(默认YES)

- (void)updateRefreshViewTopInset:(CGFloat)topInset;

/**
 *  开始下拉刷新，需要子类覆写
 */
- (void)startPullRefresh;

@end
