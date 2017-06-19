//
//  SSJSharebooksCodeNetworkService.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSharebooksCodeNetworkService.h"

@implementation SSJSharebooksCodeNetworkService

- (void)requestCodeWithbooksId:(NSString *)booksId{
    self.showLodingIndicator = YES;
    [self request:SSJURLWithAPI(@"/chargebook/sharebook/query_secretKey.go") params:@{@"cuserId":SSJUSERID(),
                                                                                      @"cbooksId":booksId ? : @""}];
}

- (void)saveCodeWithbooksId:(NSString *)booksId code:(NSString *)code {
    self.showLodingIndicator = YES;
    [self request:SSJURLWithAPI(@"/chargebook/sharebook/save_secretKey.go") params:@{@"cuserId":SSJUSERID(),
                                                                                                    @"cbooksId":booksId,
                                                                                                    @"secretKey":code ? : @""}];
}

- (void)requestDidFinish:(NSDictionary *)rootElement {
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *resultInfo = [rootElement objectForKey:@"results"];
        if (resultInfo) {
            self.secretKey = resultInfo[@"secretKey"];
            self.overTime =  resultInfo[@"overTime"];
        }
    }
}
@end
