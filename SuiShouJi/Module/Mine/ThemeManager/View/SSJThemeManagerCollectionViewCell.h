//
//  SSJThemeManagerCollectionViewCell.h
//  SuiShouJi
//
//  Created by ricky on 16/7/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJThemeModel.h"

@interface SSJThemeManagerCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) SSJThemeModel *item;

@property(nonatomic) BOOL editeModel;

@end
