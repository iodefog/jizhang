//
//  SSJThemeModel.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeModel.h"

@implementation SSJThemeModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_ID forKey:@"ID"];
    [aCoder encodeObject:_name forKey:@"name"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _ID = [aDecoder decodeObjectForKey:@"ID"];
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@>:%@", self, @{@"ID":_ID,
                                                          @"name":_name,
                                                          @"previewUrlStr":_previewUrlStr,
                                                          @"size":@(_size),
                                                          @"mainTitleColor":_mainTitleColor,
                                                          @"tabBarTitleColor":_tabBarTitleColor,
                                                          @"tabBarSelectedTitleColor":_tabBarSelectedTitleColor,
                                                          @"naviBarTitleAlpha":@(_naviBarTitleAlpha),
                                                          @"naviBarTintColor":_naviBarTintColor,
                                                          @"naviBarBackgroundColor":_naviBarBackgroundColor,
                                                          @"cellSeparatorColor":_cellSeparatorColor,
                                                          @"cellIndicatorColor":_cellIndicatorColor,
                                                          @"recordHomeCalendarTitleColor":_recordHomeCalendarTitleColor,
                                                          @"recordHomeCircleBorderColor":_recordHomeCircleBorderColor,
                                                          @"recordHomeBudgetLabelTitleAlpha":@(_recordHomeBudgetLabelTitleAlpha),
                                                          @"recordHomeBudgetLabelBorderAlpha":@(_recordHomeBudgetLabelBorderAlpha),
                                                          @"recordHomeIncomeAndPayTitleAlpha":@(_recordHomeIncomeAndPayTitleAlpha),
                                                          @"recordHomeIncomeAndPayValueAlpha":@(_recordHomeIncomeAndPayValueAlpha),
                                                          @"recordHomeListDateAlpha":@(_recordHomeListDateAlpha),
                                                          @"recordHomeListDateAmountAlpha":@(_recordHomeListDateAmountAlpha),
                                                          @"recordHomeListChargeTitleAlpha":@(_recordHomeListChargeTitleAlpha),
                                                          @"recordHomeListChargeMemoAlpha":@(_recordHomeListChargeMemoAlpha)}];
}

@end
