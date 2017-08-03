//
//  SSJStartTextItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJStartTextItem : NSObject

@property (nonatomic, copy) NSString *color;

@property (nonatomic, copy) NSString *fontSize;

@property (nonatomic, copy) NSString *textAuthor;

@property (nonatomic, copy) NSString *textContent;

@end

@interface SSJStartTextImgItem : NSObject

@property (nonatomic, copy) NSString *imgUrl;

@property (nonatomic, copy) NSArray<SSJStartTextItem *> *texts;



@end


