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
#warning test
    [self request:@"http://jz.gs.9188.com:18080/sharebook/query_secretKey.go" params:@{@"cuserId":SSJUSERID(),
                                                                                      @"cbooksId":booksId ? : @""}];
}

- (void)saveCodeWithbooksId:(NSString *)booksId code:(NSString *)code {
#warning test
    [self request:SSJURLWithAPI(@"http://jz.gs.9188.com:18080/sharebook/save_secretKey.go") params:@{@"cuserId":SSJUSERID(),
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
