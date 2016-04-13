//
//  SSJCalenderTableViewNoDataHeader.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCalenderTableViewNoDataHeader : UIView

+ (id)CalenderTableViewNoDataHeader;

//点击记录按钮的回调
typedef void (^RecordMakingButtonBlock)();

@property (nonatomic, copy) RecordMakingButtonBlock RecordMakingButtonBlock;

@end
