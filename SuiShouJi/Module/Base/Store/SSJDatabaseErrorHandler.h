//
//  SSJDatabaseErrorHandler.h
//  SuiShouJi
//
//  Created by old lang on 23/5/17.
//  Copyright © 2023年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDatabaseErrorHandler : NSObject

+ (void)handleError:(NSError *)error;
+ (void)uploadFileData;
@end
