//
//  SSJRecordMakingBillTypeSelectionCellItem.m
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeSelectionCellItem.h"

@implementation SSJRecordMakingBillTypeSelectionCellItem

+ (instancetype)itemWithTitle:(NSString *)title imageName:(NSString *)imageName colorValue:(NSString *)colorValue ID:(NSString *)ID {
    SSJRecordMakingBillTypeSelectionCellItem *item = [[SSJRecordMakingBillTypeSelectionCellItem alloc] init];
    item.title = title;
    item.imageName = imageName;
    item.colorValue = colorValue;
    item.ID = ID;
    return item;
}

@end
