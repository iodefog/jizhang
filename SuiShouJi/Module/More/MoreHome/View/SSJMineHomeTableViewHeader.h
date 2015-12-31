//
//  SSJMineHomeTableViewHeader.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMineHomeTableViewHeader : UIView
+ (id)MineHomeHeader;
@property (weak, nonatomic) IBOutlet UIButton *portraitButton;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end
