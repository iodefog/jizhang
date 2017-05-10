//
//  SSJNewDotNetworkService.m
//  SuiShouJi
//
//  Created by yi cai on 2017/1/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewDotNetworkService.h"
#import "SSJThemeAndAdviceDotItem.h"
#import "SSJUserTableManager.h"
@implementation SSJNewDotNetworkService
- (void)requestThemeAndAdviceUpdate
{
    self.showLodingIndicator = NO;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [self request:@"admin/checkRemind.go" params:dict];
}

- (void)requestDidFinish:(id)rootElement
{
    [super requestDidFinish:rootElement];
    if ([rootElement isKindOfClass:[NSDictionary class]] && [self.returnCode isEqualToString:@"1"]) {
        //转模型
        NSDictionary *result = [[NSDictionary dictionaryWithDictionary:rootElement] objectForKey:@"results"];
        self.dotItem = [SSJThemeAndAdviceDotItem mj_objectWithKeyValues:result];
        self.dotItem.creplyDate = [NSDate dateWithString:self.dotItem.creplydate formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        @weakify(self);
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            @strongify(self);
            self.dotItem.hasThemeUpdate = [[self themeVersion] doubleValue] < [self.dotItem.themeVersion doubleValue];
            if (self.dotItem.creplydate.length < 1) {
                self.dotItem.hasAdviceUpdate = NO ;
            }else if (self.dotItem.creplydate.length > 0 && userItem.adviceTime.length < 1) {
                self.dotItem.hasAdviceUpdate = YES;
            } else {
                self.dotItem.hasAdviceUpdate = [self.dotItem.creplyDate compare:[NSDate dateWithString:userItem.adviceTime formatString:@"yyyy-MM-dd HH:mm:ss.SSS"]] == NSOrderedDescending;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserItemReturnKey object:nil];
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
}



- (NSString *)themeVersion
{
    NSString *themeStr = [[NSUserDefaults standardUserDefaults] objectForKey:kThemeVersionKey];
    return themeStr.length > 0 ? themeStr : @"-1";
}
@end
