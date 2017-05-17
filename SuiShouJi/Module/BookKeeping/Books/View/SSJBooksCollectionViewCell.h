//
//  SSJBooksCollectionViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SSJBooksTypeItem;
NS_ASSUME_NONNULL_BEGIN
@interface SSJBooksCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong) SSJBooksTypeItem *booksTypeItem;
/**当前选中的账本ID*/
@property (nonatomic, copy) NSString *curretSelectedBookId;
NS_ASSUME_NONNULL_END
@end
