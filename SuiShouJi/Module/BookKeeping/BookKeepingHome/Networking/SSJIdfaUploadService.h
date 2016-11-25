//
//  SSJIdfaUploadService.h
//  SuiShouJi
//
//  Created by ricky on 16/11/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJIdfaUploadService : SSJBaseNetworkService

- (void)uploadIdfaWithIdfaStr:(NSString *)str Success:(void (^)(NSString *idfaStr))success;

@end
