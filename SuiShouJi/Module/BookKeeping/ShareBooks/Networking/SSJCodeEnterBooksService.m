//
//  SSJCodeEnterBooksService.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCodeEnterBooksService.h"

@implementation SSJCodeEnterBooksService

- (void)enterBooksWithCode:(NSString *)code{
    self.showLodingIndicator = YES;
    [self request:SSJURLWithAPI(@"/chargebook/sharebook/join_book.go") params:@{@"cuserId":SSJUSERID(),
                                                                                @"secretKey":code ? : @""}];
}

- (void)requestDidFinish:(NSDictionary *)rootElement {
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *resultInfo = [rootElement objectForKey:@"results"];
        if (resultInfo) {
            self.shareBooksTableInfo = [NSMutableDictionary dictionaryWithDictionary:resultInfo[@"share_book"]];
            self.shareMemberTableInfo =  resultInfo[@"share_member"];
            self.userChargeTableInfo = resultInfo[@"share_charge"];
            self.shareFriendMarkTableInfo = resultInfo[@"share_friends_mark"];
        }
    }
}

@end
