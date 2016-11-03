//
//  SSJLoanDetailCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDetailCellItem.h"

@implementation SSJLoanDetailCellItem

+ (instancetype)itemWithImage:(NSString *)image
                        title:(NSString *)title
                     subtitle:(NSString *)subtitle {
    
    SSJLoanDetailCellItem *item = [[SSJLoanDetailCellItem alloc] init];
    item.image = image;
    item.title = title;
    item.subtitle = subtitle;
    return item;
}

@end
