//
//  SSJPersonalDetailUserIconCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJPersonalDetailUserIconCell : SSJBaseTableViewCell

@end

@interface SSJPersonalDetailUserIconCellItem : SSJBaseCellItem

@property (nonatomic, strong) NSURL *userIconUrl;

+ (instancetype)itemWithIconUrl:(NSURL *)url;

@end
