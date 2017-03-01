//
//  SSJColorSelectCollectionViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingGradientColorItem.h"

@interface SSJGradientColorSelectCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) SSJFinancingGradientColorItem *itemColor;

@property (nonatomic) BOOL isSelected;

@end
