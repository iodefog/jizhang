//
//  SSJImaageBrowseViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJImaageBrowseViewController : SSJBaseViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) UIImage *image;


/**
 *  选择新的图片的回调
 *
 *  @param image 回传的图片
 */
typedef void (^NewImageSelectedBlock)(UIImage *image);


@property (nonatomic, copy) NewImageSelectedBlock NewImageSelectedBlock;


/**
 *  删除图片的回调
 */
typedef void (^DeleteImageBlock)();


@property (nonatomic, copy) DeleteImageBlock DeleteImageBlock;
@end
