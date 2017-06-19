//
//  SSJShareBookMemberItem.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBookMemberItem.h"

@implementation SSJShareBookMemberItem

+ (NSDictionary *)propertyMapping {
    static NSDictionary *mapping = nil;
    if (!mapping) {
        mapping = @{@"memberId":@"cmemberid",
                    @"booksId":@"cbooksid",
                    @"icon":@"cicon",
                    @"joinDate":@"cjoindate",
                    @"state":@"istate"};
    }
    return mapping;
}

@end
