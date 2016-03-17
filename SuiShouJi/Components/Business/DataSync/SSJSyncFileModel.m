//
//  SSJSyncFileModel.m
//  SuiShouJi
//
//  Created by old lang on 16/3/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSyncFileModel.h"

@interface SSJSyncFileModel ()

@property (nonatomic, strong) NSData *fileData;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, copy) NSString *mimeType;

@end

@implementation SSJSyncFileModel

+ (instancetype)modelWithFileData:(NSData *)data fileName:(NSString *)name mimeType:(NSString *)type {
    SSJSyncFileModel *model = [[SSJSyncFileModel alloc] init];
    model.fileData = data;
    model.fileName = name;
    model.mimeType = type;
    return model;
}

@end
