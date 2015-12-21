//
//  SSJCategoryListView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryListView.h"
#import "SSJCategoryCollectionView.h"

@interface SSJCategoryListView()
@property(nonatomic,strong) NSMutableArray *collectionViewArray;
@property(nonatomic,strong) UIPageControl *pageControl;
@property(nonatomic,strong) UIScrollView *scrolView;
@end
@implementation SSJCategoryListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self addSubview:self.pageControl];
        [self addSubview:self.scrolView];
    }
    return self;
}

-(void)layoutSubviews{
    self.pageControl.top = self.scrolView.bottom;
    self.pageControl.centerX = self.centerX;
}

-(void)setCollectionView{
    for (int i = 0; i < 2; i++) {
        CGFloat positionX = i * self.width;

        SSJCategoryCollectionView *collectionView = [[SSJCategoryCollectionView alloc]init];
        collectionView.frame = CGRectMake(positionX, 0, self.scrolView.width, self.scrolView.height);
        collectionView.ItemClickedBlock = ^(NSString *categoryTitle , UIImage *categoryImage){
            if (self.CategorySelected) {
                self.CategorySelected(categoryTitle,categoryImage);
            }
        };
        [self.collectionViewArray addObject:collectionView];
        [self.scrolView addSubview:collectionView];
    }
}

-(UIPageControl*)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.frame = CGRectMake(0, 0, 70, 30);
        _pageControl.numberOfPages = 2;
        _pageControl.currentPageIndicatorTintColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return _pageControl;
}

-(UIScrollView*)scrolView{
    if (!_scrolView) {
        _scrolView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height - 30)];
        [self setCollectionView];
        _scrolView.showsHorizontalScrollIndicator = NO;
        _scrolView.pagingEnabled = YES;
        _scrolView.contentSize = CGSizeMake(self.width * 2, 0);
        _scrolView.delegate = self;
    }
    return _scrolView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat x = scrollView.contentOffset.x;
    int page = (x + self.width / 2) / self.width;
    self.pageControl.currentPage = page;
}

-(void)reloadData{
    
}

@end
