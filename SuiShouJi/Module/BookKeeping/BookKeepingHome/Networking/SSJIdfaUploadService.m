//
//  SSJIdfaUploadService.m
//  SuiShouJi
//
//  Created by ricky on 16/11/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJIdfaUploadService.h"
#import "SSJCustomJsonSerializer.h"

@interface SSJIdfaUploadService()

@property (nonatomic, copy) void (^successBlock)(NSString *idfaStr);

@property(nonatomic, strong) NSString *idfaStr;

@end

@implementation SSJIdfaUploadService

- (void)uploadIdfaWithIdfaStr:(NSString *)str Success:(void (^)(NSString *idfaStr))success{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:str forKey:@"idfa"];
    [dict setObject:SSJDefaultSource() forKey:@"source"];
    self.idfaStr = str;
    self.responseSerializer = [SSJCustomJsonSerializer serializer];
    [self request:SSJURLWithAPI(@"http://iphone.app.huishuaka.com/credit/iosIdfaSave.go") params:dict];
    self.successBlock = success;
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    if ([self.returnCode isEqualToString:@"1"]) {
        if (self.successBlock) {
            self.successBlock(self.idfaStr);
        }
    }
}


@end
