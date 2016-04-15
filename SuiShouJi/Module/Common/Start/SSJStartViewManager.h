//
//  SSJStartViewManager.h
//  SuiShouJi
//
//  Created by old lang on 16/4/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJStartViewManager : NSObject

- (void)showWithCompletion:(void(^)(SSJStartViewManager *))completion;

@end
