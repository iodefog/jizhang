//
//  SSJUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/10/27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJUtil.h"
//#import <CommonCrypto/CommonDigest.h>
//#import "SFHFKeychainUtils.h"
#import "SDWebImageManager.h"

NSString* SSJURLWithAPI(NSString* api) {
    return [[NSURL URLWithString:api relativeToURL:[NSURL URLWithString:SSJBaseURLString]] absoluteString];
}

NSString* SSJImageURLWithAPI(NSString* api) {
    return [[NSURL URLWithString:api relativeToURL:[NSURL URLWithString:@"http://jz.9188.com"]] absoluteString];
}

NSString *SSJAppName() {
    NSString *strAppname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    return strAppname;
}

NSString *SSJURLScheme() {
    NSArray *arr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    NSString *scheme = nil;
    if (arr.count > 0) {
        NSDictionary *dic = arr[0];
        NSArray *subarr = [dic objectForKey:@"CFBundleURLSchemes"];
        if (subarr.count > 0) {
            scheme = subarr[0];
        }
    }
    return scheme;
}

NSString *SSJAppVersion() {
    NSString *verString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"%@",verString];
}

float SSJSystemVersion() {
    return [[UIDevice currentDevice].systemVersion floatValue];
}

UIViewController* SSJFindTopModelViewController(UIViewController* vc){
    if (vc.presentedViewController) {
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
    }else {
        vc = nil;
    }
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController*)vc visibleViewController];
    }
    
    return vc;
}

UIViewController* SSJVisibalController() {
    
    UIViewController* appRootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if ([appRootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tableBarVC = (UITabBarController*)appRootViewController;
        if (tableBarVC.presentedViewController) {
            return SSJFindTopModelViewController(tableBarVC);
        }else {
            UINavigationController* selectedNav = (UINavigationController*)tableBarVC.selectedViewController;
            
            if (selectedNav.presentedViewController) {
                return SSJFindTopModelViewController(selectedNav);
            }else {
                return selectedNav.topViewController;
            }
        }
    }else {
        if (appRootViewController.presentedViewController) {
            return SSJFindTopModelViewController(appRootViewController);
        }else {
            return appRootViewController;
        }
    }
}

NSString* SSJProjectSettingsPath(){
    return [[NSBundle mainBundle] pathForResource:@"ProjectSettings" ofType:@"plist"];
}

NSDictionary* SSJProjectSettings(){
    return [NSDictionary dictionaryWithContentsOfFile:SSJProjectSettingsPath()];
}

NSString* SSJDefaultSource() {
    NSDictionary* dic = SSJProjectSettings();
    if (dic){
        return [dic objectForKey:@"DefaultSource"];
    }else {
        return nil;
    }
}

BOOL SSJIsAppStoreSource() {
    NSDictionary* dic = SSJProjectSettings();
    NSArray *appStoreSources = [dic objectForKey:@"AppStoreSources"];
    if ([appStoreSources isKindOfClass:[NSArray class]]) {
        return [appStoreSources containsObject:SSJDefaultSource()];
    }
    return NO;
}

NSString *SSJMessageWithErrorCode(NSError *error) {
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        if (error.code == NSURLErrorTimedOut) {
            return @"连线超时，休息一下再试^_^";
        } else if (error.code == NSURLErrorNotConnectedToInternet) {
            return @"您的网络未连接，连接后再试^_^";
        } else if (error.code == 503||error.code==502) {
            return @"服务暂不可用";
        } else if (error.code == 500) {
            return @"服务器发生了一点小问题";
        }
    }
    return nil;
}

BOOL stringMatchRex(NSString* str ,NSString* rex){
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", rex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (isMatch){
        return YES;
    }else {
        return NO;
    }
}

BOOL checkName(NSString *userName){
    BOOL canUse = NO;
    if (userName.length>0) {
        NSString * regex = @"^[\\u4e00-\\u9fa5·•.]+$";//校验姓名规则
        BOOL canChange = stringMatchRex(userName, regex);
        canUse = canChange;
    }
    return canUse;
}

BOOL SSJIsFirstLaunchForCurrentVersion() {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString *versionKey = SSJAppVersion();
    NSInteger launchTimes = [userDefault integerForKey:versionKey];
    return launchTimes == 0;
}

void SSJAddLaunchTimesForCurrentVersion() {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString *versionKey = SSJAppVersion();
    NSInteger launchTimes = [userDefault integerForKey:versionKey];
    launchTimes ++;
    [userDefault setInteger:launchTimes forKey:versionKey];
    [userDefault synchronize];
}

NSString *SSJDocumentPath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    return docPath;
}

static NSString *const SSJSSLCertificateName = @"2_www.licaidi.com.cer";

NSString *SSJSSLCertificatePath() {
    NSString *documentPath = SSJDocumentPath();
    NSString *certificatePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Certificates/%@",SSJSSLCertificateName]];
    return certificatePath;
}

BOOL SSJSaveSSLCertificate(NSData *certificate) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *SSLDirectory = [SSJDocumentPath() stringByAppendingPathComponent:@"Certificates"];
    NSString *SSLPath = [SSLDirectory stringByAppendingPathComponent:SSJSSLCertificateName];
    
    BOOL isDirectory = NO;
    BOOL isPathExist = [fileManager fileExistsAtPath:SSLDirectory isDirectory:&isDirectory];
    if (isPathExist && isDirectory) {
        return [certificate writeToFile:SSLPath atomically:YES];
    }
    
    NSError *error = nil;
    BOOL createSuccessfull = [fileManager createDirectoryAtPath:SSLDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    if (createSuccessfull && !error) {
        NSString *SSLPath = [SSLDirectory stringByAppendingPathComponent:SSJSSLCertificateName];
        return [certificate writeToFile:SSLPath atomically:YES];
    }
    
    return NO;
}

static NSString *const kDatabasePath = @"mydatabase.db";

NSString *SSJSQLitePath() {
    NSString *documentPath = SSJDocumentPath();
    NSString *databaseDirectory = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"SQLite"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:databaseDirectory]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:databaseDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            SSJPRINT(@"error:%@",[error localizedDescription]);
        }
    }
    
    return [databaseDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",kDatabasePath]];
}

static NSString *const kQQListKey = @"";

NSArray *SSJQQList() {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:kQQListKey];
}

BOOL SSJSaveQQList(NSArray *qqList) {
    if (qqList) {
        [[NSUserDefaults standardUserDefaults] setObject:qqList forKey:kQQListKey];
        return [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return NO;
}

NSString *SSJUUID(){
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    return [strUUID lowercaseString];
}

BOOL SSJSaveImage(UIImage *image , NSString *imageName){
    if (![[NSFileManager defaultManager] fileExistsAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fullImageName = [NSString stringWithFormat:@"%@.jpg",imageName];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSString *fullPath = [[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"] stringByAppendingPathComponent:fullImageName];
    return [imageData writeToFile:fullPath atomically:YES];
};

BOOL SSJSaveThumbImage(UIImage *image , NSString *imageName){
    if (![[NSFileManager defaultManager] fileExistsAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fullImageName = [NSString stringWithFormat:@"%@-thumb.jpg",imageName];
    NSData *imageData = UIImageJPEGRepresentation([image ssj_scaleImageWithSize:CGSizeMake(50, 50)], 0.5);
    NSString *fullPath = [[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"] stringByAppendingPathComponent:fullImageName];
    return [imageData writeToFile:fullPath atomically:YES];
}

NSString *SSJImagePath(NSString *imageName){
    NSString *fullImageName = [NSString stringWithFormat:@"%@.jpg",imageName];
    NSString *fullPath = [[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"] stringByAppendingPathComponent:fullImageName];
    return fullPath;
};

NSString *SSJGetChargeImageUrl(NSString *imageName){
    NSString *imageURL = [NSString stringWithFormat:@"http://jz.9188.com/image/sync/%@",imageName];
    return imageURL;
}

