//
//  SSJFinancingHomeCollectionViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingHomeitem.h"

@interface SSJFinancingHomeCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) SSJFinancingHomeitem *item;

@property (nonatomic,strong) UILabel *fundingBalanceLabel;

@end
