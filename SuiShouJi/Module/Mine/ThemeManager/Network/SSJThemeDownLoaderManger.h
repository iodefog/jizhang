//
//  SSJThemeDownLoaderManger.h
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SSJThemeDownLoaderProgressBlocker : NSObject

@property (nonatomic, copy) void (^progressBlock)(float progress);

@property (nonatomic, copy) NSString *ID;

@property (nonatomic) float progress;

@end

@interface SSJThemeDownLoaderManger : NSObject

+ (SSJThemeDownLoaderManger *)sharedInstance;

- (void)downloadThemeWithID:(NSString *)ID
                        url:(NSString *)urlStr
                    Success:(void(^)())success
                    failure:(void (^)(NSError *error))failure
                   progress:(void(^)(float progress))progress;

@property (nonatomic, strong) NSMutableDictionary *blockerMapping;

@end

