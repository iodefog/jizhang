//
//  SSJImaageBrowseViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJImaageBrowseViewController : SSJBaseViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

typedef NS_ENUM(NSInteger, SSJImageBrowseVcType){
    
    //编辑图片
    SSJImageBrowseVcTypeEdite,
    
    //浏览图片
    SSJImageBrowseVcTypeBrowse
};

@property (nonatomic,strong) UIImage *image;

@property (nonatomic,strong) SSJBillingChargeCellItem *item;

@property (nonatomic, assign) SSJImageBrowseVcType type;


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
