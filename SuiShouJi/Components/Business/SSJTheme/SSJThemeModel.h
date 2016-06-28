//
//  SSJThemeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJThemeModel : NSObject <NSCoding>

//
@property (nonatomic, copy) NSString *ID;

//
@property (nonatomic, copy) NSString *name;

//
@property (nonatomic, copy) NSString *previewUrlStr;

//
@property (nonatomic) double size;

//
@property (nonatomic, copy) NSString *tabBarTintColor;

@property (nonatomic) CGFloat naviBarTitleFontSize;

@property (nonatomic, copy) NSString *naviBarBackgroundColor;

@end
