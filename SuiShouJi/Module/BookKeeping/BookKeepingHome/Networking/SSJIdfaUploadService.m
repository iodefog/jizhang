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
    NSString *appId = SSJDetailSettingForSource(@"appleID");
    NSString *strKey=@"iwannapie?!";
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *signMsg = [NSString stringWithFormat:@"appid=%@&idfa=%@&timestamp=%f&key=%@",appId,str,timestamp,strKey];
    signMsg = [[signMsg ssj_md5HexDigest] uppercaseString];
    
    [dict setObject:appId ?: @"" forKey:@"appid"];
    [dict setObject:str ?: @"" forKey:@"idfa"];
    [dict setObject:@(timestamp) forKey:@"timestamp"];
    [dict setObject:SSJDefaultSource() forKey:@"source"];
    [dict setObject:strKey forKey:@"key"];
    [dict setObject:signMsg forKey:@"signMsg"];
    
    self.idfaStr = str;
    [self request:SSJURLWithAPI(@"aso/addIdfa.go") params:dict];
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
