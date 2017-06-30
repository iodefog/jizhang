//
//  SSJAppUpdateModel.h
//  SuiShouJi
//
//  Created by ricky on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJAppUpdateModel : NSObject

@property(nonatomic, strong) NSString *appVersion;

@property(nonatomic) NSInteger upgradeType;

@property(nonatomic, strong) NSString *upgradeContent;

@property(nonatomic, strong) NSString *upgradeUrl;

@end
