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
    [aCoder encodeFloat:_size forKey:@"size"];
    [aCoder encodeObject:_previewUrlStr forKey:@"previewUrlStr"];
    [aCoder encodeFloat:_backgroundAlpha forKey:@"backgroundAlpha"];
    [aCoder encodeObject:_mainColor forKey:@"mainColor"];
    [aCoder encodeObject:_secondaryColor forKey:@"secondaryColor"];
    [aCoder encodeObject:_marcatoColor forKey:@"marcatoColor"];
    [aCoder encodeObject:_mainFillColor forKey:@"mainFillColor"];
    [aCoder encodeObject:_secondaryFillColor forKey:@"secondaryFillColor"];
    [aCoder encodeObject:_borderColor forKey:@"borderColor"];
    [aCoder encodeObject:_buttonColor forKey:@"buttonColor"];
    [aCoder encodeObject:_naviBarTitleColor forKey:@"naviBarTitleColor"];
    [aCoder encodeObject:_naviBarTintColor forKey:@"naviBarTintColor"];
    [aCoder encodeObject:_naviBarBackgroundColor forKey:@"naviBarBackgroundColor"];
    [aCoder encodeObject:_tabBarTitleColor forKey:@"tabBarTitleColor"];
    [aCoder encodeObject:_tabBarSelectedTitleColor forKey:@"tabBarSelectedTitleColor"];
    [aCoder encodeObject:_tabBarBackgroundColor forKey:@"tabBarBackgroundColor"];
    [aCoder encodeFloat:_cellSeparatorAlpha forKey:@"cellSeparatorAlpha"];
    [aCoder encodeObject:_cellSeparatorColor forKey:@"cellSeparatorColor"];
    [aCoder encodeObject:_cellIndicatorColor forKey:@"cellIndicatorColor"];
    [aCoder encodeObject:_moreHomeTitleColor forKey:@"moreHomeTitleColor"];
    [aCoder encodeObject:_moreHomeSubtitleColor forKey:@"moreHomeSubtitleColor"];
    [aCoder encodeObject:_recordHomeBorderColor forKey:@"recordHomeBorderColor"];
    [aCoder encodeObject:_recordHomeCalendarColor forKey:@"recordHomeCalendarColor"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _ID = [aDecoder decodeObjectForKey:@"ID"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _size = [aDecoder decodeFloatForKey:@"size"];
        _previewUrlStr = [aDecoder decodeObjectForKey:@"previewUrlStr"];
        _backgroundAlpha = [aDecoder decodeFloatForKey:@"backgroundAlpha"];
        _mainColor = [aDecoder decodeObjectForKey:@"mainColor"];
        _secondaryColor = [aDecoder decodeObjectForKey:@"secondaryColor"];
        _marcatoColor = [aDecoder decodeObjectForKey:@"marcatoColor"];
        _mainFillColor = [aDecoder decodeObjectForKey:@"mainFillColor"];
        _secondaryFillColor = [aDecoder decodeObjectForKey:@"secondaryFillColor"];
        _borderColor = [aDecoder decodeObjectForKey:@"borderColor"];
        _buttonColor = [aDecoder decodeObjectForKey:@"buttonColor"];
        _naviBarTitleColor = [aDecoder decodeObjectForKey:@"naviBarTitleColor"];
        _naviBarTintColor = [aDecoder decodeObjectForKey:@"naviBarTintColor"];
        _naviBarBackgroundColor = [aDecoder decodeObjectForKey:@"naviBarBackgroundColor"];
        _tabBarTitleColor = [aDecoder decodeObjectForKey:@"tabBarTitleColor"];
        _tabBarSelectedTitleColor = [aDecoder decodeObjectForKey:@"tabBarSelectedTitleColor"];
        _tabBarBackgroundColor = [aDecoder decodeObjectForKey:@"tabBarBackgroundColor"];
        _cellSeparatorAlpha = [aDecoder decodeFloatForKey:@"cellSeparatorAlpha"];
        _cellSeparatorColor = [aDecoder decodeObjectForKey:@"cellSeparatorColor"];
        _cellIndicatorColor = [aDecoder decodeObjectForKey:@"cellIndicatorColor"];
        _moreHomeTitleColor = [aDecoder decodeObjectForKey:@"moreHomeTitleColor"];
        _moreHomeSubtitleColor = [aDecoder decodeObjectForKey:@"moreHomeSubtitleColor"];
        _recordHomeBorderColor = [aDecoder decodeObjectForKey:@"recordHomeBorderColor"];
        _recordHomeCalendarColor = [aDecoder decodeObjectForKey:@"recordHomeCalendarColor"];
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@>:%@", self, @{@"ID":_ID,
                                                          @"name":_name,
                                                          @"size":@(_size),
                                                          @"previewUrlStr":_previewUrlStr,
                                                          @"backgroundAlpha":@(_backgroundAlpha),
                                                          @"mainColor":_mainColor,
                                                          @"secondaryColor":_secondaryColor,
                                                          @"marcatoColor":_marcatoColor,
                                                          @"borderColor":_borderColor,
                                                          @"buttonColor":_buttonColor,
                                                          @"naviBarTitleColor":_naviBarTitleColor,
                                                          @"naviBarTintColor":_naviBarTintColor,
                                                          @"naviBarBackgroundColor":_naviBarBackgroundColor,
                                                          @"tabBarTitleColor":_tabBarTitleColor,
                                                          @"tabBarSelectedTitleColor":_tabBarSelectedTitleColor,
                                                          @"tabBarBackgroundColor":_tabBarBackgroundColor,
                                                          @"cellSeparatorAlpha":@(_cellSeparatorAlpha),
                                                          @"cellSeparatorColor":_cellSeparatorColor,
                                                          @"cellIndicatorColor":_cellIndicatorColor,
                                                          @"moreHomeTitleColor":_moreHomeTitleColor,
                                                          @"moreHomeSubtitleColor":_moreHomeSubtitleColor,
                                                          @"recordHomeCalendarColor":_recordHomeCalendarColor}];
}

@end
