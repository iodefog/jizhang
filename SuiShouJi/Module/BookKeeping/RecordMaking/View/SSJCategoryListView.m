//
//  SSJCategoryListView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryListView.h"
#import "SSJCategoryCollectionView.h"
#import "SSJCategoryCollectionViewCell.h"
#import "SSJPageControl.h"
#import "FMDB.h"

@interface SSJCategoryListView()
@property(nonatomic,strong) SSJPageControl *pageControl;
@property (nonatomic,strong) NSMutableArray *Items;
@end
@implementation SSJCategoryListView{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    long _page;
    long _totalPage;
    long _selectedPage;
    NSIndexPath *_selectedIndex;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.incomeOrExpence = YES;
        _selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        _selectedPage = 0;
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        _page = 0;
        [self getPage];
        self.collectionViewArray = [[NSMutableArray alloc]init];
        [self addSubview:self.pageControl];
        [self addSubview:self.scrollView];
    }
    return self;
}

-(void)layoutSubviews{
    self.pageControl.bottom = self.height;
    self.pageControl.centerX = self.centerX;
    if (_screenWidth == 375) {
        self.scrollView.frame = CGRectMake(0, 0, self.width, self.height - 20);
    }else if(_screenWidth == 414){
        self.scrollView.frame = CGRectMake(0, 0, self.width, self.height - 40);
    }else{
        self.scrollView.frame = CGRectMake(0, 0, self.width, self.height - 10);
    }
    _scrollView.contentSize = CGSizeMake(self.width * _page, 0);
    for (int i = 0; i < _page; i++) {
        CGFloat positionX = i * self.width;
        ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).frame = CGRectMake(positionX, 0, self.scrollView.width, self.scrollView.height);
    }
}

-(void)setCollectionView{
    _totalPage = 8;
    for (int i = 0; i < _totalPage; i++) {
        SSJCategoryCollectionView *collectionView = [[SSJCategoryCollectionView alloc]init];
        collectionView.incomeOrExpence = self.incomeOrExpence;
        collectionView.frame = CGRectZero;
        collectionView.page = i;
        collectionView.incomeOrExpence = self.incomeOrExpence;
        collectionView.selectedId = self.selectedId;
        __weak typeof(self) weakSelf = self;
        collectionView.ItemClickedBlock = ^(SSJRecordMakingCategoryItem *item){
            self.item = item;
            for (int i = 0; i < _page; i++) {
                ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).selectedId = self.selectedId;
                ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).totalPage = _page;
                _pageControl.numberOfPages = _page;
                ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).page = i;
                ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).incomeOrExpence = self.incomeOrExpence;
                ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).selectedId = item.categoryID;
                [((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).collectionView reloadData];
            }
            if (weakSelf.CategorySelectedBlock) {
                weakSelf.CategorySelectedBlock(self.item);
            }
        };
        collectionView.removeFromCategoryListBlock = ^{
            [self reloadData];
        };

        [self.collectionViewArray addObject:collectionView];
        [self.scrollView addSubview:collectionView];
    }
}

-(SSJPageControl*)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[SSJPageControl alloc]init];
        _pageControl.numberOfPages = _page;
        _pageControl.spaceBetweenPages = 10;
        _pageControl.pageImage = [UIImage imageNamed:@"circle"];
        _pageControl.currentPageImage = [UIImage imageNamed:@"solid_circle"];
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
        _scrollView.contentSize = CGSizeMake(self.width * _page, 0);
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
    [self getPage];
    self.scrollView.contentSize = CGSizeMake(self.width * _page, 0);
    for (int i = 0; i < _totalPage; i ++) {
        ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).selectedId = self.selectedId;
        ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).totalPage = _page;
        _pageControl.numberOfPages = _page;
        ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).page = i;
        ((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).incomeOrExpence = self.incomeOrExpence;
        [((SSJCategoryCollectionView*)[self.collectionViewArray objectAtIndex:i]).collectionView reloadData];
    }
    [self setNeedsLayout];
}

-(void)getPage{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    NSUInteger count = [db intForQuery:@"SELECT COUNT(*) FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ID = B.CBILLID AND A.ITYPE = ? AND B.ISTATE = 1 AND B.CUSERID = ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID()] + 1;
    if (_screenWidth == 320) {
        if (_screenHeight == 568) {
            if (count % 8 == 0) {
                _page = count / 8;
            }else{
                _page = count / 8 + 1;
            }
        }else{
            if (count % 4 == 0) {
                _page = count / 4;
            }else{
                _page = count / 4 + 1;
            }
        }
    }else if(_screenWidth == 375){
        if (count % 8 == 0) {
            _page = count / 8;
        }else{
            _page = count / 8 + 1;
        }
    }else{
        if (count % 12 == 0) {
            _page = count / 12;
        }else{
            _page = count / 12 + 1;
        }
    }
    [db close];
}
@end
