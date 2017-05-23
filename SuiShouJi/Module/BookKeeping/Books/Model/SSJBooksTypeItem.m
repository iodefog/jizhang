//
//  SSJBooksTypeItem.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeItem.h"

@implementation SSJBooksTypeItem
@synthesize booksId;
@synthesize booksName;
@synthesize booksColor = _booksColor;
@synthesize booksOrder;
@synthesize booksParent;
@synthesize cwriteDate;

+ (NSDictionary *)propertyMapping {
    static NSDictionary *mapping = nil;
    if (!mapping) {
        mapping = @{@"booksId":@"cbooksid",
                    @"booksName":@"cbooksname",
                    @"booksColor":@"cbookscolor",
                    @"booksParent":@"iparenttype",
                    @"userId":@"cuserid",
                    @"cwriteDate":@"cwritedate",
                    @"operatorType":@"operatortype",
                    @"booksOrder":@"iorder",
                    @"booksIcoin":@"cicoin"};
    }
    return mapping;
}


-(BOOL)isEqual:(id)object{
    [super isEqual:object];
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[SSJBooksTypeItem class]]) {
        return NO;
    }
    
    SSJBooksTypeItem *memberItem = (SSJBooksTypeItem *)object;
    
    if ([self.booksId isEqualToString:memberItem.booksId]) {
        return YES;
    }else{
        return NO;
    }
    
    return NO;
}
@end
