//
//  SSJBooksTypeCollectionViewCell.h
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBooksTypeItem.h"

@interface SSJBooksTypeCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong) SSJBooksTypeItem *item;

typedef void (^longPressBlock)();

@property(nonatomic,copy) longPressBlock longPressBlock;

@end
