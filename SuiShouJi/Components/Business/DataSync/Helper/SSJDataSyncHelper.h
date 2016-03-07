//
//  SSJDataSyncHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/1/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

BOOL SSJSetCurrentSyncUserId(NSString *userid);

NSString *SSJCurrentSyncUserId();

@interface SSJDataSyncHelper : NSObject

+ (void)uploadBodyData:(NSData *)data headerParams:(NSDictionary *)prarms toUrlPath:(NSString *)path completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end