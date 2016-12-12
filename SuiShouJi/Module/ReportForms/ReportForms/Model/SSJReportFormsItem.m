//
//  SSJReportFormsItem.m
//  SuiShouJi
//
//  Created by old lang on 15/12/29.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsItem.h"

@implementation SSJReportFormsItem

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"scale":@(_scale),
                                                        @"money":@(_money),
                                                        @"type":@(_type),
                                                        @"imageName":(_imageName ?: @""),
                                                        @"name":(_name ?: @""),
                                                        @"colorValue":(_colorValue ?: @""),
                                                        @"ID":(_ID ?: @""),
                                                        @"isMember":@(_isMember)}];
}

@end
