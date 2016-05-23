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

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", @{@"ID":(_ID ?: [NSNull null]),
                                               @"title":(_title ?: [NSNull null]),
                                               @"imageName":(_imageName ?: [NSNull null]),
                                               @"colorValue":(_colorValue ?: [NSNull null]),
                                               @"selected":@(_selected),
                                               @"editable":@(_editable),
                                               @"animated":@(_animated)}];
}

@end
