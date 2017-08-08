//
//  SSJWishWithdrawMoneyViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
@class SSJWishModel;
typedef enum : NSUInteger {
    SSJSaveMoneyTypeNormal, //从心愿进度中进入
    SSJSaveMoneyTypeList //从心愿列表进入
} SSJSaveMoneyType;

@interface SSJWishWithdrawMoneyViewController : SSJBaseViewController

@property (nonatomic, strong) SSJWishModel *wishModel;

/**进入页面类型*/
@property (nonatomic, assign) SSJSaveMoneyType saveMoneyType;

//SSJWishChargeBillTypeSave,          //存钱
//SSJWishChargeBillTypeWithdraw       //取钱
@property (nonatomic, assign) SSJWishChargeBillType itype;

@end
