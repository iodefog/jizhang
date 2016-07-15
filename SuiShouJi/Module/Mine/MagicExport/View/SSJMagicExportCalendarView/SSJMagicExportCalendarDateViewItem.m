//
//  SSJMagicExportCalendarViewCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarDateViewItem.h"

@implementation SSJMagicExportCalendarDateViewItem

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"hidden":@(_hidden),
                                                        @"selected":@(_selected),
                                                        @"showMarker":@(_showMarker),
                                                        @"date":(_date ?: [NSNull null]),
                                                        @"desc":(_desc ?: [NSNull null]),
                                                        @"dateColor":(_dateColor ?: [NSNull null]),
                                                        @"selectedDateColor":(_selectedDateColor ?: [NSNull null]),
                                                        @"highlightColor":(_highlightColor ?: [NSNull null])}];
}

- (void)setHidden:(BOOL)hidden {
    _hidden = hidden;
    if (_hidden) {
        
    }
}

@end
