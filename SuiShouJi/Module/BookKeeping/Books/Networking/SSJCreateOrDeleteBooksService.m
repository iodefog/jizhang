//
//  SSJCreateOrDeleteBooksService.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreateOrDeleteBooksService.h"
#import "SSJShareBookItem.h"
#import "SSJFinancingGradientColorItem.h"
@implementation SSJCreateOrDeleteBooksService

- (void)createShareBookWithBookItem:(SSJShareBookItem *)bookItem {
//    cuserId	String	是	用户id
//    cbookName	String	是	账本名称
//    cbookColor	String	是	账本颜色
//    iparentType	String	是	账本父类型
//    cwriteDate	String	是	客户端操作时间
//    operatorType	String	是	操作类型
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    bookItem.cwriteDate = cwriteDate;
    NSDictionary *paramDic = @{@"cuserId":SSJUSERID(),
                               @"cbookName":[NSString stringWithFormat:@"%@",bookItem.booksName],
                               @"cbookColor":[NSString stringWithFormat:@"%@,%@",bookItem.booksColor.startColor,bookItem.booksColor.endColor],
                               @"iparentType":@(bookItem.booksParent),
                               @"cwriteDate":bookItem.cwriteDate,
                               @"operatorType":@"0"};
    self.showLodingIndicator = YES;
    [self request:SSJURLWithAPI(@"/chargebook/sharebook/add_shareBook.go") params:paramDic];
}

- (void)deleteShareBookWithBookId:(NSString *)bookId memberId:(NSString *)memberId memberState:(SSJShareBooksMemberState)memberState {
    NSDictionary *paramDic = @{@"cmemberId":memberId,
                               @"cbooksId":bookId,
                               @"istate":@(memberState)};
    self.showLodingIndicator = YES;
    [self request:SSJURLWithAPI(@"/chargebook/sharebook/remove_member.go") params:paramDic];
}

- (void)requestDidFinish:(NSDictionary *)rootElement {
    if (![self.returnCode isEqualToString:@"1"]) return;
    NSArray *keyArray = [rootElement allKeys];
    if ([keyArray containsObject:@"results"]) {
        NSDictionary *result = rootElement[@"results"];
        if ([[result allKeys] containsObject:@"shareBook"]) {
            self.shareBookDic = result[@"shareBook"];
        }
        
        if ([[result allKeys] containsObject:@"share_charge"]) {
            self.shareChargeArray = [result objectForKey:@"share_charge"];
        }
        if ([[result allKeys] containsObject:@"shareMembers"]) {
            self.shareMemberArray = [result objectForKey:@"shareMembers"];
        } else if ([[result allKeys] containsObject:@"share_member"]) {
            self.shareMemberArray = [result objectForKey:@"share_member"];
        }
        if ([[result allKeys] containsObject:@"shareFriendsMarks"]) {
            self.shareFriendsMarkArray = [result objectForKey:@"shareFriendsMarks"];
        }
    }
}

@end
