
//
//  SSJInviteCodeJoinViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJInviteCodeJoinViewController.h"
#import "UIViewController+MMDrawerController.h"

#import "SSJCodeEnterBooksService.h"
#import "SSJShareBooksSyncTable.h"
#import "SSJShareBooksMemberSyncTable.h"
#import "SSJUserChargeSyncTable.h"
#import "SSJShareBooksFriendMarkSyncTable.h"
#import "SSJUserDefaultBillTypesCreater.h"

#import "SSJDatabaseQueue.h"
#import "SSJCodeInputEnableService.h"
#import "SSJDataSynchronizer.h"

@interface SSJInviteCodeJoinViewController ()

@property(nonatomic, strong) UIView *backView;

@property(nonatomic, strong) UITextField *codeInput;

@property(nonatomic, strong) UILabel *customCodeLab;

@property(nonatomic, strong) UIButton *sendButton;

@property(nonatomic, strong) SSJCodeEnterBooksService *service;

@property(nonatomic, strong) SSJCodeInputEnableService *verifyCodeInputService;

@end

@implementation SSJInviteCodeJoinViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"暗号加入";
        self.appliesTheme = NO;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"sharebk_backgroud"];
    [self.view addSubview:self.backView];
    [self.backView addSubview:self.codeInput];
    [self.backView addSubview:self.customCodeLab];
    [self.view addSubview:self.sendButton];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    
    [self.view setNeedsUpdateConstraints];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.verifyCodeInputService request];
}

- (void)updateViewConstraints {
    
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(200);
        make.width.mas_equalTo(self.view.mas_width).offset(-35);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM + 30);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.codeInput mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.backView.mas_width).offset(-44);
        make.height.mas_equalTo(57);
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.top.mas_equalTo(self.backView).offset(36);
    }];
    
    [self.customCodeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeInput.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.codeInput);
    }];
    
    [self.sendButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(224, 46));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.backView.mas_bottom);
    }];
    

    [super updateViewConstraints];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.service cancel];
}

#pragma mark - Getter
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.cornerRadius = 16.f;
        _backView.layer.shadowOffset = CGSizeMake(0, 2);
        _backView.layer.shadowColor = [UIColor ssj_colorWithHex:@"#000000"].CGColor;
        _backView.layer.shadowOpacity = 0.15;
    }
    return _backView;
}

- (UITextField *)codeInput {
    if (!_codeInput) {
        _codeInput = [[UITextField alloc] init];
        if (self.inviteCode.length) {
            _codeInput.text = self.inviteCode;
        }
        _codeInput.returnKeyType = UIReturnKeyDone;
        _codeInput.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _codeInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _codeInput.textAlignment = NSTextAlignmentCenter;
        [_codeInput ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#DDDDDD"]];
        [_codeInput ssj_setBorderStyle:SSJBorderStyleBottom];
        [_codeInput ssj_setBorderWidth:1.f];
        _codeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入暗号" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#CCCCCC"]}];
        _codeInput.rightViewMode = UITextFieldViewModeAlways;
        _codeInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        _codeInput.tintColor = [UIColor ssj_colorWithHex:@"#333333"];
        @weakify(self);
        [_codeInput.rac_textSignal subscribeNext:^(id x) {
            @strongify(self);
            if (self.codeInput.text.length == 0) {
                self.sendButton.backgroundColor = [UIColor ssj_colorWithHex:@"#CCCCCC"];
                self.sendButton.layer.shadowColor = [UIColor blackColor].CGColor;
                self.sendButton.layer.shadowOpacity = 0.15;
                self.sendButton.userInteractionEnabled = NO;
            } else {
                self.sendButton.backgroundColor = [UIColor ssj_colorWithHex:@"#EE4F4F"];
                self.sendButton.layer.shadowColor = [UIColor ssj_colorWithHex:@"#EE4F4F"].CGColor;
                self.sendButton.layer.shadowOpacity = 0.39;
                self.sendButton.userInteractionEnabled = YES;
            }
        }];
    }
    return _codeInput;
}

- (UILabel *)customCodeLab {
    if (!_customCodeLab) {
        _customCodeLab = [[UILabel alloc] init];
        _customCodeLab.textColor = [UIColor ssj_colorWithHex:@"#999999"];
        _customCodeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _customCodeLab.text = @"对上暗号，即可加入";
        [_customCodeLab sizeToFit];
    }
    return _customCodeLab;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _sendButton.layer.cornerRadius = 23.f;
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"芝麻开门" forState:UIControlStateNormal];
        _sendButton.backgroundColor = [UIColor ssj_colorWithHex:@"#EE4F4F"];
        _sendButton.layer.shadowOffset = CGSizeMake(0, 4);
        [_sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (SSJCodeEnterBooksService *)service {
    if (!_service) {
        _service = [[SSJCodeEnterBooksService alloc] initWithDelegate:self];
    }
    return _service;
}

- (SSJCodeInputEnableService *)verifyCodeInputService {
    if (!_verifyCodeInputService) {
        _verifyCodeInputService = [[SSJCodeInputEnableService alloc] initWithDelegate:self];
        
    }
    return _verifyCodeInputService;
}

#pragma mark - Event
- (void)sendButtonClicked:(id)sender {
    [self.service enterBooksWithCode:self.codeInput.text];
    [SSJAnaliyticsManager event:@"sb_anhao_zhimakaimen"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if (service == self.service) {
        if ([service.returnCode isEqualToString:@"1"]) {
            @weakify(self);
            [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
                @strongify(self);
                NSError *error = nil;
                
                NSInteger maxOrder = [db intForQuery:@"select max(iorder) from bk_share_books where cbooksid in (select cbooksid  from bk_share_books_member where cmemberid = ? and istate = ?)",SSJUSERID(),@(SSJShareBooksMemberStateNormal)] + 1;
                
                NSString *booksId = self.service.shareBooksTableInfo[@"cbooksid"];
                
                if (self.service.shareBooksTableInfo) {
                    [self.service.shareBooksTableInfo setObject:@(maxOrder) forKey:@"iorder"];
                }
                
                if (![db executeUpdate:@"delete from bk_share_books_member where cbooksid = ?",booksId]) {
                    return;
                }
                
                if (![SSJShareBooksSyncTable mergeRecords:@[self.service.shareBooksTableInfo] forUserId:SSJUSERID() inDatabase:db error:&error]) {
                    return;
                }
                
                if (![SSJShareBooksMemberSyncTable mergeRecords:self.service.shareMemberTableInfo forUserId:SSJUSERID() inDatabase:db error:&error]) {
                    return;
                }
                
                if (![SSJUserChargeSyncTable mergeRecords:self.service.userChargeTableInfo forUserId:SSJUSERID() inDatabase:db error:&error]) {
                    return;
                }
                
                if (![SSJShareBooksFriendMarkSyncTable mergeRecords:self.service.shareFriendMarkTableInfo forUserId:SSJUSERID() inDatabase:db error:&error]) {
                    return;
                }
                
                if (![db executeUpdate:@"delete from bk_user_charge where cbooksid = ? and ibillid = ?",booksId,@"13"]) {
                    return;
                }
                
                
                if (![db executeUpdate:@"update bk_user set ccurrentbooksid = ? where cuserid = ?",booksId,SSJUSERID()]) {
                    return;
                }
                
                NSError *tError = nil;
                SSJBooksType booksType = [self.service.shareBooksTableInfo[@"iparenttype"] integerValue];
                [SSJUserDefaultBillTypesCreater createDefaultDataTypeForUserId:SSJUSERID() booksId:booksId booksType:booksType inDatabase:db error:&tError];
                if (tError) {
                    return;
                }
                
                NSString *bookName = [db stringForQuery:@"select cbooksname from bk_share_books where cbooksid = ?",booksId];
                
                SSJDispatchMainSync(^{
                    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
                    if (self.inviteCodeJoinBooksBlock) {
                        self.inviteCodeJoinBooksBlock(bookName);
                    }
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
                [SSJAnaliyticsManager event:@"sb_anhao_input_success"];
            }];
        } else {
            [CDAutoHideMessageHUD showMessage:service.desc];
            [SSJAnaliyticsManager event:@"sb_anhao_input_error"];
        }

    } else {
        if ([service.returnCode isEqualToString:@"-2008"]) {
            self.codeInput.text = service.desc;
            self.codeInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
            self.codeInput.textColor = [UIColor ssj_colorWithHex:@"#EE4F4F"];
            self.codeInput.enabled = NO;
        } else {
            self.codeInput.enabled = YES;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
