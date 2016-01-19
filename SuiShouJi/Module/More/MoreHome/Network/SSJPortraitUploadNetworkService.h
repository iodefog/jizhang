//
//  SSJPortraitUploadNetworkService.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJPortraitUploadNetworkService : SSJBaseNetworkService
/**
 *  上传头像
 *
 *  @param image 头像图片
 */

typedef void (^UploadCompleteBlock)(); //上传头像完成的回调

@property (nonatomic, copy) UploadCompleteBlock UploadCompleteBlock;

- (void)uploadimgWithIMG:(UIImage *)image finishBlock:(UploadCompleteBlock)finishBlock;
@end
