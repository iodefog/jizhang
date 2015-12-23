//
//  SSJFundingTypeSelectView.h
//  SuiShouJi
//
//  Created by ricky on 15/12/23.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJFundingTypeSelectView : UIView<UITableViewDataSource,UITableViewDelegate>

typedef void (^fundingTypeSelectBlock)(NSString *fundingTitle);

//选择类型的回调
@property (nonatomic, copy) fundingTypeSelectBlock fundingTypeSelectBlock;

@end
