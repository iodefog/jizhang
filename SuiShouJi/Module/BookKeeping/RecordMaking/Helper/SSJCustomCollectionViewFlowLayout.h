//
//  SSJCustomCollectionViewFlowLayout.h
//  SuiShouJi
//
//  Created by ricky on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCustomCollectionViewFlowLayout : UICollectionViewLayout

@property (nonatomic,assign) CGSize itemSize;
@property (nonatomic,assign) NSInteger linesNum;
@property (nonatomic,assign) NSInteger columnNum;
@property (nonatomic,assign) UIEdgeInsets pageContentInsets;

/**
 *  初始化自定义的layout
 *
 *  @param itemSize          item的大小
 *  @param linesNum          每页的行数
 *  @param columnNum         每页的列数
 *  @param pageContentInsets 每页之间的间距
 *
 *  @return 
 */
- (instancetype)initWithItem:(CGSize)itemSize
                        linesNum:(NSInteger)linesNum
                       columnNum:(NSInteger)columnNum
               pageContentInsets:(UIEdgeInsets)pageContentInsets;

/** 返回所有的页面的数量 */
- (NSInteger)pagesNumber;
/** 返回该section下页面的数量 */
- (NSInteger)pagesNumberInSection:(NSInteger)section;
/** 返回该section前还有的页面数量 */
- (NSInteger)pagesNumberBeforeSection:(NSInteger)secion;
/** 返回一页里面最多的item数量 */
- (NSInteger)maxInOnePage;

- (NSInteger)sectionFromPages:(NSInteger)pages;@end
