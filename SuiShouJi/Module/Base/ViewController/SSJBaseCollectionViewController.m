//
//  SSJBaseCollectionViewController.m
//  SuiShouJi
//
//  Created by cdd on 15/10/27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseCollectionViewController.h"
#import "SRRefreshView.h"
#import "SSJLoadMoreCollectionViewCell.h"

@interface SSJBaseCollectionViewController ()<SRRefreshDelegate>

@property (nonatomic, strong) SRRefreshView   *slimeView;

@end

@implementation SSJBaseCollectionViewController
@synthesize collectionView=_collectionView;

- (void)dealloc {
    [self.slimeView removeFromSuperview];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUpInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setUpInit];
    }
    return self;
}

- (void)setUpInit{
    self.showDragView=YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    if (self.showDragView) {
        [self.collectionView addSubview:self.slimeView];
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.slimeView update:64];
    }
}

- (UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.headerReferenceSize=CGSizeMake(self.view.width, 7);
        _collectionView =[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.backgroundColor=[UIColor groupTableViewBackgroundColor];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        //保证contentsize小于frame的size时也能下拉刷新
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}

- (SRRefreshView *)slimeView{
    if (_slimeView==nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor orangeColor];
        _slimeView.slime.skinColor = [UIColor whiteColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.activityIndicationView.color = [UIColor orangeColor];
        _slimeView.slime.viscous=50;
    }
    return _slimeView;
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.showDragView) {
        [self.slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.showDragView) {
        [self.slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView{
    [self startPullRefresh];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [[UICollectionViewCell alloc]init];
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    if (self.showDragView) {
        [self.slimeView endRefresh];
    }
}

- (void)serverDidCancel:(SSJBaseNetworkService *)service {
    [super serverDidCancel:service];
    if (self.showDragView) {
        [self.slimeView endRefresh];
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError*)error {
    [super server:service didFailLoadWithError:error];
    if (self.showDragView) {
        [self.slimeView endRefresh];
    }
}

#pragma mark - Public
- (void)updateRefreshViewTopInset:(CGFloat)topInset{
    [self.slimeView update:topInset];
}

- (void)startPullRefresh {
}

@end
