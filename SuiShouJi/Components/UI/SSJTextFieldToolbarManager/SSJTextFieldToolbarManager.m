//
//  SSJTextFieldAddition.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJTextFieldToolbarManager.h"
#import <objc/runtime.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJTextFieldToolbarManager(@interface)
#pragma mark -
@interface SSJTextFieldToolbarManager ()

@property (nonatomic, strong) NSMutableArray<UITextField *> *textFields;

- (UITextField *)goPreWithCurrentTextField:(UITextField *)textField;

- (UITextField *)goNextWithCurrentTextField:(UITextField *)textField;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextField (SSJToolbar)
#pragma mark -

static const void *kToolbarKey = &kToolbarKey;
static const void *kToolbarOrderKey = &kToolbarOrderKey;
static const void *kToolbarPreItemKey = &kToolbarPreItemKey;
static const void *kToolbarNextItemKey = &kToolbarNextItemKey;
static const void *kToolbarDoneItemKey = &kToolbarDoneItemKey;
static const void *kToolbarSpaceItemKey = &kToolbarSpaceItemKey;
static const void *kSSJTextFieldToolbarManagerKey = &kSSJTextFieldToolbarManagerKey;

@implementation UITextField (SSJToolbar)

- (void)ssj_installToolbar {
    [self.ssj_toolbar setItems:@[self.ssj_spaceItem, self.ssj_doneItem]];
    self.inputAccessoryView = self.ssj_toolbar;
    [self ssj_updateAppearanceAccordingToTheme];
}

- (void)ssj_uninstallToolbar {
    [self ssj_setToolbar:nil];
    [self ssj_setPreItem:nil];
    [self ssj_setNextItem:nil];
    [self ssj_setDoneItem:nil];
    [self ssj_setSpaceItem:nil];
    self.inputAccessoryView = nil;
}

- (void)ssj_updateAppearanceAccordingToTheme {
    self.ssj_toolbar.tintColor = SSJ_MAIN_COLOR;
    self.ssj_toolbar.barTintColor = SSJ_MAIN_FILL_COLOR;
}

- (NSUInteger)ssj_order {
    return [objc_getAssociatedObject(self, kToolbarOrderKey) unsignedIntegerValue];
}

- (void)ssj_setOrder:(NSUInteger)order {
    [self willChangeValueForKey:@"ssj_order"];
    objc_setAssociatedObject(self, kToolbarOrderKey, @(order), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"ssj_order"];
}

- (SSJTextFieldToolbarManager *)ssj_manager {
    return objc_getAssociatedObject(self, kSSJTextFieldToolbarManagerKey);
}

- (void)ssj_setManager:(SSJTextFieldToolbarManager *)manager  {
    objc_setAssociatedObject(self, kSSJTextFieldToolbarManagerKey, manager, OBJC_ASSOCIATION_ASSIGN);
}

- (UIToolbar *)ssj_toolbar {
    UIToolbar *toolbar = objc_getAssociatedObject(self, kToolbarKey);
    if (!toolbar) {
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        [self ssj_setToolbar:toolbar];
    }
    return toolbar;
}

- (void)ssj_setToolbar:(UIToolbar *)toolbar {
    objc_setAssociatedObject(self, kToolbarKey, toolbar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIBarButtonItem *)ssj_preItem {
    UIBarButtonItem *preItem = objc_getAssociatedObject(self, kToolbarPreItemKey);
    if (!preItem) {
        preItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"pre", nil) style:UIBarButtonItemStylePlain target:self action:@selector(ssj_preAction)];
        [self ssj_setPreItem:preItem];
    }
    return preItem;
}

- (void)ssj_setPreItem:(UIBarButtonItem *)item {
    objc_setAssociatedObject(self, kToolbarPreItemKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIBarButtonItem *)ssj_nextItem {
    UIBarButtonItem *nextItem = objc_getAssociatedObject(self, kToolbarNextItemKey);
    if (!nextItem) {
        nextItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"next", nil) style:UIBarButtonItemStylePlain target:self action:@selector(ssj_nextAction)];
        [self ssj_setNextItem:nextItem];
    }
    return nextItem;
}

- (void)ssj_setNextItem:(UIBarButtonItem *)item {
    objc_setAssociatedObject(self, kToolbarNextItemKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIBarButtonItem *)ssj_doneItem {
    UIBarButtonItem *doneItem = objc_getAssociatedObject(self, kToolbarDoneItemKey);
    if (!doneItem) {
        doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(ssj_doneAction)];
        [self ssj_setDoneItem:doneItem];
    }
    return doneItem;
}

- (void)ssj_setDoneItem:(UIBarButtonItem *)item {
    objc_setAssociatedObject(self, kToolbarDoneItemKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIBarButtonItem *)ssj_spaceItem {
    UIBarButtonItem *spaceItem = objc_getAssociatedObject(self, kToolbarSpaceItemKey);
    if (!spaceItem) {
        spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        [self ssj_setSpaceItem:spaceItem];
    }
    return spaceItem;
}

- (void)ssj_setSpaceItem:(UIBarButtonItem *)item {
    objc_setAssociatedObject(self, kToolbarSpaceItemKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ssj_doneAction {
    [self resignFirstResponder];
}

- (void)ssj_preAction {
    [self.ssj_manager goPreWithCurrentTextField:self];
}

- (void)ssj_nextAction {
    [self.ssj_manager goNextWithCurrentTextField:self];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJTextFieldToolbarManager(@implementation)
#pragma mark -
@implementation SSJTextFieldToolbarManager

- (void)dealloc {
    [self uninstallAllTextFieldToolbar];
}

- (instancetype)init {
    if (self = [super init]) {
        self.textFields = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)installTextFieldToolbar:(UITextField *)textField {
    if (!textField || [self.textFields containsObject:textField]) {
        return;
    }
    
    if (!objc_getAssociatedObject(textField, kToolbarOrderKey)) {
        [textField ssj_setOrder:(self.textFields.lastObject.ssj_order + 1)];
    }
    
    if (textField.inputAccessoryView != textField.ssj_toolbar) {
        textField.inputAccessoryView = textField.ssj_toolbar;
        textField.ssj_toolbar.items = @[textField.ssj_preItem,
                                        textField.ssj_nextItem,
                                        textField.ssj_spaceItem,
                                        textField.ssj_doneItem];
    }
    
    [textField ssj_setManager:self];
    [self addTextField:textField];
}

- (void)uninstallTextFieldToolbar:(UITextField *)textField {
    [textField ssj_uninstallToolbar];
    [textField removeObserver:self forKeyPath:@"ssj_order"];
    [self.textFields removeObject:textField];
    [self updateToolbarPreAndNextBtnEnable];
}

- (void)uninstallAllTextFieldToolbar {
    for (UITextField *textField in self.textFields) {
        [textField ssj_uninstallToolbar];
        [textField removeObserver:self forKeyPath:@"ssj_order"];
    }
    [self.textFields removeAllObjects];
}

- (void)addTextField:(UITextField *)textField {
    __block BOOL hasInsert = NO;
    [self.textFields enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([textField ssj_order] == [obj ssj_order]) {
#ifdef DEBUG
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"已经存在相同order的textField"}]];
#endif
        }
        
        if ([textField ssj_order] < [obj ssj_order]) {
            [self.textFields insertObject:textField atIndex:idx];
            hasInsert = YES;
            *stop = YES;
        }
    }];
    
    if (!hasInsert) {
        [self.textFields addObject:textField];
    }
    [self updateToolbarPreAndNextBtnEnable];
    [textField addObserver:self forKeyPath:@"ssj_order" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
}

- (void)updateToolbarPreAndNextBtnEnable {
    [self.textFields enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            obj.ssj_preItem.enabled = NO;
            obj.ssj_nextItem.enabled = YES;
        } else if (idx == self.textFields.count - 1) {
            obj.ssj_preItem.enabled = YES;
            obj.ssj_nextItem.enabled = NO;
        } else {
            obj.ssj_preItem.enabled = YES;
            obj.ssj_nextItem.enabled = YES;
        }
    }];
}

- (UITextField *)goPreWithCurrentTextField:(UITextField *)textField {
    NSUInteger idx = [self.textFields indexOfObject:textField];
    if (idx == NSNotFound) {
#ifdef DEBUG
        [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"当前的textField不在数组中"}]];
#endif
        return nil;
    }
    
    if (idx == 0) {
        return nil;
    }
    
    UITextField *preTextField = self.textFields[--idx];
    [preTextField becomeFirstResponder];
    return preTextField;
}

- (UITextField *)goNextWithCurrentTextField:(UITextField *)textField {
    NSUInteger idx = [self.textFields indexOfObject:textField];
    if (idx == NSNotFound) {
#ifdef DEBUG
        [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"当前的textField不在数组中"}]];
#endif
        return nil;
    }
    
    if (idx >= self.textFields.count - 1) {
        return nil;
    }
    
    UITextField *nextTextField = self.textFields[++idx];
    [nextTextField becomeFirstResponder];
    return nextTextField;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    [self reorderTextFields];
}

- (void)reorderTextFields {
    [self.textFields sortUsingComparator:^NSComparisonResult(UITextField * _Nonnull obj1, UITextField *  _Nonnull obj2) {
        if (obj1.ssj_order < obj2.ssj_order) {
            return NSOrderedAscending;
        } else if (obj1.ssj_order > obj2.ssj_order) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

@end

