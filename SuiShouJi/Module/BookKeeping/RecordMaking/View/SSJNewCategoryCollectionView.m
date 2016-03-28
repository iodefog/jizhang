//
//  SSJNewCategoryCollectionView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewCategoryCollectionView.h"
#import "SSJPageControl.h"
#import "SSJCustomCollectionViewFlowLayout.h"
#import "SSJCategoryCollectionViewCell.h"

@interface SSJNewCategoryCollectionView()
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) SSJPageControl *pageControl;
@property (nonatomic,strong) SSJCustomCollectionViewFlowLayout *layout;
@property (nonatomic,strong) NSString *selectedId;
@end

@implementation SSJNewCategoryCollectionView{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.pageContentInsets = UIEdgeInsetsMake(0, 4, 12, 4);
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

- (NSInteger)numberOfSections{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionViewCellIdentifier" forIndexPath:indexPath];
    cell.item = (SSJRecordMakingCategoryItem*)[self.items objectAtIndex:indexPath.row];
    if ([cell.item.categoryID isEqualToString:self.selectedId]) {
        cell.categorySelected = YES;
    }else{
        cell.categorySelected = NO;
    }
    __weak typeof(self) weakSelf = self;
    cell.removeCategoryBlock = ^(){
        if (weakSelf.removeFromCategoryListBlock) {
            weakSelf.removeFromCategoryListBlock();
        }
    };
    cell.EditeModel = NO;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJCategoryCollectionViewCell *cell = (SSJCategoryCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (self.ItemClickedBlock) {
        self.ItemClickedBlock(cell.item);
    }
}

#pragma mark -  UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self checkIfIndexChanged:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self checkIfIndexChanged:scrollView];
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.frame
                                                 collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = nil;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _collectionView;
}


-(SSJPageControl *)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[SSJPageControl alloc]initWithFrame:CGRectMake(0, self.height - 15, self.width, 15)];
        _pageControl.spaceBetweenPages = 10;
        _pageControl.pageImage = [UIImage imageNamed:@"circle"];
        _pageControl.currentPageImage = [UIImage imageNamed:@"solid_circle"];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.numberOfPages = [self.layout pagesNumberInSection:0];
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

-(SSJCustomCollectionViewFlowLayout *)layout{
    if (!_layout) {
        if (_screenWidth == 320) {
            if (_screenHeight == 568) {
                _layout.itemSize = CGSizeMake((self.width - 80)/4, (self.height - 20) / 2);
                _layout.columnNum = 4;
                _layout.linesNum = 2;
            }else{
                _layout.itemSize = CGSizeMake((self.width - 80)/4, self.height - 5);
                _layout.columnNum = 4;
                _layout.linesNum = 1;
            }
        }else if(_screenWidth == 375){
            _layout.itemSize = CGSizeMake((self.width - 80)/4, (self.height - 80) / 2);
            _layout.columnNum = 4;
            _layout.linesNum = 2;
        }else{
            _layout.itemSize = CGSizeMake((self.width - 80)/4, (self.height - 40) / 3);
            _layout.columnNum = 4;
            _layout.linesNum = 3;
        }
        _layout = [[SSJCustomCollectionViewFlowLayout alloc]
                   initWithTileSize:_itemSize
                                                    linesNum:_lineCount
                                                                          columnNum:_columnCount
                                                                  pageContentInsets:_pageContentInsets];
    }
    return _layout;
}

-(void)setColumnCount:(NSUInteger)columnCount
{
    _columnCount = columnCount;
    self.layout.columnNum = _columnCount;
}

-(void)setPageContentInsets:(UIEdgeInsets)pageContentInsets
{
    _pageContentInsets = pageContentInsets;
    self.layout.pageContentInsets = pageContentInsets;
}

-(void)setLineCount:(NSUInteger)lineCount
{
    _lineCount = lineCount;
    self.layout.linesNum = _lineCount;
}

-(void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    self.layout.itemSize = _itemSize;
}

-(void)setItems:(NSMutableArray *)items{
    _items = items;
}

- (void)checkIfIndexChanged:(UIScrollView *)scrollView
{
    CGPoint contentOffset = [scrollView contentOffset];
    CGFloat page = contentOffset.x / scrollView.frame.size.width;
    
    NSInteger section = [self.layout sectionFromPages:page];
    NSInteger pagesBefore = [self.layout pagesNumberBeforeSection:section];
    
    self.pageControl.numberOfPages = [self.layout pagesNumberInSection:section];
    self.pageControl.currentPage = page - pagesBefore;
    
}

- (void)reloadData
{
    [self.collectionView reloadData];
    [self checkIfIndexChanged:self.collectionView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
