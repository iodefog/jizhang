//
//  SSJJspatchAnalyze.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/5/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJJsPatchItem.h"
#import "SSJBaseNetworkService.h"

@interface SSJJspatchAnalyze : NSObject<SSJBaseNetworkServiceDelegate>

+ (void)SSJJsPatchAnalyzePatch;

+ (void)removePatch;

@end
