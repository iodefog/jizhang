//
//  SSJCalenderScreenShotHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/1/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalenderScreenShotHelper.h"

@implementation SSJCalenderScreenShotHelper

+ (void)screenShotForCalenderWithCellImage:(UIImage *)image Date:(NSDate *)date income:(double)income expence:(double)expence imageBlock:(void (^)(UIImage *image))imageBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *shareImage = nil;
        
        UIImage *headerImage = [UIImage imageNamed:@"calendar_shareheader"];
        
        UIImage *qrImage = [UIImage imageNamed:@"calendar_qrImage"];
        
        UIImage *backImage = [UIImage ssj_themeImageWithName:@"background"];
        
        double width = image.size.width;
        
        // 调整两张图的宽和高
        double headerImageHeight = headerImage.size.height * width / headerImage.size.width;
        double wholeHeight = MAX(headerImageHeight + 130 + image.size.height + 48, SSJSCREENWITH);
        [headerImage ssj_scaleImageWithSize:CGSizeMake(width, headerImageHeight)];
        [backImage ssj_scaleImageWithSize:CGSizeMake(SSJSCREENWITH, SSJSCREENHEIGHT)];

        // 开始绘制
        UIGraphicsBeginImageContext(CGSizeMake(width, wholeHeight));
        
        // 首先绘制背景图片
        [backImage drawInRect:CGRectMake(0, 0, width, backImage.size.height)];
        
        // 如果长度超过总长度,则在下面补充纯色背景
        if (wholeHeight > backImage.size.height) {
            UIImage *colorImage = [UIImage ssj_imageWithColor:[backImage ssj_getPixelColorAtLocation:CGPointMake(backImage.size.width, backImage.size.height)] size:CGSizeMake(backImage.size.width, wholeHeight - backImage.size.height)];
            [colorImage drawInRect:CGRectMake(0, wholeHeight - SSJSCREENHEIGHT, width, wholeHeight - backImage.size.height)];
        }
        
        // 绘制第一张图
        [headerImage drawInRect:CGRectMake(0, 0, width, headerImageHeight)];
        
        float firstImageCenterX = CGRectGetMidX(CGRectMake(0, 0, width, headerImageHeight));
        float firstImageCenterY = CGRectGetMidY(CGRectMake(0, 0, width, headerImageHeight));
        
        // 写上日期
        NSString *dateStr = [date formattedDateWithFormat:@"MM/dd"];
        CGSize dateSize = [dateStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21]}];
        
        [dateStr drawInRect:CGRectMake(firstImageCenterX - 10 - dateSize.width, firstImageCenterY - dateSize.height / 2, dateSize.width, dateSize.width) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];

        
        // 写上星期
        NSString *weekDayStr = [NSString stringWithFormat:@"%@",[self stringFromWeekday:date.weekday]];
        CGSize weekDaySize = [weekDayStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21]}];
        [weekDayStr drawInRect:CGRectMake(firstImageCenterX + 10, firstImageCenterY - weekDaySize.height / 2, weekDaySize.width, weekDaySize.width) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];

        // 写上年份
        NSString *yearStr = [NSString stringWithFormat:@"%04ld",(long)date.year];
        CGSize yearSize = [yearStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21]}];
        [weekDayStr drawInRect:CGRectMake(firstImageCenterY + dateSize.height / 2 + 15, firstImageCenterX - dateSize.width / 2 - 10 - yearSize.width / 2, yearSize.height, yearSize.width) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];
        
        // 写上总收入
        NSString *incomeTitleStr = @"总收入:";
        CGSize incomeTitleSize = [incomeTitleStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        [incomeTitleStr drawInRect:CGRectMake(10, headerImageHeight + 25 - incomeTitleSize.height / 2, incomeTitleSize.width, incomeTitleSize.height) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

        // 写上收入金额
        NSString *incomeStr = [[NSString stringWithFormat:@"%f",income] ssj_moneyDecimalDisplayWithDigits:2];
        CGSize incomeSize = [incomeStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        [incomeStr drawInRect:CGRectMake(10 + incomeTitleSize.width + 5, headerImageHeight + 25 - incomeSize.height / 2, incomeSize.width, incomeSize.height) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor]}];
        
        // 写上支出金额
        NSString *expenceStr = [[NSString stringWithFormat:@"%f",expence] ssj_moneyDecimalDisplayWithDigits:2];
        CGSize expenceSize = [expenceStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        [expenceStr drawInRect:CGRectMake(width - expenceSize.width - 10, headerImageHeight + 25 - expenceSize.height / 2, expenceSize.width, expenceSize.height) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor]}];
        
        // 写上总支出
        NSString *expenceTitleStr = @"总支出:";
        CGSize expenceTitleSize = [expenceTitleStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        [expenceTitleStr drawInRect:CGRectMake(width - expenceSize.width - 15 - expenceTitleSize.width, headerImageHeight + 25 - expenceTitleSize.height / 2, expenceTitleSize.width, expenceTitleSize.height) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        
        
        // 把cell的截图画上去
        [image drawInRect:CGRectMake(0, headerImageHeight + 50, width, image.size.height)];
        
        // 把二维码的图画上去
        [qrImage drawInRect:CGRectMake(width / 2 - qrImage.size.width / 2, wholeHeight - 65 - qrImage.size.height / 2, expenceSize.width, expenceSize.height)];
        
        // 把二维码下面的字写上去
        NSString *qrStr = @"长按识别图中二维码,下载有鱼记账";
        CGSize qrStrSize = [qrStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        [qrStr drawInRect:CGRectMake((width - qrStrSize.width) / 2, wholeHeight - 65 - qrStrSize.height / 2, qrStrSize.width, qrStrSize.height) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

        shareImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        SSJDispatch_main_async_safe(^{
            imageBlock(shareImage);
        });
    });
}

+ (NSString *)stringFromWeekday:(NSInteger)weekday {
    switch (weekday) {
        case 1: return @"星期日";
        case 2: return @"星期一";
        case 3: return @"星期二";
        case 4: return @"星期三";
        case 5: return @"星期四";
        case 6: return @"星期五";
        case 7: return @"星期六";
            
        default: return nil;
    }
}

@end
