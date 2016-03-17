//
//  SSJSyncFileModel.h
//  SuiShouJi
//
//  Created by old lang on 16/3/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJSyncFileModel : NSObject

@property (nonatomic, strong, readonly) NSData *fileData;

@property (nonatomic, copy, readonly) NSString *fileName;

@property (nonatomic, copy, readonly) NSString *mimeType;

+ (instancetype)modelWithFileData:(NSData *)data fileName:(NSString *)name mimeType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END