//
//  SSJFundingTypeSelectView.h
//  SuiShouJi
//
//  Created by ricky on 15/12/23.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingHomeitem.h"

@interface SSJFundingTypeSelectView : UIView<UITableViewDataSource,UITableViewDelegate>

typedef void (^fundingTypeSelectBlock)(SSJFinancingHomeitem *item);

@property (nonatomic,strong) NSString *selectFundID;

//选择类型的回调
@property (nonatomic, copy) fundingTypeSelectBlock fundingTypeSelectBlock;
    
@property(nonatomic) BOOL needCreditOrNot;

@property (nonatomic, copy) void(^dismissBlock)();

@property(nonatomic, strong) NSArray *exceptionIDs;

-(void)reloadDate;

- (void)show;

- (void)dismiss;

@end
