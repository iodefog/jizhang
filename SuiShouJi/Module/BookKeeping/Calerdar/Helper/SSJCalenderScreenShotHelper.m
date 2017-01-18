//
//  SSJCalenderScreenShotHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/1/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalenderScreenShotHelper.h"

@implementation SSJCalenderScreenShotHelper

+ (UIImage *)screenShotForCalenderWithCellImage:(UIImage *)image Date:(NSDate *)date income:(double)income expence:(double)expence{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *headerImage = [UIImage imageNamed:@""];
        UIImage *qrImage = [UIImage imageNamed:@""];
        UIImage *backImage = [UIImage ssj_themeImageWithName:@"background"];
        double width = image.size.width;
        // 调整两张图的宽和高
        double headerImageHeight = headerImage.size.height * width / headerImage.size.width;
        double qrImageHeight = qrImage.size.height * width / qrImage.size.width;
        double wholeHeight = MAX(headerImageHeight + qrImageHeight + image.size.height + 48, SSJSCREENWITH);
        [headerImage ssj_scaleImageWithSize:CGSizeMake(width, headerImageHeight)];
        [qrImage ssj_scaleImageWithSize:CGSizeMake(width, qrImageHeight)];
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
        
        // 写上日期
        NSString *dateStr = [date formattedDateWithFormat:@"MM/dd"];
        CGSize dateSize = [dateStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21]}];
        [dateStr drawInRect:CGRectMake(0, 0, 0, 0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];
        
        // 写上星期
        NSString *weekDayStr = [NSString stringWithFormat:@"%@",[self stringFromWeekday:date.weekday]];
        CGSize weekDaySize = [weekDayStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21]}];
        [weekDayStr drawInRect:CGRectMake(0, 0, 0, 0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];

        // 写上年份
        NSString *yearStr = [NSString stringWithFormat:@"%04ld",(long)date.year];
        CGSize yearSize = [yearStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21]}];
        [weekDayStr drawInRect:CGRectMake(0, 0, 0, 0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];
        
        
        UIGraphicsEndImageContext();
    });
    return nil;
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
