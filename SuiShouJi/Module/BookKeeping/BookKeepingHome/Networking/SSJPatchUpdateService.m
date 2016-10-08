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

@property (nonatomic, copy) void (^successBlock)(SSJJsPatchItem *item);

@end

@implementation SSJPatchUpdateService

- (void)requestPatchWithCurrentVersion:(NSString *)version Success:(void (^)(SSJJsPatchItem *item))success{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:version forKey:@"version"];
    [self request:SSJURLWithAPI(@"/maintenance/maintenance.go") params:dict];
    self.successBlock = success;
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    if ([self.returnCode isEqualToString:@"1"]) {
        self.patchItem = [SSJJsPatchItem mj_objectWithKeyValues:[[rootElement objectForKey:@"results"] firstObject]];
        if (self.successBlock) {
            self.successBlock(self.patchItem);
        }
    }
}

@end
