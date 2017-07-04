//
//  SSJPersonalDetailUserNicknameCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJPersonalDetailUserNicknameCell : SSJBaseTableViewCell

@end

@interface SSJPersonalDetailUserNicknameCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *nickname;

+ (instancetype)itemWithNickname:(NSString *)nickname;

@end
