//
//  SSJFixedFinanceProductHelper.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductHelper.h"

@implementation SSJFixedFinanceProductHelper
/**
 计算每日利息
 
 @param model 借贷模型，根据rate、interestType两个属性计算利息
 @return 计算结果
 */
+ (double)caculateInterestForEveryDayWithRate:(double)rate rateType:(SSJMethodOfRateOrTime)rateType money:(double)money {
    double dayRate = rate * money * 0.01;
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
                        interest = time * rate * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate * 0.01;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 30 * 0.01;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }
                break;
            case SSJMethodOfRateOrTimeMonth:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * 30 * rate * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate * 0.01;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 30 * 0.01;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeYear:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * 365 * rate * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate * 0.01;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 30 * 0.01;
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
                        interest = (time / 30) * rate * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate * 0.01 / 30;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 0.01;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeMonth:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * rate * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate * 0.01 / 30;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 0.01;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeYear:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * rate * 12 * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate * 0.01 / 12;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 0.01;
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
                        interest = time * rate * money * 0.01 / 365;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate * 0.01 / 365;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 0.01 / 12;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeMonth:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * (rate / 12) * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * (rate / 365) * 0.01;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = (rate / 12) * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期每月该账户将生成%.2f元的利息流水",interest];
                        break;
                    default:
                        break;
                }

                break;
            case SSJMethodOfRateOrTimeYear:
                switch (interesttype) {
                    case SSJMethodOfInterestOncePaid://一次性
                        interest = time * rate * money * 0.01;
                        desc = [NSString stringWithFormat:@"预期到期利息为%.2f元",interest];
                        break;
                    case SSJMethodOfInterestEveryDay:
                        interest = money * rate * 0.01 / 365;
                        desc = [NSString stringWithFormat:@"预期每天该账户将生成%.2f元的利息流水",interest];
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        interest = money * rate * 0.01 / 12;
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

@end
