//
//  SSJDataSyncHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/1/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

//  加密密钥字符串
extern NSString *const kSignKey;

/**
 *  设置当前用户数据同步的用户编号
 *
 *  @param userid 当前用户的用户编号
 *
 *  @return (BOOL) 是否保存成功
 */
BOOL SSJSetCurrentSyncDataUserId(NSString *userid);

/**
 *  返回当前用户数据同步的用户编号
 *
 *  @return (NSString *) 当前用户数据同步的用户编号
 */
NSString *SSJCurrentSyncDataUserId();

/**
 *  设置当前用户图片同步的用户编号
 *
 *  @param userid 当前用户的用户编号
 *
 *  @return (BOOL) 是否保存成功
 */
BOOL SSJSetCurrentSyncImageUserId(NSString *userid);

/**
 *  返回当前用户图片同步的用户编号
 *
 *  @return (NSString *) 当前用户图片同步的用户编号
 */
NSString *SSJCurrentSyncImageUserId();



@interface SSJDataSyncHelper : NSObject

+ (NSURLSessionUploadTask *)uploadBodyData:(NSData *)data
                              headerParams:(NSDictionary *)prarms
                                 toUrlPath:(NSString *)path
                                  fileName:(NSString *)fileName
                                  mimeType:(NSString *)mimeType
                         completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end