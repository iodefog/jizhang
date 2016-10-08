//
//  SSJPatchUpdateService.m
//  SuiShouJi
//
//  Created by ricky on 16/5/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPatchUpdateService.h"
#import "SSJJsPatchItem.h"

@interface SSJPatchUpdateService()

@end
@implementation SSJPatchUpdateService

- (void)requestPatchWithCurrentVersion:(NSString *)version{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:version forKey:@"version"];
    [self request:SSJURLWithAPI(@"/maintenance/maintenance.go") params:dict];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    if ([self.returnCode isEqualToString:@"1"]) {
        self.patchItem = [SSJJsPatchItem mj_objectWithKeyValues:[rootElement objectForKey:@"results"]];
    }
}

@end
