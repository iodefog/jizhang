//
//  SSJBooksTypeCollectionViewCell.h
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBooksTypeItem.h"

SSJ_DEPRECATED

@interface SSJBooksTypeCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) SSJBooksTypeItem *item;

typedef void (^selectButtonClickedBlock)(SSJBooksTypeItem *item);

@property(nonatomic) BOOL selectToEdite;

@property(nonatomic) BOOL isSelected;

@property(nonatomic) BOOL editeModel;

@end
