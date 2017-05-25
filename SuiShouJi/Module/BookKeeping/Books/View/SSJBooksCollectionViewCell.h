//
//  SSJBooksCollectionViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SSJBooksCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) __kindof SSJBaseCellItem *booksTypeItem;

/**当前选中的账本ID*/
@property (nonatomic, copy) NSString *curretSelectedBookId;

/**编辑按钮点击*/
@property (nonatomic, copy) void(^editBookAction)(__kindof SSJBaseCellItem *booksTypeItem);

/**
 新建账本后动画
 */
- (void)animationAfterCreateBook;

NS_ASSUME_NONNULL_END
@end
