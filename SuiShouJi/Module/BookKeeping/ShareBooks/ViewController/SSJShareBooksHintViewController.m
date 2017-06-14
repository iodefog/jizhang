//
//  SSJShareBooksHintViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/6/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksHintViewController.h"

@interface SSJShareBooksHintViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *firstTitleLab;

@property (nonatomic, strong) UILabel *firstContentLab;

@property (nonatomic, strong) UILabel *secondTitleLab;

@property (nonatomic, strong) UILabel *secondContentLab;

@property (nonatomic, strong) UIView *firstRedView;

@property (nonatomic, strong) UIView *secondRedView;

@end

@implementation SSJShareBooksHintViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.appliesTheme = NO;
        self.title = @"暗号注意事项";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.firstTitleLab];
    [self.scrollView addSubview:self.firstContentLab];
    [self.scrollView addSubview:self.secondTitleLab];
    [self.scrollView addSubview:self.secondContentLab];
    [self.scrollView addSubview:self.firstRedView];
    [self.scrollView addSubview:self.secondRedView];
    
    [self.view updateConstraintsIfNeeded];
    // Do any additional setup after loading the view.
}

- (void)updateViewConstraints {
    
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.left.top.equalTo(self.view);
    }];
    
    [self.firstTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(SSJ_NAVIBAR_BOTTOM + 20);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.width.mas_equalTo(self.scrollView.mas_width).offset(-30);
    }];
    
    [self.firstContentLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.firstTitleLab.mas_bottom).offset(23);
        make.left.mas_equalTo(self.firstTitleLab);
        make.width.mas_equalTo(self.scrollView.mas_width).offset(-30);
    }];
    
    [self.secondTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.firstContentLab.mas_bottom).offset(23);
        make.left.mas_equalTo(self.firstContentLab);
        make.width.mas_equalTo(self.scrollView.mas_width).offset(-30);
    }];
    
    [self.secondContentLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.secondTitleLab.mas_bottom).offset(23);
        make.left.mas_equalTo(self.secondTitleLab);
        make.width.mas_equalTo(self.scrollView.mas_width).offset(-30);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-30);
    }];
    
    [self.firstRedView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(6, 16));
        make.left.mas_equalTo(self.scrollView).offset(18);
        make.top.mas_equalTo(self.firstTitleLab).offset(4);
    }];
    
    [self.secondRedView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(6, 16));
        make.left.mas_equalTo(self.scrollView).offset(18);
        make.top.mas_equalTo(self.secondTitleLab).offset(4);
    }];
    
    [super updateViewConstraints];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return  UIStatusBarStyleDefault;
}

#pragma mark - Getter
- (UILabel *)firstTitleLab {
    if (!_firstTitleLab) {
        _firstTitleLab = [[UILabel alloc] init];
        _firstTitleLab.numberOfLines = 0;
        _firstTitleLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3];
        _firstTitleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"暗号"];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        CGFloat emptylen = _firstTitleLab.font.pointSize * 2;
        style.firstLineHeadIndent = emptylen;
        style.alignment = NSTextAlignmentJustified;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, attributeStr.length)];
        _firstTitleLab.attributedText = attributeStr;
    }
    return _firstTitleLab;
}

- (UILabel *)firstContentLab {
    if (!_firstContentLab) {
        _firstContentLab = [[UILabel alloc] init];
        _firstContentLab.numberOfLines = 0;
        _firstContentLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _firstContentLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"你可通过暗号邀请成员加入共享账本，暗号有效期为12小时。若重新生成暗号并确认使用，则之前的暗号作废。"];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        CGFloat emptylen = _firstContentLab.font.pointSize * 2;
        style.firstLineHeadIndent = emptylen;
        style.lineSpacing = 23;
        style.alignment = NSTextAlignmentJustified;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, attributeStr.length)];
        _firstContentLab.attributedText = attributeStr;
    }
    return _firstContentLab;
}

- (UILabel *)secondTitleLab {
    if (!_secondTitleLab) {
        _secondTitleLab = [[UILabel alloc] init];
        _secondTitleLab.numberOfLines = 0;
        _secondTitleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"注意"];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        CGFloat emptylen = _secondTitleLab.font.pointSize * 2;
        style.firstLineHeadIndent = emptylen;
        style.alignment = NSTextAlignmentJustified;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, attributeStr.length)];
        _secondTitleLab.attributedText = attributeStr;
    }
    return _secondTitleLab;
}

- (UILabel *)secondContentLab {
    if (!_secondContentLab) {
        _secondContentLab = [[UILabel alloc] init];
        _secondContentLab.numberOfLines = 0;
        _secondContentLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _secondContentLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"12小时有效期内，输入此暗号的人，将进入到此共享账本中。\nso～，你懂的，为避免不认识的人进入你的共享账本，暗号请尽量复杂化，目前暗号支持中文、英文以及各种符号组合。过了12小时有效期后，此暗号作废，任何人无法再凭此暗号加入。\n你的共享账本你做主，你可以随时删除任意成员。"];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        CGFloat emptylen = _secondContentLab.font.pointSize * 2;
        style.firstLineHeadIndent = emptylen;
        style.lineSpacing = 23;
        style.alignment = NSTextAlignmentJustified;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, attributeStr.length)];
        _secondContentLab.attributedText = attributeStr;
    }
    return _secondContentLab;
}


- (UIView *)firstRedView {
    if (!_firstRedView) {
        _firstRedView = [[UIView alloc] init];
        _firstRedView.backgroundColor = [UIColor ssj_colorWithHex:@"#eb4a64"];
    }
    return _firstRedView;
}

- (UIView *)secondRedView {
    if (!_secondRedView) {
        _secondRedView = [[UIView alloc] init];
        _secondRedView.backgroundColor = [UIColor ssj_colorWithHex:@"#eb4a64"];
    }
    return _secondRedView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentSize = CGSizeMake(self.view.width, 460);
    }
    return _scrollView;
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
