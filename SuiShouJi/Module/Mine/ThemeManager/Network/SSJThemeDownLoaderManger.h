//
//  SSJThemeDownLoaderManger.h
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSJThemeDownLoaderMangerDelegate<NSObject>

@required
- (void)downLoadThemeWithProgress:(NSProgress *)progress;
@end

@interface SSJThemeDownLoaderManger : NSObject

- (void)downloadThemeWithUrl:(NSString *)urlStr
                     Success:(void(^)())success
                     failure:(void (^)(NSError *error))failure;

@property(nonatomic, assign) id <SSJThemeDownLoaderMangerDelegate>delegate;

@end

