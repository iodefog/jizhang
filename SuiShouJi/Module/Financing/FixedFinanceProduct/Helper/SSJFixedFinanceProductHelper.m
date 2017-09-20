//
//  SSJFixedFinanceProductHelper.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductHelper.h"
#import "SSJFixedFinanceProductChargeItem.h"
#import "SSJFixedFinanceProductItem.h"
#import "SSJFixedFinanceProductStore.h"

@implementation SSJFixedFinanceProductHelper
/**
 计算每日利息
 
 @param model 借贷模型，根据rate、interestType两个属性计算利息
 @return 计算结果
 */
+ (double)caculateInterestForEveryDayWithRate:(double)rate rateType:(SSJMethodOfRateOrTime)rateType money:(double)money {
    double dayRate = rate * money;
    switch (rateType) {
        case SSJMethodOfRateOrTimeDay:
            return dayRate;
            break;
        case SSJMethodOfRateOrTimeMonth:
            return dayRate / 30;
            break;
        case SSJMethodOfRateOrTimeYear:
            return dayRate / 365;
            break;
            
        default:
            break;
    }
    return 0;
}

+ (double)caculateYuQiInterestWithProductItem:(SSJFixedFinanceProductItem *)item {
    NSArray *addAndRedemChargeItems = [SSJFixedFinanceProductStore queryFixedFinanceProductAddAndRedemChargeListWithModel:item error:nil];
    item.interesttype = SSJMethodOfInterestOncePaid;
    double interest = 0;
    double lixi = 0;
    NSDate *endDate = [item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"];
    NSDate *lastChangeDate = item.startDate;
    switch (item.timetype) {
        case SSJMethodOfRateOrTimeDay:
        {
            //天，一次性
            double investmentMoney = 0;
            NSDate *lastChangeDate = item.startDate;
            for (NSInteger i=0; i< addAndRedemChargeItems.count; i++) {
                SSJFixedFinanceProductChargeItem *chaItem = [addAndRedemChargeItems ssj_safeObjectAtIndex:i];
                
                if (chaItem.chargeType ==SSJFixedFinCompoundChargeTypeCreate) {
                    //原始本金
                    investmentMoney += chaItem.money;
                } else if (chaItem.chargeType == SSJFixedFinCompoundChargeTypeAdd) {
                    //如果变动日期已经超过结束日期的时候就返回不在计息
                    if ([chaItem.billDate isLaterThanOrEqualTo:endDate]) {
                        break;
                    }
                    
                    NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:[chaItem.billDate daysFrom:lastChangeDate] timetype:item.timetype money:investmentMoney interestType:item.interesttype startDate:@""];
                    lixi += [[interestDic objectForKey:@"interest"] doubleValue];
                    
                    investmentMoney += chaItem.money;
                    lastChangeDate = chaItem.billDate;
                    
                } else if (chaItem.chargeType == SSJFixedFinCompoundChargeTypeRedemption) {
                    //如果变动日期已经超过结束日期的时候就返回不在计息
                    if ([chaItem.billDate isLaterThanOrEqualTo:endDate]) {
                        break;
                    }
                    //赎回手续费
                    NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:[chaItem.billDate daysFrom:lastChangeDate] timetype:item.timetype money:investmentMoney interestType:item.interesttype startDate:@""];
                    lixi += [[interestDic objectForKey:@"interest"] doubleValue];
//                    double poundate = [SSJFixedFinanceProductStore queryRedemPoundageMoneyWithRedmModel:chaItem error:nil];
                    investmentMoney += chaItem.money;
//                    investmentMoney -= poundate;
                    lastChangeDate = chaItem.billDate;
                    
                }
                //当前金额
                
                
            }
            interest = lixi;
            //最后一条利息
            NSInteger days = [[item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] daysFrom:lastChangeDate];
            NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:days timetype:item.timetype money:investmentMoney interestType:item.interesttype startDate:@""];
            interest += [[interestDic objectForKey:@"interest"] doubleValue];
            
        }
            break;
            
        case SSJMethodOfRateOrTimeMonth:
        {

            
            //生成利息
            //月，一次性
            double investmentMoney = 0;
            double lixi = 0;
            NSDate *lastChangeDate = item.startDate;
            for (NSInteger i=0; i<addAndRedemChargeItems.count; i++) {
                SSJFixedFinanceProductChargeItem *chaItem = [addAndRedemChargeItems ssj_safeObjectAtIndex:i];
                
                if (chaItem.chargeType ==SSJFixedFinCompoundChargeTypeCreate) {
                    //原始本金
                    investmentMoney += chaItem.money;
                } else if (chaItem.chargeType == SSJFixedFinCompoundChargeTypeAdd) {
                    
                    NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:[chaItem.billDate daysFrom:lastChangeDate] timetype:item.timetype money:investmentMoney interestType:item.interesttype startDate:@""];
                    lixi += [[interestDic objectForKey:@"interest"] doubleValue];
                    investmentMoney += chaItem.money;
                    lastChangeDate = chaItem.billDate;
                    
                } else if (chaItem.chargeType == SSJFixedFinCompoundChargeTypeRedemption) {
                    //赎回手续费
                    NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:[chaItem.billDate daysFrom:lastChangeDate] timetype:item.timetype money:investmentMoney interestType:item.interesttype startDate:@""];
                    lixi += [[interestDic objectForKey:@"interest"] doubleValue];
//                    double poundate = [SSJFixedFinanceProductStore queryRedemPoundageMoneyWithRedmModel:chaItem error:nil];
                    investmentMoney += chaItem.money;
//                    investmentMoney -= poundate;
                    lastChangeDate = chaItem.billDate;
                    
                }
                //当前金额
                
                
            }
            interest = lixi;
            //最后一条利息
            NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:[[item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] daysFrom:lastChangeDate] timetype:SSJMethodOfRateOrTimeDay money:investmentMoney interestType:item.interesttype startDate:@""];
            interest += [[interestDic objectForKey:@"interest"] doubleValue];
            
                    }
            break;
            
        case SSJMethodOfRateOrTimeYear:
        {
                       //年，一次性（当做月来处理）
            double investmentMoney = 0;
            double lixi = 0;
            NSDate *lastChangeDate = item.startDate;
            for (NSInteger i=0; i<addAndRedemChargeItems.count; i++) {
                SSJFixedFinanceProductChargeItem *chaItem = [addAndRedemChargeItems ssj_safeObjectAtIndex:i];
                
                if (chaItem.chargeType ==SSJFixedFinCompoundChargeTypeCreate) {
                    //原始本金
                    investmentMoney += chaItem.money;
                } else if (chaItem.chargeType == SSJFixedFinCompoundChargeTypeAdd) {
                    NSInteger months = [chaItem.billDate monthsFrom:lastChangeDate];
                    NSInteger begDays = [chaItem.billDate daysFrom: [lastChangeDate dateByAddingMonths:months]];
                    ////第二个月
                    //第二个月初第一天并入第二个月
                    NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:months timetype:SSJMethodOfRateOrTimeMonth money:investmentMoney interestType:item.interesttype startDate:@""];
                    lixi += [[interestDic objectForKey:@"interest"] doubleValue];
                    
                    //分段按照天分段利息
                    NSDictionary *feninterestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:begDays timetype:SSJMethodOfRateOrTimeDay money:investmentMoney interestType:item.interesttype startDate:@""];
                    lixi += [[feninterestDic objectForKey:@"interest"] doubleValue];
                    
                    investmentMoney += chaItem.money;
                    lastChangeDate = chaItem.billDate;
                    
                } else if (chaItem.chargeType == SSJFixedFinCompoundChargeTypeRedemption) {
                    //赎回手续费
                    NSInteger months = [chaItem.billDate monthsFrom:lastChangeDate];
                    NSInteger begDays = [chaItem.billDate daysFrom: [lastChangeDate dateByAddingMonths:months]];
                    
                    ////第二个月
                    //第二个月初第一天并入第二个月
                    NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:months timetype:SSJMethodOfRateOrTimeMonth money:investmentMoney interestType:item.interesttype startDate:@""];
                    lixi += [[interestDic objectForKey:@"interest"] doubleValue];
                    
                    //分段按照天分段利息
                    NSDictionary *feninterestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:begDays timetype:SSJMethodOfRateOrTimeDay money:investmentMoney interestType:item.interesttype startDate:@""];
                    lixi += [[feninterestDic objectForKey:@"interest"] doubleValue];
                    
                    //手续费
//                    double poundate = [SSJFixedFinanceProductStore queryRedemPoundageMoneyWithRedmModel:chaItem error:nil];
                    
                    investmentMoney += chaItem.money;
//                    investmentMoney -= poundate;
                    lastChangeDate = chaItem.billDate;
                }
            }
            
            interest = lixi;
            BOOL hasno = [SSJFixedFinanceProductStore queryIsChangeMoneyWithProductModel:item];
            //最后一条利息
            NSDate *endDate = [item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"];
            NSInteger months = [endDate daysFrom:lastChangeDate];
            NSInteger begDays = [endDate daysFrom: [lastChangeDate dateByAddingMonths:months]];
            NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:hasno ? item.time : months timetype:hasno ? item.timetype : SSJMethodOfRateOrTimeMonth money:investmentMoney interestType:item.interesttype startDate:@""];
            
            interest += [[interestDic objectForKey:@"interest"] doubleValue];
        }
            break;
            
        default:
            break;
    }
    return interest;
}

/**
 计算预期利息
 此处，利率和期限的组合方式有9种，1-3种是年-年，月-月，日-日，这三种直接相乘即可。
 4、5种是利率年-期限月，利率年-期限日，预期利息=本金*年利率*月数/12, 预期利息=
 本金*年利率*天数/365,
 6、7种是利率月-期限年，利率月-期限日，预期利息=本金*月利率*年数*12，预期利息=本金*月利率*天数/30，
 8、9年是利率日-期限年，利率日-期限月，预期利息=本金*日利率*年数*365，预期利息=本金*日利率*月数*30
 
 @param rate 利率
 @param rateType 利率类型（年，月，日）
 @param time 期限
 @param timeType 期限类型（年，月，日）
 @param money 本金
 @param interesttype 气息方式
 @param startDate 气息时间
 @return 预期利息key：interest，key：desc
 */
+ (NSDictionary *)caculateYuQiInterestWithRate:(double)rate rateType:(SSJMethodOfRateOrTime)rateType time:(double)time timetype:(SSJMethodOfRateOrTime)timeType money:(double)money interestType:(SSJMethodOfInterest)interesttype startDate:(NSString *)startDate {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    double interest = 0;
    NSString *desc = @"";
    if (rateType == SSJMethodOfRateOrTimeDay) {//利率
        switch (timeType) {
            case SSJMethodOfRateOrTimeDay:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * rate * money;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 30;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }
                break;
            case SSJMethodOfRateOrTimeMonth:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * 30 * rate * money;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 30;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeYear:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * 365 * rate * money;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 30;
                        desc = [NSString stringWithFormat:@"预期每月10号该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }//期限
        [dict setValue:[NSString stringWithFormat:@"%.2f",interest] forKey:@"interest"];
        [dict setValue:desc forKey:@"desc"];
        return dict;
    } else if (rateType == SSJMethodOfRateOrTimeMonth) {
        switch (timeType) {
            case SSJMethodOfRateOrTimeDay:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = (time / 30) * rate * money;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate / 30;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeMonth:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * rate * money / 30;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate / 30;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeYear:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * rate * 12 * money;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate / 30;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            default:
                break;
        }
        [dict setValue:[NSString stringWithFormat:@"%.2f",interest] forKey:@"interest"];
        [dict setValue:desc forKey:@"desc"];
        return dict;

    
    } else if (rateType == SSJMethodOfRateOrTimeYear) {
        switch (timeType) {
            case SSJMethodOfRateOrTimeDay:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * rate * money / 365;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate / 365;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate / 12;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeMonth:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * (rate / 12) * money;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * (rate / 365);
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = (rate / 12) * money;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeYear:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * rate * money;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate / 365;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate / 12;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            default:
                break;
        }
        [dict setValue:[NSString stringWithFormat:@"%.2f",interest] forKey:@"interest"];
        [dict setValue:desc forKey:@"desc"];
        return dict;

    }
    [dict setValue:@"0.00" forKey:@"interest"];
    [dict setValue:@"" forKey:@"desc"];
    return dict;
}


//money,interest
+ (NSMutableDictionary *)caculateInterestWithModel:(SSJFixedFinanceProductItem *)item chargeModels:(NSArray <SSJFixedFinanceProductChargeItem *>*)models {
    if (models.count == 0) return 0;
    if ([item.startDate isSameDay:[NSDate date]]) return 0;//如果是新建当日还没有利息
    
    //如果已到期则产生产生流水为预期流水相当于一次性返回得到的金额
    NSDate *startDate = item.startDate;//[item.startDate dateByAddingDays:1];//开始时间
    double money = 0;
    double interest = 0;
    double surplus = 0;
    NSDate *currentDate;
    for (SSJFixedFinanceProductChargeItem *model in models) {
        switch (model.chargeType) {
            case SSJFixedFinCompoundChargeTypeCreate://新建
            {
                money += model.money;
                surplus += [self caculateInterestUntilDate:model.billDate startDate:startDate model:item money:money];
                currentDate = model.billDate;
            }
                
                break;
            case SSJFixedFinCompoundChargeTypeAdd://追加
            {
                money += model.money;
                surplus += [self caculateInterestUntilDate:model.billDate startDate:currentDate model:item money:money];
                currentDate = model.billDate;
//                startDate = currentDate;
            }
                break;
            case SSJFixedFinCompoundChargeTypeRedemption://赎回
            {
                money -= model.money;
                
                surplus += [self caculateInterestUntilDate:model.billDate startDate:currentDate model:item money:money];
                currentDate = model.billDate;
//                startDate = currentDate;
            }
//                break;
//            case SSJFixedFinCompoundChargeTypeBalanceIncrease://余额转入
//            {
//                money += model.money;
//                
//                surplus += [self caculateInterestUntilDate:model.billDate startDate:currentDate model:item money:money];
//                currentDate = model.billDate;
////                startDate = currentDate;
//            }
//                break;
//            case SSJFixedFinCompoundChargeTypeBalanceDecrease://余额转出
//            {
//                money += model.money;
//                
//                surplus += [self caculateInterestUntilDate:model.billDate startDate:currentDate model:item money:money];
//                currentDate = model.billDate;
////                startDate = currentDate;
//            }
                break;
            case SSJFixedFinCompoundChargeTypeCloseOutInterest://结算,赎回利息
            {
                money += model.money;
                surplus += [self caculateInterestUntilDate:model.billDate startDate:currentDate model:item money:money];
//                startDate = currentDate;
                currentDate = model.billDate;
            }
                break;
            default:
                break;
        }
    }
    
    //计算最后一条流水产生的利息
    surplus += [self caculateInterestUntilDate:[[NSDate date] dateBySubtractingDays:1] startDate:currentDate model:item money:money];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(money) forKey:@"money"];
    [dic setObject:@(surplus) forKey:@"interest"];
    //计算利息
    return dic;
}


/**
 已产生计算利息
 */
+ (double)caculateInterestUntilDate:(NSDate *)untilDate startDate:(NSDate *)beginDate model:(SSJFixedFinanceProductItem *)item money:(double)money {
    if ([untilDate isSameDay:beginDate]) return 0;
    double interest = 0;
    NSDate *startDate = item.startDate;//开始时间
    if (item.timetype == SSJMethodOfInterestEveryMonth) {//月
        if ([[NSDate date] isLaterThan:[startDate dateByAddingMonths:item.time]]) {//到期
            interest = [[[self caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:item.time timetype:item.timetype money:money interestType:(SSJMethodOfInterestOncePaid) startDate:item.startdate] objectForKey:@"interest"] doubleValue];
        } else {
            //按天计算
            interest = [self caculateInterestForEveryDayWithRate:item.rate rateType:item.ratetype money:money] * [untilDate daysFrom:beginDate];
        }
    } else if (item.timetype == SSJMethodOfRateOrTimeYear) {//年
        if ([[NSDate date] isLaterThan:[startDate dateByAddingYears:item.time]]) {//到期相当于一次性
            interest = [[[self caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:item.time timetype:item.timetype money:money interestType:(SSJMethodOfInterestOncePaid) startDate:item.startdate] objectForKey:@"interest"] doubleValue];
        } else {
            //按天计算
            interest = [self caculateInterestForEveryDayWithRate:item.rate rateType:item.ratetype money:money] * [untilDate daysFrom:beginDate];
        }
    } else if (item.timetype == SSJMethodOfRateOrTimeDay) {//天
        if ([[NSDate date] isLaterThan:[startDate dateByAddingDays:item.time]]) {//到期相当于一次性//到期
            interest = [[[self caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:item.time timetype:item.timetype money:money interestType:(SSJMethodOfInterestOncePaid) startDate:item.startdate] objectForKey:@"interest"] doubleValue];
        } else {
            //按天计算
            interest = [self caculateInterestForEveryDayWithRate:item.rate rateType:item.ratetype money:money] * [untilDate daysFrom:beginDate];
        }
    }
    return interest;
}

- (double)calculateInterestWithMoney:(double)money rate:(double)rate interesttype:(SSJMethodOfInterest)interesttype timetype:(SSJMethodOfRateOrTime)timetype {
    switch (interesttype) {
        case SSJMethodOfInterestEveryDay:
            switch (timetype) {
                case SSJMethodOfRateOrTimeDay:
                    
                    break;
                case SSJMethodOfRateOrTimeMonth:
                    
                    break;
                case SSJMethodOfRateOrTimeYear:
                    
                    break;
                    
                default:
                    break;
            }
            break;
        case SSJMethodOfInterestEveryMonth:
            switch (timetype) {
                case SSJMethodOfRateOrTimeDay:
                    
                    break;
                case SSJMethodOfRateOrTimeMonth:
                    
                    break;
                case SSJMethodOfRateOrTimeYear:
                    
                    break;
                    
                default:
                    break;
            }
            
            break;
        case SSJMethodOfInterestOncePaid:
            switch (timetype) {
                case SSJMethodOfRateOrTimeDay:
                    
                    break;
                case SSJMethodOfRateOrTimeMonth:
                    
                    break;
                case SSJMethodOfRateOrTimeYear:
                    
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    return 0;
}

+ (int)chargeIdWithModel:(SSJFixedFinanceProductChargeItem *)model {
    int suindex = 0;
        switch (model.chargeType) {
            case SSJFixedFinCompoundChargeTypeCreate://新建
                suindex = 3;
                break;
            case SSJFixedFinCompoundChargeTypeAdd://追加
                suindex = 3;
                break;
            case SSJFixedFinCompoundChargeTypeRedemption://赎回
                suindex = 3;
                break;
//            case SSJFixedFinCompoundChargeTypeBalanceIncrease://余额转入
//                suindex = 3;
//                break;
//            case SSJFixedFinCompoundChargeTypeBalanceDecrease://余额转出
//                suindex = 3;
//                break;
            case SSJFixedFinCompoundChargeTypeBalanceInterestIncrease://利息转入
                suindex = 3;;
                break;
            case SSJFixedFinCompoundChargeTypeBalanceInterestDecrease://利息转出
                suindex = 3;
                break;
            case SSJFixedFinCompoundChargeTypeInterest://固收理财派发利息流水
                suindex = 3;
                break;
                
            case SSJFixedFinCompoundChargeTypeCloseOutInterest://结算利息
                suindex = 3;
                break;
            case SSJFixedFinCompoundChargeTypeCloseOut://结清
                break;
                suindex = 3;
            default:
                break;
        }
    return suindex;
}


+ (NSDate *)endDateWithStartDate:(NSDate *)startDate time:(NSInteger)time timeType:(SSJMethodOfRateOrTime)timeType {
    switch (timeType) {
        case SSJMethodOfRateOrTimeDay:
            return [startDate dateByAddingDays:time];
            break;
        case SSJMethodOfRateOrTimeMonth:
            return [startDate dateByAddingMonths:time];
            break;
        case SSJMethodOfRateOrTimeYear:
            return [startDate dateByAddingYears:time];
            break;
            
        default:
            break;
    }
}


- (NSInteger)getDifferenceWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
//    [endDate dateByAddingDays:<#(NSInteger)#>]
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:startDate toDate:endDate options:0];
    return [comps day];
}

@end
