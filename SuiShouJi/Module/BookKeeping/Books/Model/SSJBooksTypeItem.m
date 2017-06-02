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
@synthesize booksColor;
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

- (NSString *)getSingleColor {
    NSInteger index = [[SSJFinancingGradientColorItem defualtColors] indexOfObject:self.booksColor];
    
    NSString *singleColor;
    
    switch (index) {
        case 0:
            singleColor = @"#fc72ae";
            break;
            
        case 1:
            singleColor = @"#f96a6a";
            break;
            
        case 2:
            singleColor = @"#8094f9";
            break;
            
        case 3:
            singleColor = @"#81b9f0";
            break;
            
        case 4:
            singleColor = @"#39d4da";
            break;
            
        case 5:
            singleColor = @"#56d696";
            break;
            
        case 6:
            singleColor = @"#f8b556";
            break;
            
        case 7:
            singleColor = @"#fc835a";
            break;
            
        case 8:
            singleColor = @"#c6b244";
            break;
            
        case 9:
            singleColor = @"#8d79ff";
            break;
            
        case 10:
            singleColor = @"#c565e5";
            break;
            
        case 11:
            singleColor = @"#51a4ff";
            break;
            
        default:
            singleColor = @"#fc72ae";
            break;
            
    }
    
    return singleColor; 
}

+ (NSString *)parentIconForParenType:(NSInteger)type {
    NSString *icon;
    
    switch (type) {
        case 0:
            icon = @"bk_moren";
            break;
            
        case 1:
            icon = @"bk_shengyi";
            break;
            
        case 2:
            icon = @"bk_lvxing";
            break;
            
        case 3:
            icon = @"bk_zhuangxiu";
            break;
            
        case 4:
            icon = @"bk_jiehun";
            break;
            
        default:
            icon = @"bk_moren";
            break;
    }
    
    return icon;
}


@end
