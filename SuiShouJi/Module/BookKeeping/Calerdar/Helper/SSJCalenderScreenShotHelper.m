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
        double width = image.size.width;
        double headerImageHeight = headerImage.size.height * width / headerImage.size.width;
        double qrImageHeight = qrImage.size.height * width / qrImage.size.width;
        double wholeHeight = headerImageHeight + qrImageHeight + image.size.height + 48;
        [headerImage ssj_scaleImageWithSize:CGSizeMake(width, headerImageHeight)];
        [qrImage ssj_scaleImageWithSize:CGSizeMake(width, qrImageHeight)];
        UIGraphicsBeginImageContext(CGSizeMake(width, wholeHeight));
        [headerImage drawInRect:CGRectMake(0, 0, width, headerImageHeight)];
        NSString *dateStr = [NSString stringWithFormat:@""];
        [dateStr drawInRect:CGRectMake(0, 0, 0, 0) withAttributes:@{}];
        UIGraphicsEndImageContext();
    });
    return nil;
}

@end
