
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

@end


@implementation SSJRecordMakingAdditionalView

+ (id)RecordMakingAdditionalView {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SSJRecordMakingAdditionalView" owner:nil options:nil];
    return array[0];
}

-(void)awakeFromNib{
    
}

- (IBAction)additionalButtonClicked:(id)sender {
    if (self.btnClickedBlock) {
        self.btnClickedBlock(((UIButton*)sender).tag);
    }
}

-(void)setSelectedImage:(UIImage *)selectedImage{
    _selectedImage = selectedImage;
    if (_selectedImage == nil) {
        [self.takePhotoButton setBackgroundImage:selectedImage forState:UIControlStateNormal];
        [self.takePhotoButton setTitle:@"拍照" forState:UIControlStateNormal];
    }else{
        [self.takePhotoButton setBackgroundImage:selectedImage forState:UIControlStateNormal];
        [self.takePhotoButton setTitle:@"" forState:UIControlStateNormal];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
