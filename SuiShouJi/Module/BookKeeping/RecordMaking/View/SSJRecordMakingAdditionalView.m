
//
//  SSJRecordMakingAdditionalView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingAdditionalView.h"

@interface SSJRecordMakingAdditionalView()
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *circleButton;
@property (weak, nonatomic) IBOutlet UIButton *memoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takephotoLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleButtonTrailing;

@end


@implementation SSJRecordMakingAdditionalView

+ (id)RecordMakingAdditionalView {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SSJRecordMakingAdditionalView" owner:nil options:nil];
    return array[0];
}

-(void)awakeFromNib{
    self.lineHeight.constant = 1.f / [UIScreen mainScreen].scale;
    self.takephotoLeading.constant = self.width / 2 / 2 - 21;
    self.circleButtonTrailing.constant = self.width / 2 / 2 - 21;
    [self.takePhotoButton setBackgroundImage:[UIImage imageNamed:@"paizhao"] forState:UIControlStateNormal];
//    [self.]
}

- (IBAction)additionalButtonClicked:(id)sender {
    if (self.btnClickedBlock) {
        self.btnClickedBlock(((UIButton*)sender).tag);
    }
}

-(void)setSelectedImage:(UIImage *)selectedImage{
    _selectedImage = selectedImage;
    if (_selectedImage == nil) {
        [self.takePhotoButton setBackgroundImage:[UIImage imageNamed:@"paizhao"] forState:UIControlStateNormal];
    }else{
        [self.takePhotoButton setBackgroundImage:selectedImage forState:UIControlStateNormal];
    }
}

-(void)setHasCircle:(BOOL)hasCircle{
    _hasCircle = hasCircle;
    self.circleButton.selected = _hasCircle;
}

-(void)setHasMemo:(BOOL)hasMemo{
    _hasMemo = hasMemo;
    self.memoButton.selected = _hasMemo;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
