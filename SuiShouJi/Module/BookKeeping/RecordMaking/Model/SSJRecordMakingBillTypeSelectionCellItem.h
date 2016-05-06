//
//  SSJRecordMakingBillTypeSelectionCellItem.h
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJRecordMakingBillTypeSelectionCellItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *colorValue;

@property (nonatomic, copy) NSString *ID;

@property (nonatomic) BOOL showDeleteBtn;

@property (nonatomic) BOOL selected;

@property (nonatomic) BOOL editable;

@property (nonatomic) BOOL animated;

+ (instancetype)itemWithTitle:(NSString *)title
                    imageName:(NSString *)imageName
                   colorValue:(NSString *)colorValue
                           ID:(NSString *)ID;

@end
