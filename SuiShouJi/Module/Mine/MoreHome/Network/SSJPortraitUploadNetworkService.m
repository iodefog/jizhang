//
//  SSJPortraitUploadNetworkService.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPortraitUploadNetworkService.h"
#import "UIImageView+WebCache.h"
#import "CDPointActivityIndicator.h"
#import "SSJGlobalServiceManager.h"

@implementation SSJPortraitUploadNetworkService
- (void)uploadimgWithIMG:(UIImage *)image finishBlock:(UploadCompleteBlock)finishBlock{
    self.UploadCompleteBlock = finishBlock;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"usericon%@.jpg", str];
    
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc]init];
    [paraDic setObject:SSJAppVersion() forKey:@"appVersion"];
    [paraDic setObject:SSJAppVersion() forKey:@"releaseVersion"];
    [paraDic setObject:SSJDefaultSource() forKey:@"source"];
    [paraDic setObject:@"2" forKey:@"mtype"];
    [paraDic setObject:SSJUSERID() forKey:@"cuserid"];
    [paraDic setObject:(SSJAccessToken() ? SSJAccessToken() : @"") forKey:@"accessToken"];
    [paraDic setObject:(SSJAppId() ? SSJAppId() : @"") forKey:@"appId"];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SSJURLWithAPI(@"/user/uploadIcon.go") parameters:paraDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"image" fileName:fileName mimeType:@"image/jpeg"];
    } error:&tError];
    
    if (tError) {
        [CDAutoHideMessageHUD showMessage:@"头像上传失败"];
        SSJPRINT(@"Upload Error->: %@", tError);
        return;
    }
    
    [CDPointActivityIndicator startAnimating];
    
    SSJGlobalServiceManager *manager = [SSJGlobalServiceManager standardManager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //  开始上传
    NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        [CDPointActivityIndicator stopAnimating];
        
        if (error) {
            [CDAutoHideMessageHUD showMessage:@"头像上传失败"];
            SSJPRINT(@"Upload Error->: %@", error);
            return;
        }
        
        NSError *tError = nil;
        SSJPRINT(@">>> response data:%@",responseObject);
        id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&tError];
        if (tError) {
            [CDAutoHideMessageHUD showMessage:@"头像上传失败"];
            SSJPRINT(@"<----- warning:error occured when parsing xmlDoc ----->");
            return;
        }
        
        NSInteger strReturnCode = [data[@"code"] integerValue];
        NSString *strDesc = data[@"desc"];
        
        if (strReturnCode == 1) {
            NSDictionary *resultInfo = data[@"results"];
            NSString *icon = resultInfo[@"icon"];
            [CDAutoHideMessageHUD showMessage:@"头像上传成功"];
            if (self.UploadCompleteBlock) {
                self.UploadCompleteBlock(icon);
            }
        }else{
            [CDAutoHideMessageHUD showMessage:@"头像上传失败"];
            SSJPRINT(@"%@",strDesc);
            SSJPRINT(@"%ld",(long)strReturnCode);
        }
    }];
    [task resume];
}

@end
