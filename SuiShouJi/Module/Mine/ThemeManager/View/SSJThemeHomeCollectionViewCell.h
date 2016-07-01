//
//  SSJThemeHomeCollectionViewCell.h
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJThemeItem.h"

@interface SSJThemeHomeCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong) SSJThemeItem *item;

-(float)cellHeight;
@end
