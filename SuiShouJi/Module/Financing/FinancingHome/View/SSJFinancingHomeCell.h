//
//  SSJFinancingHomeCollectionViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingHomeitem.h"
#import "SSJBaseCellItem.h"

@interface SSJFinancingHomeCell : UICollectionViewCell

@property (nonatomic,strong) SSJFinancingHomeitem *item;


@property (nonatomic,strong) UILabel *fundingBalanceLabel;


@property(nonatomic) BOOL editeModel;

//点击删除按钮的回调
typedef void (^deleteButtonClickBlock)(SSJFinancingHomeCell *cell,NSInteger chargeCount);

@property (nonatomic, copy) deleteButtonClickBlock deleteButtonClickBlock;

@end
