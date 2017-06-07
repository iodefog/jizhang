//
//  SSJRecordMakingBillTypeSelectionCellItem.h
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJRecordMakingBillTypeSelectionCellState) {
    SSJRecordMakingBillTypeSelectionCellStateNormal = 0,
    SSJRecordMakingBillTypeSelectionCellStateSelected,
    SSJRecordMakingBillTypeSelectionCellStateEditing
};

@interface SSJRecordMakingBillTypeSelectionCellItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *colorValue;

@property (nonatomic, copy) NSString *ID;

@property (nonatomic) int order;

@property (nonatomic) SSJRecordMakingBillTypeSelectionCellState state;

//@property (nonatomic) BOOL animated;

+ (instancetype)itemWithTitle:(NSString *)title
                    imageName:(NSString *)imageName
                   colorValue:(NSString *)colorValue
                           ID:(NSString *)ID
                        order:(int)order;

@end
