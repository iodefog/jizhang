//
//  SSJIDFAUploader.m
//  SuiShouJi
//
//  Created by old lang on 17/4/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJIDFAUploader.h"
#import "SSJIdfaUploadService.h"
#import <AdSupport/ASIdentifierManager.h>
#import "SimulateIDFA.h"
#import "SSJNetworkReachabilityManager.h"

static BOOL hasUploadIdfa = NO;

@interface SSJIDFAUploader ()

@property(nonatomic, strong) SSJIdfaUploadService *uploadService;

@end

@implementation SSJIDFAUploader

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeNetworkStatus) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

+ (void)observeNetworkStatus {
    [SSJNetworkReachabilityManager observeReachabilityStatusChange:^(SSJNetworkReachabilityStatus status) {
        if (hasUploadIdfa) {
            return;
        }
        if (status == SSJNetworkReachabilityStatusReachableViaWWAN
            || status == SSJNetworkReachabilityStatusReachableViaWiFi) {
            [self uploadIdfa];
            hasUploadIdfa = YES;
        }
    }];
}

// 上传idfa
+ (void)uploadIdfa {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *idfa;
        if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
            idfa = [NSString stringWithFormat:@"%@",[ASIdentifierManager sharedManager].advertisingIdentifier];
        } else{
            idfa = [SimulateIDFA createSimulateIDFA];
        }
        NSString *lastUploadIdfa = [[NSUserDefaults standardUserDefaults] objectForKey:SSJLastSavedIdfaKey];
        if (![lastUploadIdfa isEqualToString:idfa] || !lastUploadIdfa) {
            SSJIdfaUploadService *service = [[SSJIdfaUploadService alloc] initWithDelegate:NULL];
            [service uploadIdfaWithIdfaStr:idfa Success:^(NSString *idfaStr) {
                [[NSUserDefaults standardUserDefaults] setObject:idfaStr forKey:SSJLastSavedIdfaKey];
            }];
        }
    });
}

@end
