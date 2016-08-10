//
//  SSJThemeDownLoadCompleteService.h
//  SuiShouJi
//
//  Created by ricky on 16/8/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJThemeDownLoadCompleteService : SSJBaseNetworkService
- (void)downloadCompleteThemeWithThemeId:(NSString *)Id;
@end
