//
//  SSJBookColorSelectedCollectionViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SSJFinancingGradientColorItem;
@interface SSJBookColorSelectedCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) SSJFinancingGradientColorItem *itemColor;

/**<#注释#>*/
@property (nonatomic, assign,getter=isColorSelected) BOOL colorSelected;

@end
