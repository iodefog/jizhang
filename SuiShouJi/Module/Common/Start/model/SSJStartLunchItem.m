//
//  SSJStartLunchItem.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJStartLunchItem.h"

@implementation SSJStartLunchItem
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"startImageUrl" : @"homeheaderbg",
             @"lottieUrl" : @"dynamicPicture.homelottie",
             @"animImageUrl" : @"dynamicPicture.homeAnimBg"
             };
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self mj_encode:aCoder];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self mj_decode:aDecoder];
    }
    return self;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}
@end
