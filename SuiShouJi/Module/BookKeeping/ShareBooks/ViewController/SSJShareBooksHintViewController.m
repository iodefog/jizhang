//
//  SSJShareBooksHintViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/6/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksHintViewController.h"

@interface SSJShareBooksHintViewController ()

@property (nonatomic, strong) UILabel *firstTitleLab;

@property (nonatomic, strong) UILabel *firstContentLab;

@property (nonatomic, strong) UILabel *secondTitleLab;

@property (nonatomic, strong) UILabel *secondContentLab;

@end

@implementation SSJShareBooksHintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

#pragma mark - Getter
- (UILabel *)firstTitleLab {
    if (!_firstTitleLab) {
        _firstTitleLab = [[UILabel alloc] init];
        _firstTitleLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3];
        _firstTitleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _firstTitleLab.text = @"暗号";
    }
    return _firstTitleLab;
}

- (UILabel *)firstContentLab {
    if (!_firstContentLab) {
        _firstContentLab = [[UILabel alloc] init];
        _firstContentLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3];
        _firstContentLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _firstContentLab.text = @"你可通过暗号邀请成员加入共享账本，暗号有效期为12小时。若重新生成暗号并确认使用，则之前的暗号作废。";
    }
    return _firstContentLab;
}

- (UILabel *)secondTitleLab {
    if (!_secondTitleLab) {
        _secondTitleLab = [[UILabel alloc] init];
        _secondTitleLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3];
        _secondTitleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _secondTitleLab.text = @"注意";
    }
    return _secondTitleLab;
}

- (UILabel *)secondContentLab {
    if (!_secondContentLab) {
        _secondContentLab = [[UILabel alloc] init];
        _secondContentLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3];
        _secondContentLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _secondContentLab.text = @"12小时有效期内，输入此暗号的人，将进入到此共享账本中。\nso～，你懂的，为避免不认识的人进入你的共享账本，暗号请尽量复杂化，目前暗号支持中文、英文以及各种符号组合。过了12小时有效期后，此暗号作废，任何人无法再凭此暗号加入。\n你的共享账本你做主，你可以随时删除任意成员。";
    }
    return _secondContentLab;
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
