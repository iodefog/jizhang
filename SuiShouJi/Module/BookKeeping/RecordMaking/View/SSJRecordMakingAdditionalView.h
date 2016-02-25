//
//  SSJRecordMakingAdditionalView.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJRecordMakingAdditionalView : UIView

+ (id)RecordMakingAdditionalView;

typedef void (^btnClickedBlock)(NSInteger buttonTag);

//点击按钮的回调
@property(nonatomic, copy)btnClickedBlock btnClickedBlock;

@property (nonatomic,strong) UIImage *selectedImage;
@end
