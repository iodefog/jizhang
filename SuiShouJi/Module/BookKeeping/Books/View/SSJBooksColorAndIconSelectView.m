//
//  SSJBooksColorAndIconSelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksColorAndIconSelectView.h"
#import "SSJAddNewTypeColorSelectionView.h"

@interface SSJBooksColorAndIconSelectView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIImageView *selectedTypeView;

@property (nonatomic, strong) SSJAddNewTypeColorSelectionView *colorSelectionView;

@property (nonatomic, strong) NSMutableArray *cellItems;

@property(nonatomic, strong) UILabel *booksParentLab;

@property(nonatomic, strong) UIView *backColorView;

@end

@implementation SSJBooksColorAndIconSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.textField];
        [self addSubview:self.backColorView];
        [self addSubview:self.booksParentLab];
        [self addSubview:self.imageSelectionView];
        [self addSubview:self.colorSelectionView];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    _textField.frame = CGRectMake(0, 0, self.width, 63);
    _backColorView.frame = CGRectMake(0, _textField.bottom, self.width, 34);
    _booksParentLab.left = 30   ;
    _booksParentLab.centerY = _backColorView.centerY;
    _imageSelectionView.frame = CGRectMake(0, _backColorView.bottom, self.width, self.height - _backColorView.bottom - self.colorSelectionView.height);
    _colorSelectionView.bottom = self.height;
}

- (void)updateAppearance {
    _textField.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _textField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入类别名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    [_textField ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    _backColorView.backgroundColor = [UIColor ssj_colorWithHex:@"#f9d2da"];
    _booksParentLab.textColor  = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _colorSelectionView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_colorSelectionView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    [self updateImageSelectionView];
}

- (void)setImages:(NSArray *)images {
    if (![_images isEqualToArray:images]) {
        _images = images;
        self.selectedImage = [_images firstObject];
    }
}

- (void)setColors:(NSArray *)colors {
    if (![_colors isEqualToArray:colors]) {
        _colors = colors;
        self.selectedColor = [_colors firstObject];
    }
}

- (void)setSelectedImage:(NSString *)selectedImage {
    if (![_selectedImage isEqualToString:selectedImage]) {
        _selectedImage = selectedImage;
        [self updateSelectedImage];
        [self updateImageSelectionView];
        //        [self updateColorSelectionView];
    }
}

- (void)setSelectedColor:(NSString *)selectedColor {
    if (![_selectedColor isEqualToString:selectedColor]) {
        _selectedColor = selectedColor;
        [self updateSelectedImage];
        [self updateImageSelectionView];
        [self updateColorSelectionView];
    }
}

- (void)setBooksParent:(NSInteger)booksParent{
    _booksParent = booksParent;
    switch (_booksParent) {
        case 0:{
            self.booksParentLab.text = @"账本收支类型: 日常账本";
            [self.booksParentLab sizeToFit];
        }
            break;
            
        case 1:{
            self.booksParentLab.text = @"账本收支类型: 生意账本";
            [self.booksParentLab sizeToFit];
        }
            
            break;
            
        case 2:{
            self.booksParentLab.text = @"账本收支类型: 结婚账本";
            [self.booksParentLab sizeToFit];
        }
            break;
            
        case 3:{
            self.booksParentLab.text = @"账本收支类型: 装修账本";
            [self.booksParentLab sizeToFit];
        }
            break;
            
        case 4:{
            self.booksParentLab.text = @"账本收支类型: 旅行账本";
            [self.booksParentLab sizeToFit];
        }
            break;
    
        default:{
            self.booksParentLab.text = @"日常账本";
            [self.booksParentLab sizeToFit];
        }
            break;
    }
}

- (void)setDisplayColorRowCount:(CGFloat)displayColorRowCount {
    _colorSelectionView.displayRowCount = displayColorRowCount;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _textField) {
        [_textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Private
- (void)updateSelectedImage {
    _selectedTypeView.tintColor = [UIColor ssj_colorWithHex:_selectedColor];
    _selectedTypeView.image = [[UIImage imageNamed:_selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_selectedTypeView sizeToFit];
    _selectedTypeView.left = 30;
    _selectedTypeView.centerY = _textField.height * 0.5;
}

- (void)updateImageSelectionView {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:_images.count];
    for (NSString *image in _images) {
        SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc] init];
        item.categoryImage = image;
        if (_selectedImage && [image isEqualToString:_selectedImage]) {
            item.categoryColor = _selectedColor;
        } else {
            item.categoryColor = SSJ_CURRENT_THEME.secondaryColor;
        }
        [items addObject:item];
    }
    _imageSelectionView.items = items;
    _imageSelectionView.selectedIndexs = @[@([_images indexOfObject:_selectedImage])];
    [_imageSelectionView updateAppearance];
}

- (void)updateColorSelectionView {
    _colorSelectionView.colors = _colors;
    _colorSelectionView.selectedIndex = [_colors indexOfObject:_selectedColor];
}

#pragma mark - Event
- (void)colorSelectionViewAction {
    self.selectedColor = [_colorSelectionView.colors ssj_safeObjectAtIndex:_colorSelectionView.selectedIndex];
    
    if (_selectColorAction) {
        _selectColorAction(self);
    }
}

#pragma mark - Getter
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.width, 63)];
        _textField.font = [UIFont systemFontOfSize:15];
        _textField.delegate = self;
        [_textField ssj_setBorderWidth:1];
        [_textField ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, _textField.height)];
        [leftView addSubview:self.selectedTypeView];
        _textField.leftView = leftView;
        _textField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _textField;
}

- (UIImageView *)selectedTypeView {
    if (!_selectedTypeView) {
        _selectedTypeView = [[UIImageView alloc] init];
    }
    return _selectedTypeView;
}

- (SSJCategoryEditableCollectionView *)imageSelectionView {
    if (!_imageSelectionView) {
        __weak typeof(self) wself = self;
        _imageSelectionView = [[SSJCategoryEditableCollectionView alloc] init];
        _imageSelectionView.editable = NO;
        _imageSelectionView.itemSize = CGSizeMake((self.width - 20) * 0.2, 70);
        _imageSelectionView.selectedItemsChangeHandle = ^(SSJCategoryEditableCollectionView *view) {
            SSJRecordMakingCategoryItem *selectedItem = [view.selectedItems firstObject];
            wself.selectedImage = selectedItem.categoryImage;
            if (wself.selectImageAction) {
                wself.selectImageAction(wself);
            }
        };
        _imageSelectionView.didScrollHandle = ^(SSJCategoryEditableCollectionView *view, CGPoint velocity) {
            if (velocity.y < 0) {
                [wself.textField resignFirstResponder];
            } else {
                [wself.textField becomeFirstResponder];
            }
        };
    }
    return _imageSelectionView;
}

- (SSJAddNewTypeColorSelectionView *)colorSelectionView {
    if (!_colorSelectionView) {
        _colorSelectionView = [[SSJAddNewTypeColorSelectionView alloc] initWithWidth:self.width];
        _colorSelectionView.displayRowCount = 2.5;
        _colorSelectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        [_colorSelectionView ssj_setBorderWidth:1];
        [_colorSelectionView ssj_setBorderStyle:SSJBorderStyleTop];
        [_colorSelectionView addTarget:self action:@selector(colorSelectionViewAction) forControlEvents:UIControlEventValueChanged];
    }
    return _colorSelectionView;
}

- (UILabel *)booksParentLab{
    if (!_booksParentLab) {
        _booksParentLab = [[UILabel alloc]init];
        _booksParentLab.font = [UIFont systemFontOfSize:18];
        _booksParentLab.backgroundColor = [UIColor clearColor];
        _booksParentLab.textColor  = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _booksParentLab;
}

- (UIView *)backColorView{
    if (!_backColorView) {
        _backColorView = [[UIView alloc]init];
        _backColorView.backgroundColor = [UIColor ssj_colorWithHex:@"#f9d2da"];
    }
    return _backColorView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
