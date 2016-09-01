//
//  SSJCreditCardCollectionCell.h
//  SuiShouJi
//
//  Created by ricky on 16/9/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCreditCardItem.h"

@interface SSJCreditCardCollectionCell : UICollectionViewCell


@property (nonatomic,strong) SSJCreditCardItem *item;


@property (nonatomic,strong) UILabel *cardBalanceLabel;


@property(nonatomic) BOOL editeModel;

//点击删除按钮的回调
typedef void (^deleteButtonClickBlock)(SSJCreditCardCollectionCell *cell);

@property (nonatomic, copy) deleteButtonClickBlock deleteButtonClickBlock;

@end
