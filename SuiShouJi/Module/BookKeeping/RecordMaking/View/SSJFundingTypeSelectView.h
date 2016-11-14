//
//  SSJFundingTypeSelectView.h
//  SuiShouJi
//
//  Created by ricky on 15/12/23.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFundingItem.h"

@interface SSJFundingTypeSelectView : UIView<UITableViewDataSource,UITableViewDelegate>

typedef void (^fundingTypeSelectBlock)(SSJFundingItem *item);

@property (nonatomic,strong) NSString *selectFundID;

//选择类型的回调
@property (nonatomic, copy) fundingTypeSelectBlock fundingTypeSelectBlock;

@property(nonatomic, strong) NSDate *maxDate;

@property(nonatomic, strong) NSDate *minimumDate;

@property (nonatomic, copy) void(^dismissBlock)();

-(void)reloadDate;

- (void)show;

- (void)dismiss;

@end
