//
//  SSJDebugUtil.h
//  SuiShouJi
//
//  Created by old lang on 15/11/19.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG

@interface SSJDebugTimer : NSObject

+ (void)markStartTime;

+ (void)logTimeInterval;

@end

#endif

