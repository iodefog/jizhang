//
//  SSJListMenuItem.h
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJListMenuItem : NSObject

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *title;

+ (instancetype)itemWithImageName:(NSString *)imageName title:(NSString *)title;

@end
