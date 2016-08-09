//
//  SSJUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/10/27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJUtil.h"
#import "SDWebImageManager.h"
#import "MMDrawerController.h"
#import "sys/utsname.h"

NSString* SSJURLWithAPI(NSString* api) {
    return [[NSURL URLWithString:api relativeToURL:[NSURL URLWithString:SSJBaseURLString]] absoluteString];
}

NSString* SSJImageURLWithAPI(NSString* api) {
    return [[NSURL URLWithString:api relativeToURL:[NSURL URLWithString:SSJImageBaseUrlString]] absoluteString];
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

NSString *SSJPhoneModel(){
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    //iPod
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceString isEqualToString:@"iPad4,4"]
        ||[deviceString isEqualToString:@"iPad4,5"]
        ||[deviceString isEqualToString:@"iPad4,6"])      return @"iPad mini 2";
    
    if ([deviceString isEqualToString:@"iPad4,7"]
        ||[deviceString isEqualToString:@"iPad4,8"]
        ||[deviceString isEqualToString:@"iPad4,9"])      return @"iPad mini 3";
    
    return deviceString;
}

UIViewController* SSJFindTopModelViewController(UIViewController* vc){
    if (vc.presentedViewController) {
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
    }
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)vc;
        vc = SSJFindTopModelViewController(tabController.selectedViewController);
    }
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)vc;
        vc = SSJFindTopModelViewController([navController visibleViewController]);
    }
    
    return vc;
}

UIViewController* SSJVisibalController() {
    
    UIViewController* appRootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if ([appRootViewController isKindOfClass:[MMDrawerController class]]) {
        MMDrawerController *drawerController = (MMDrawerController *)appRootViewController;
        if (drawerController.presentedViewController) {
            return SSJFindTopModelViewController(drawerController);
        } else {
            switch (drawerController.openSide) {
                case MMDrawerSideNone:
                    return SSJFindTopModelViewController(drawerController.centerViewController);
                    
                case MMDrawerSideLeft:
                    return SSJFindTopModelViewController(drawerController.leftDrawerViewController);
                    
                case MMDrawerSideRight:
                    return SSJFindTopModelViewController(drawerController.rightDrawerViewController);
                    
            }
        }
    } else {
        return appRootViewController;
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

NSDictionary* SSJSettingForSource(){
    NSDictionary* dic = SSJProjectSettings();
    if (dic) {
        return [[dic objectForKey:@"Setting"] objectForKey:SSJDefaultSource()];
    }else{
        return nil;
    }
}

NSString* SSJDetailSettingForSource(NSString *key){
    NSDictionary* dic = SSJProjectSettings();
    if (dic) {
        return [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"Setting"] objectForKey:SSJDefaultSource()] objectForKey:key]];
    }else{
        return nil;
    }
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
    CFRelease(uuidRef);
    return [strUUID lowercaseString];
}

BOOL SSJSaveImage(UIImage *image , NSString *imageName){
    if (![[NSFileManager defaultManager] fileExistsAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    float imageHeight = image.size.height;
    float imageWidth = image.size.width;
    float maxLegth = MAX(imageHeight , imageWidth);
    if (maxLegth > 2500) {
        float scale = 2500 / maxLegth;
        imageHeight = imageHeight * scale;
        imageWidth = imageWidth * scale;
    }
    UIImage *resizeImage = [image ssj_scaleImageWithSize:CGSizeMake(imageWidth, imageHeight)];
    NSString *fullImageName = [imageName hasSuffix:@".jpg"] ? imageName : [NSString stringWithFormat:@"%@.jpg",imageName];
    NSData *imageData = UIImageJPEGRepresentation(resizeImage, 0.4);
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
    if (![imageName hasSuffix:@".jpg"]) {
        imageName = [NSString stringWithFormat:@"%@.jpg",imageName];
    }
    NSString *fullImageName = [NSString stringWithFormat:@"%@",imageName];
    NSString *fullPath = [[SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"] stringByAppendingPathComponent:fullImageName];
    return fullPath;
};

NSString *SSJGetChargeImageUrl(NSString *imageName){
    if (![imageName hasSuffix:@".jpg"]) {
        imageName = [NSString stringWithFormat:@"%@.jpg",imageName];
    }
    NSString *path = [NSString stringWithFormat:@"/image/sync/%@", imageName];
    return [[NSURL URLWithString:path relativeToURL:[NSURL URLWithString:SSJImageBaseUrlString]] absoluteString];
}

void SSJDispatchMainSync(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        if (block) {
            block();
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void SSJDispatchMainAsync(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        if (block) {
            block();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

BOOL SSJSavePatchVersion(NSInteger patchVersion){
    [[NSUserDefaults standardUserDefaults] setObject:@(patchVersion) forKey:SSJLastPatchVersionKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJLastPatchVersion(){
    return [[NSUserDefaults standardUserDefaults] objectForKey:SSJLastPatchVersionKey];
}



