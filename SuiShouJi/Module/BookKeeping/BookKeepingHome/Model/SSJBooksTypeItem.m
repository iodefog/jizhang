//
//  SSJBooksTypeItem.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeItem.h"

@implementation SSJBooksTypeItem
+ (NSDictionary *)propertyMapping {
    static NSDictionary *mapping = nil;
    if (!mapping) {
        mapping = @{@"booksId":@"cbooksid",
                    @"booksName":@"cbooksname",
                    @"booksColor":@"cbookscolor",
                    @"userId":@"cuserid",
                    @"cwriteDate":@"cwritedate",
                    @"operatorType":@"operatortype",
                    @"booksOrder":@"iorder"};
    }
    return mapping;
}
@end
