//
//  SSJMotionPasswordHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJMotionPasswordHelper : NSObject

+ (NSArray *)queryMotionPassword;

+ (BOOL)saveMotionPassword:(NSArray *)password;

@end
