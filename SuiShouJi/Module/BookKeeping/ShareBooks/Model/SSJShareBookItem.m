//
//  SSJShareBookItem.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBookItem.h"

@implementation SSJShareBookItem

+ (NSDictionary *)propertyMapping {
    static NSDictionary *mapping = nil;
    if (!mapping) {
        mapping = @{@"booksId":@"cbooksid",
                    @"creatorId":@"ccreator",
                    @"adminId":@"cadmin",
                    @"booksName":@"cbooksname",
                    @"booksColor":@"cbookscolor",
                    @"parentType":@"iparenttype",
                    @"booksOrder":@"iorder"};
    }
    return mapping;
}

- (void)setBooksColor:(SSJFinancingGradientColorItem *)booksColor {
    _booksColor = booksColor;
}


@end
