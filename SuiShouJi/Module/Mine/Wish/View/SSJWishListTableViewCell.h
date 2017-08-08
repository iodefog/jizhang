//
//  SSJWishListTableViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
@class SSJWishModel;

static CGFloat defImageWidth = 750;
static CGFloat defImageHeight = 402;
#define kFinalImgHeight(width) ((width) * defImageHeight / defImageWidth)


@interface SSJWishListTableViewCell : SSJBaseTableViewCell


+ (SSJWishListTableViewCell *)cellWithTableView:(UITableView *)tableView animation:(BOOL)animation;

typedef void(^SSJWishSaveMoneyBlock)(SSJWishModel *item);
@property (nonatomic, copy) SSJWishSaveMoneyBlock wishSaveMoneyBlock;
@end
