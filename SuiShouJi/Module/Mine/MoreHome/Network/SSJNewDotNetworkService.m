//
//  SSJNewDotNetworkService.m
//  SuiShouJi
//
//  Created by yi cai on 2017/1/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewDotNetworkService.h"

@implementation SSJNewDotNetworkService
- (void)requestTheme:(NSString *)themeVersion adviceTime:(NSDate *)date
{
    self.showLodingIndicator = NO;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
//    [dict setObject:SSJUSERID() forKey:@"cuserid"];
//    [dict setObject:themeVersion forKey:@"isystem"];
//    [dict setObject:date forKey:@"cversion"];
}

- (void)requestDidFinish:(id)rootElement
{
    if ([rootElement isKindOfClass:[NSDictionary class]]) {
        
    }
}
@end
