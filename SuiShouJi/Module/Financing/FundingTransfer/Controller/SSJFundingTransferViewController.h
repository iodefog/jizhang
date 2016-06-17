//
//  SSJFundingTransferViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJFundingTransferDetailItem.h"

@interface SSJFundingTransferViewController : SSJBaseViewController<UITextFieldDelegate>
@property(nonatomic, strong) SSJFundingTransferDetailItem *item;

//完成编辑的回调
typedef void (^editeCompleteBlock)(SSJFundingTransferDetailItem *item);

@property (nonatomic, copy) editeCompleteBlock editeCompleteBlock;
@end
