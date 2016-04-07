//
//  SSJMagicExportCalendarViewCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarViewCellItem.h"

@implementation SSJMagicExportCalendarViewCellItem

//- (NSString *)description {
//    return [NSString stringWithFormat:@"<%@:%p>",[self class],&self];
//    NSDictionary *propertyInfo = @{@"canSelect":@(_canSelect),
//                                   @"selected":@(_selected),
//                                   @"showMarker":@(_showMarker),
//                                   @"showContent":@(_showContent),
//                                   @"date":(_date ?: [NSNull null]),
//                                   @"dateColor":(_dateColor ?: [NSNull null]),
//                                   @"desc":(_desc ?: [NSNull null])};
//    return [NSString stringWithFormat:@"%@:%@", self, propertyInfo];
//}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"canSelect":@(_canSelect),
                                                        @"selected":@(_selected),
                                                        @"showMarker":@(_showMarker),
                                                        @"showContent":@(_showContent),
                                                        @"date":(_date ?: [NSNull null]),
                                                        @"dateColor":(_dateColor ?: [NSNull null]),
                                                        @"desc":(_desc ?: [NSNull null])}];
}

@end
