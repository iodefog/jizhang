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
#import "SFHFKeychainUtils.h"
#import "SSJDomainManager.h"

NSString* SSJURLWithAPI(NSString* api) {
    return [[NSURL URLWithString:api relativeToURL:[NSURL URLWithString:[SSJDomainManager domain]]] absoluteString];
}

NSString* SSJImageURLWithAPI(NSString* api) {
    if (api) {
        return [[SSJDomainManager imageDomain] stringByAppendingString:api];
    } else {
        return nil;
    }
    
//    return [[NSURL URLWithString:api relativeToURL:[NSURL URLWithString:[SSJDomainManager imageDomain]]] absoluteString];
}

NSString *SSJBundleID() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
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

NSString *SSJAppIcon() {
    NSString *icon = @"";
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    
    if ([UIScreen mainScreen].scale >= 2) {
        icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    } else {
        icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] firstObject];
    }
    
    return icon;
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
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";

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
            if ([vc.presentedViewController isKindOfClass:[UIAlertController class]]) {
                break;
            }
            vc = vc.presentedViewController;
        }
    }
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)vc;
        vc = SSJFindTopModelViewController(tabController.selectedViewController);
    }
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)vc;
        vc = SSJFindTopModelViewController([navController topViewController]);
    }
    
    if ([vc isKindOfClass:[MMDrawerController class]]) {
        MMDrawerController *drawer = (MMDrawerController *)vc;
        switch (drawer.openSide) {
            case MMDrawerSideNone:
                vc = SSJFindTopModelViewController(drawer.centerViewController);
                break;
                
            case MMDrawerSideLeft:
                vc = SSJFindTopModelViewController(drawer.leftDrawerViewController);
                break;
                
            case MMDrawerSideRight:
                vc = SSJFindTopModelViewController(drawer.rightDrawerViewController);
                break;
        }
    }
    
    return vc;
}

UIViewController* SSJVisibalController() {
    
    UIViewController* appRootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    return SSJFindTopModelViewController(appRootViewController);
    
//    if ([appRootViewController isKindOfClass:[MMDrawerController class]]) {
//        
//        MMDrawerController *drawerController = (MMDrawerController *)appRootViewController;
//        MMDrawerController *topDrawerController = drawerController;
//        if (drawerController.presentedViewController) {
//            UIViewController *topController = SSJFindTopModelViewController(drawerController);
//            if (![topController isKindOfClass:[MMDrawerController class]]) {
//                return topController;
//            }
//            
//            topDrawerController = (MMDrawerController *)topController;
//        }
//        
//        switch (topDrawerController.openSide) {
//            case MMDrawerSideNone:
//                return SSJFindTopModelViewController(topDrawerController.centerViewController);
//                
//            case MMDrawerSideLeft:
//                return SSJFindTopModelViewController(topDrawerController.leftDrawerViewController);
//                
//            case MMDrawerSideRight:
//                return SSJFindTopModelViewController(topDrawerController.rightDrawerViewController);
//                
//        }
//    } else {
//        return appRootViewController;
//    }
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
        NSDictionary *info = [dic objectForKey:SSJBundleID()];
        return [info objectForKey:@"source"];
    } else {
        return nil;
    }
}

NSString *SSJAppStoreUrl() {
    NSDictionary* dic = SSJProjectSettings();
    if (dic){
        NSDictionary *info = [dic objectForKey:SSJBundleID()];
        return [info objectForKey:@"AppStoreUrl"];
    } else {
        return nil;
    }
}

NSString *SSJAppleID() {
    NSDictionary* dic = SSJProjectSettings();
    if (dic){
        NSDictionary *info = [dic objectForKey:SSJBundleID()];
        return [info objectForKey:@"appleID"];
    } else {
        return nil;
    }
}

NSString* SSJDetailSettingForSource(NSString *key){
    NSDictionary* dic = SSJProjectSettings();
    if (dic){
        NSDictionary *info = [dic objectForKey:SSJBundleID()];
        return [info objectForKey:key];
    } else {
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

static NSString *const kSSJLaunchTimesInfoKey = @"kSSJLaunchTimesInfoKey";

void SSJMigrateLaunchTimesInfo() {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:kSSJLaunchTimesInfoKey]) {
        NSMutableDictionary *versionInfo = [[NSMutableDictionary alloc] init];
        NSArray *versions = @[@"1.9.2", @"1.9.1", @"1.9.0", @"1.8.2", @"1.8.1", @"1.8.0", @"1.7.3", @"1.7.2", @"1.7.1", @"1.7.0"];
        for (NSString *version in versions) {
            NSInteger launchTimes = [userDefaults integerForKey:version];
            [versionInfo setObject:@(launchTimes) forKey:version];
        }
        [userDefaults setObject:versionInfo forKey:kSSJLaunchTimesInfoKey];
        [userDefaults synchronize];
    }
}

NSDictionary *SSJLaunchTimesInfo() {
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSSJLaunchTimesInfoKey];
    if (!info) {
        info = [[NSDictionary alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:info forKey:kSSJLaunchTimesInfoKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return info;
}

NSInteger SSJLaunchTimesForCurrentVersion() {
    return [[SSJLaunchTimesInfo() objectForKey:SSJAppVersion()] integerValue];
}

NSInteger SSJLaunchTimesForAllVersion() {
    NSDictionary *info = SSJLaunchTimesInfo();
    __block NSInteger luanchTime = 0;
    if (info) {
        [info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            luanchTime += [obj integerValue];
        }];
    }
    return luanchTime;
}

void SSJAddLaunchTimesForCurrentVersion() {
    NSMutableDictionary *info = [SSJLaunchTimesInfo() mutableCopy];
    NSInteger launchTimes = [[info objectForKey:SSJAppVersion()] integerValue];
    launchTimes ++;
    [info setObject:@(launchTimes) forKey:SSJAppVersion()];
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:kSSJLaunchTimesInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

NSString *SSJUniqueID(){
    NSString *serviceName = @"com.youyu.jizhang";
    NSString *userName = @"IMEI";
    NSString *strUUID = [SFHFKeychainUtils getPasswordForUsername:userName andServiceName:serviceName error:nil];
    if (!strUUID | [strUUID isEqualToString:@""]) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        [SFHFKeychainUtils storeUsername:userName andPassword:strUUID forServiceName:serviceName updateExisting:NO error:nil];
    }
    return strUUID;
}

NSString *SSJChargeImageDirectory() {
    return [SSJDocumentPath() stringByAppendingPathComponent:@"ChargePic"];
}

BOOL SSJSaveImage(UIImage *image , NSString *imageName){
    if (![[NSFileManager defaultManager] fileExistsAtPath:SSJChargeImageDirectory()]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:SSJChargeImageDirectory() withIntermediateDirectories:YES attributes:nil error:nil];
    }
    float imageHeight = image.size.height;
    float imageWidth = image.size.width;
    float maxLegth = MAX(imageHeight , imageWidth);
    if (maxLegth > 1000) {
        float scale = 1000 / maxLegth;
        imageHeight = imageHeight * scale;
        imageWidth = imageWidth * scale;
    }
    UIImage *resizeImage = [image ssj_scaleImageWithSize:CGSizeMake(imageWidth, imageHeight)];
    NSString *fullImageName = [imageName hasSuffix:@".jpg"] ? imageName : [NSString stringWithFormat:@"%@.jpg",imageName];
    NSData *imageData = UIImageJPEGRepresentation(resizeImage, 0.4);
    NSString *fullPath = [SSJChargeImageDirectory() stringByAppendingPathComponent:fullImageName];
    return [imageData writeToFile:fullPath atomically:YES];
};

BOOL SSJSaveThumbImage(UIImage *image , NSString *imageName){
    if (![[NSFileManager defaultManager] fileExistsAtPath:SSJChargeImageDirectory()]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:SSJChargeImageDirectory() withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fullImageName = [NSString stringWithFormat:@"%@-thumb.jpg",imageName];
    NSData *imageData = UIImageJPEGRepresentation([image ssj_compressWithinSize:CGSizeMake(50, 50)], 0.5);
    NSString *fullPath = [SSJChargeImageDirectory() stringByAppendingPathComponent:fullImageName];
    return [imageData writeToFile:fullPath atomically:YES];
}

NSString *SSJImagePath(NSString *imageName){
    if (![imageName hasSuffix:@".jpg"]) {
        imageName = [NSString stringWithFormat:@"%@.jpg",imageName];
    }
    NSString *fullImageName = [NSString stringWithFormat:@"%@",imageName];
    NSString *fullPath = [SSJChargeImageDirectory() stringByAppendingPathComponent:fullImageName];
    return fullPath;
};

NSString *SSJGetChargeImageUrl(NSString *imageName){
    if (![imageName hasSuffix:@".jpg"] && ![imageName hasSuffix:@".webp"]) {
        imageName = [NSString stringWithFormat:@"%@.jpg",imageName];
    }
    NSString *path = [NSString stringWithFormat:@"/image/sync/%@", imageName];
    return SSJImageURLWithAPI(path);
}

NSURL *SSJChargeImgUrlWithName(NSString *imgName) {
    if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(imgName)]) {
        return [NSURL fileURLWithPath:SSJImagePath(imgName)];
    } else {
        return [NSURL URLWithString:SSJGetChargeImageUrl(imgName)];
    }
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

NSString *SSJTitleForCycleType(SSJCyclePeriodType type) {
    switch (type) {
        case SSJCyclePeriodTypeOnce:
            return @"仅一次";
            break;
            
        case SSJCyclePeriodTypeDaily:
            return @"每天";
            break;
            
        case SSJCyclePeriodTypeWorkday:
            return @"每个工作日";
            break;
            
        case SSJCyclePeriodTypePerWeekend:
            return @"每个周末（周六、周日）";
            break;
            
        case SSJCyclePeriodTypeWeekly:
            return @"每周";
            break;
            
        case SSJCyclePeriodTypePerMonth:
            return @"每月";
            break;
            
        case SSJCyclePeriodTypeLastDayPerMonth:
            return @"每月最后一天";
            break;
            
        case SSJCyclePeriodTypePerYear:
            return @"每年";
            break;
    }
}

int64_t SSJMilliTimestamp() {
    return (int64_t)([NSDate date].timeIntervalSince1970 * 1000);
}

BOOL SSJVerifyPassword(NSString *pwd) {
    NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:pwd];
}

void SSJSwizzleSelector(Class className, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(className, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(className, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}


#pragma mark - 账本类型个人账本or共享账本
SSJBooksCategory SSJGetBooksCategory() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SSJBookCategoryKey];
}

BOOL SSJSaveBooksCategory(SSJBooksCategory category) {
    [[NSUserDefaults standardUserDefaults] setInteger:category forKey:SSJBookCategoryKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

void SSJClearCurrentBooksCategory() {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SSJBookCategoryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

BOOL SSJJoinQQGroup(NSString *group, NSString *key) {
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", group, key];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    else return NO;
}

static NSString * const kEvaluatedPolicyDomainStateKey = @"kEvaluatedPolicyDomainStateKey";

NSData *SSJEvaluatedPolicyDomainState() {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEvaluatedPolicyDomainStateKey];
}

BOOL SSJUpdateEvaluatedPolicyDomainState(NSData *data) {
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kEvaluatedPolicyDomainStateKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}
