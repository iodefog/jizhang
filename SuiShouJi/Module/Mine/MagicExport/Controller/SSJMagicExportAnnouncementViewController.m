//
//  SSJMagicExportAnnouncementViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportAnnouncementViewController.h"

@implementation SSJMagicExportAnnouncementViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"关于邮箱收件的通知";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 40;
    style.paragraphSpacing = 30;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"亲爱的用户您好：\n各大邮箱公司正在审核本司发送的邮箱属性，若您在“收件箱”收不到邮件，可至您邮箱里的“广告邮件”或“垃圾邮件”中查看 。\n很抱歉给您带来不便，我们正加速解决此问题，感谢您的理解与支持。" attributes:@{NSParagraphStyleAttributeName:style}];
    
    UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(35, 30 + SSJ_NAVIBAR_BOTTOM, self.view.width - 55, self.view.height - 30 - SSJ_NAVIBAR_BOTTOM)];
    contentLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    contentLab.attributedText = text;
    contentLab.numberOfLines = 0;
    [contentLab sizeToFit];
    contentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [self.view addSubview:contentLab];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:nil];
}

@end
