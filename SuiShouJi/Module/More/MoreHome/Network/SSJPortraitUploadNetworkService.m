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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    [manager POST:SSJURLWithAPI(@"/user/uploadIcon.go") parameters:paraDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"image" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        SSJPRINT(@">>> response data:%@",responseObject);
        id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            SSJPRINT(@"<----- warning:error occured when parsing xmlDoc ----->");
            return;
        }
        NSInteger strReturnCode = [data[@"code"] integerValue];
        NSString *strDesc = data[@"desc"];
        [CDPointActivityIndicator startAnimating];
        if (strReturnCode == 1) {
            [CDPointActivityIndicator stopAnimating];
            [CDAutoHideMessageHUD showMessage:@"头像上传成功"];
            if (self.UploadCompleteBlock) {
                self.UploadCompleteBlock();
            }
        }else{
            [CDPointActivityIndicator stopAnimating];
            [CDAutoHideMessageHUD showMessage:@"头像上传失败"];
            NSLog(@"%@",strDesc);
            NSLog(@"%ld",(long)strReturnCode);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"头像上传失败"];
        NSLog(@"Upload Error->: %@", error);
    }];
}

@end
