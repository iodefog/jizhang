//
//  SSJThemeDownLoaderManger.h
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SSJThemeDownLoaderProgressBlock)(float);

@interface SSJThemeDownLoaderManger : NSObject

+ (SSJThemeDownLoaderManger *)sharedInstance;

- (void)downloadThemeWithID:(NSString *)ID
                        url:(NSString *)urlStr
                    success:(void(^)())success
                    failure:(void (^)(NSError *error))failure;

- (void)addProgressHandler:(SSJThemeDownLoaderProgressBlock)handler forID:(NSString *)ID;

@end

