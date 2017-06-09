//
//  SSJBillingChargeViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  记账流水
#import "SSJBaseViewController.h"

@class SSJDatePeriod;

NS_ASSUME_NONNULL_BEGIN

@interface SSJBillingChargeViewController : SSJBaseViewController

// --------------------------- 注意：billId、billName只需要传一个 ---------------------------//
/**
 收支类型ID，只有查询指定类别的流水必须传此参数；如果booksId为SSJAllBooksIds，则必须传此参数
 */
@property (nonatomic, copy, nullable) NSString *billId;

/**
 类别名字，只有查询指定类别名称的流水必须传此参数
 */
@property (nonatomic, copy, nullable) NSString *billName;

// ------------------------------------------------------------------------------------------------//

/**
 成员ID，只有查询指定成员的流水必须传此参数
 */
@property (nonatomic, copy, nullable) NSString *memberId;

/**
 账本id，根据此id展示哪个账本的数据，如果不传就默认展示当前账本的数据，如果传SSJAllBooksIds就展示所有账本数据
 */
@property (nonatomic, copy, nullable) NSString *booksId;

/**
 查询周期内的流水
 */
@property (nonatomic, strong) SSJDatePeriod *period;

/**
 是否是支出流水（只有是成员流水时需要传值）
 */
@property (nonatomic) BOOL isPayment;

/**
 指定是收入、支出、结余（收入＋支出）
 */
@property (nonatomic) SSJBillType billType;

@end

NS_ASSUME_NONNULL_END
