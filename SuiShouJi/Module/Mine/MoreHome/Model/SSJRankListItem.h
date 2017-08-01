//
//  SSJRankListItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJRankListItem : SSJBaseCellItem

/**用户ID*/
@property (nonatomic, copy) NSString *cuserid;

/**打赏备注*/
@property (nonatomic, copy) NSString *memo;

/**用户名*/
@property (nonatomic, copy) NSString *crealname;

/**用户头像地址*/
@property (nonatomic, copy) NSString *cicon;

/**个人累计打赏金额*/
@property (nonatomic, copy) NSString *summoney;

/**打赏榜名次*/
@property (nonatomic, copy) NSString *ranking;
@end
