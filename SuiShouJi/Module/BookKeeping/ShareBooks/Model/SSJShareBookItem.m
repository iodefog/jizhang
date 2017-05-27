//
//  SSJShareBookItem.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBookItem.h"

@implementation SSJShareBookItem
@synthesize booksId;
@synthesize booksName;
//@synthesize booksColor = _booksColor;
@synthesize booksColor;
@synthesize booksOrder;
@synthesize booksParent;
@synthesize cwriteDate;

+ (NSDictionary *)propertyMapping {
    static NSDictionary *mapping = nil;
    if (!mapping) {
        mapping = @{@"booksId":@"cbooksid",
                    @"creatorId":@"ccreator",
                    @"adminId":@"cadmin",
                    @"booksName":@"cbooksname",
                    @"booksColor":@"cbookscolor",
                    @"booksParent":@"iparenttype",
                    @"booksOrder":@"iorder",
                    @"cwriteDate":@"cadddate"};
    }
    return mapping;
}


+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return [self propertyMapping];
}
//+ (NSDictionary *)mj_objectClassInArray {
//    return @{@"booksColor":@"SSJFinancingGradientColorItem"};
//}
@end
