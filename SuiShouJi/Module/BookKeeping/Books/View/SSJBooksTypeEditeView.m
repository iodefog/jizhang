//
//  SSJBooksTypeEditeView.m
//  SuiShouJi
//
//  Created by ricky on 16/5/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeEditeView.h"
#import "YYKeyboardManager.h"
#import "SSJColorSelectCollectionViewCell.h"
#import "SSJDatabaseQueue.h"
#import "SSJBooksTypeStore.h"

@interface SSJBooksTypeEditeView()<YYKeyboardObserver,UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *sepeatorLine;
@property(nonatomic, strong) UITextField *nameInput;
@property(nonatomic, strong) UICollectionView *colorSelectView;
@property(nonatomic, strong) UIButton *comfirmButton;
@property(nonatomic, strong) UIButton *deleteButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) NSArray *colors;
@end

@implementation SSJBooksTypeEditeView{
    NSString *_selectColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.colors = @[@"#7fb04f",@"#f5a237",@"#ff6363",@"#5ca0d9",@"#6a7fe7",@"#eb66a7",@"#ad82dd",@"#2aaf69"];
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        [self addSubview:self.nameInput];
        [self addSubview:self.colorSelectView];
        [self addSubview:self.comfirmButton];
        [self addSubview:self.cancelButton];
        [self addSubview:self.deleteButton];
        self.layer.cornerRadius = 8.f;
        [[YYKeyboardManager defaultManager] addObserver:self];
        [self sizeToFit];
    }
    return self;
}

-(void)dealloc{
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width - 66, [UIApplication sharedApplication].keyWindow.width - 66);
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.bottom = keyWindow.height;
    
    self.centerX = keyWindow.width / 2;
    
    //    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
    //        self.bottom = keyWindow.height;
    //    } timeInterval:0.25 fininshed:NULL];
    
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.6 target:self touchAction:@selector(dismiss)];
    
    [self.nameInput becomeFirstResponder];
    

    
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.nameInput resignFirstResponder];
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:NULL];
    
    if (self.editeViewDismissBlock) {
        self.editeViewDismissBlock();
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.size = CGSizeMake(self.width, 50);
    self.titleLabel.leftTop = CGPointMake(0, 0);
    self.nameInput.size = CGSizeMake(self.width - 28, 54);
    self.nameInput.top = self.titleLabel.bottom;
    self.nameInput.centerX = self.width / 2;
    self.cancelButton.size = CGSizeMake(self.width / 2, 50);
    self.cancelButton.leftBottom = CGPointMake(0, self.height);
    self.comfirmButton.size = CGSizeMake(self.width / 2, 50);
    self.comfirmButton.rightBottom = CGPointMake(self.width, self.height);
    self.colorSelectView.size = CGSizeMake(self.width, self.comfirmButton.top - self.nameInput.bottom);
    self.colorSelectView.leftTop = CGPointMake(0, self.nameInput.bottom);
    self.deleteButton.rightTop = CGPointMake(self.width - 10 , 0);
    self.deleteButton.centerY = self.titleLabel.centerY;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.colors.count;
}

- (NSInteger)numberOfSections{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJColorSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorSelectCollectionViewCell" forIndexPath:indexPath];
    cell.itemColor = self.colors[indexPath.row];
    if ([cell.itemColor isEqualToString:_selectColor.lowercaseString]) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _selectColor = self.colors[indexPath.row];
    [self.colorSelectView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float itemWidth = (self.width - 105) / 4;
    return CGSizeMake(itemWidth, itemWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 30, 30, 14);
}

#pragma mark - @protocol YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationCurve delay:0 options:transition.animationOption animations:^{
        CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.superview];
        CGRect popframe = self.frame;
        popframe.origin.y = kbFrame.origin.y - popframe.size.height - 20;
        self.frame = popframe;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Getter
-(UICollectionView *)colorSelectView{
    if (_colorSelectView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 15;
        flowLayout.minimumLineSpacing = 10;
        _colorSelectView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _colorSelectView.dataSource=self;
        _colorSelectView.delegate=self;
        [_colorSelectView registerClass:[SSJColorSelectCollectionViewCell class] forCellWithReuseIdentifier:@"ColorSelectCollectionViewCell"];
        _colorSelectView.backgroundColor = [UIColor whiteColor];
    }
    return _colorSelectView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _titleLabel.text = @"编辑/添加账本";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel ssj_setBorderStyle:SSJBorderStyleBottom];
        [_titleLabel ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#CCCCCC"]];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

-(UITextField *)nameInput{
    if (!_nameInput) {
        _nameInput = [[UITextField alloc]init];
        _nameInput.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        _nameInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        UILabel *leftLabel = [[UILabel alloc]init];
        leftLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        leftLabel.text = @"账本名称: ";
        leftLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [leftLabel sizeToFit];
        _nameInput.leftView = leftLabel;
        _nameInput.leftViewMode = UITextFieldViewModeAlways;
        [_nameInput ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#CCCCCC"]];
        [_nameInput ssj_setBorderStyle:SSJBorderStyleBottom];
        _nameInput.delegate = self;
        _nameInput.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _nameInput;
}

-(UIButton *)comfirmButton{
    if (!_comfirmButton) {
        _comfirmButton = [[UIButton alloc]init];
        [_comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:@"#EE4F4F"] forState:UIControlStateNormal];
        [_comfirmButton ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleLeft];
        [_comfirmButton ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#EE4F4F"]];
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _comfirmButton;
}

-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]init];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_cancelButton ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#cccccc"]];
        [_cancelButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

#pragma mark - Event
-(void)cancelButtonClicked:(id)sender{
    [self dismiss];
}

-(void)comfirmButtonClicked:(id)sender{
    if (!self.nameInput.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入账本名称"];
        return;
    }
    if (self.nameInput.text.length > 5) {
        [CDAutoHideMessageHUD showMessage:@"账本名称最多输入五个字"];
        return;
    }
    [self dismiss];
    self.item.booksName = [self.nameInput.text ssj_emojiFilter];
//    self.item.booksColor = _selectColor;
    if (self.comfirmButtonClickedBlock) {
        self.comfirmButtonClickedBlock(self.item);
    }
}

-(void)deleteButtonClicked:(id)sender{
    [self dismiss];
    [SSJAnaliyticsManager event:@"delete_account_book"];
    if (self.deleteButtonClickedBlock) {
        self.deleteButtonClickedBlock(self.item);
    }
}

#pragma mark - Setter
-(void)setItem:(SSJBooksTypeItem *)item{
    _item = item;
    if (![_item.booksName isEqualToString:@"添加账本"]) {
        self.nameInput.text = _item.booksName;
//        _selectColor = _item.booksColor;
    }else{
        self.nameInput.text = @"";
        _selectColor = @"#7FB04F";
    }
    if ([_item.booksId isEqualToString:_item.userId] || [_item.booksName isEqualToString:@"添加账本"]) {
        self.deleteButton.hidden = YES;
    }else{
        self.deleteButton.hidden = NO;
    }
    [self.colorSelectView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
