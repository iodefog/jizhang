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
@property(nonatomic,strong) UIScrollView *scrollView;
@end
@implementation SSJCategoryListView{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.collectionViewArray = [[NSMutableArray alloc]init];
        [self addSubview:self.pageControl];
        [self addSubview:self.scrollView];
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
    }
    return self;
}

-(void)layoutSubviews{
    self.pageControl.top = self.scrollView.bottom;
    self.pageControl.centerX = self.centerX;
    if (_screenWidth == 375 | _screenWidth == 414) {
        self.scrollView.frame = CGRectMake(0, 0, self.width, self.height - 20);
    }else{
        self.scrollView.frame = CGRectMake(0, 0, self.width, self.height - 10);
    }
    _scrollView.contentSize = CGSizeMake(self.width * 2, 0);
    for (int i = 0; i < 2; i++) {
        CGFloat positionX = i * self.width;
        ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).frame = CGRectMake(positionX, 0, self.scrollView.width, self.scrollView.height);;
    }

}

-(void)setCollectionView{
    for (int i = 0; i < 2; i++) {
        SSJCategoryCollectionView *collectionView = [[SSJCategoryCollectionView alloc]init];
        collectionView.frame = CGRectZero;
        collectionView.ItemClickedBlock = ^(NSString *categoryTitle , UIImage *categoryImage){
            if (self.CategorySelected) {
                self.CategorySelected(categoryTitle,categoryImage);
            }
        };
        [self.collectionViewArray addObject:collectionView];
        [self.scrollView addSubview:collectionView];
    }
}

-(UIPageControl*)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.frame = CGRectMake(0, 0, 70, 10);
        _pageControl.numberOfPages = 2;
        _pageControl.currentPageIndicatorTintColor = [UIColor ssj_colorWithHex:@"cccccc"];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

-(UIScrollView*)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        [self setCollectionView];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(self.width * 2, 0);
        _scrollView.delegate = self;
    }
    return _scrollView;
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
