

#import "UMFeedbackViewController.h"
#import "UMOpenMacros.h"
#import "UMChatToolBar.h"
#import "UMChatTableViewCell.h"
#import "UMPostTableViewCell.h"
#import "UMFeedback.h"
#import "UMFullScreenPhotoView.h"


static void * kJSQMessagesKeyValueObservingContext = &kJSQMessagesKeyValueObservingContext;
const CGFloat kMessagesInputToolbarHeightDefault = 44.0f;

@interface UMFeedbackViewController () <UITableViewDataSource, UITableViewDelegate, UMFeedbackDataDelegate, UIAlertViewDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate>//UINavigationBarDelegate,

@property(nonatomic, weak) id <ChatViewDelegate> delegate;
@property (nonatomic, strong) UIView *feedbackView;
@property (strong, nonatomic) UITableView *mTableView;
@property (strong, nonatomic) UMChatToolBar *inputToolBar;

/**
 *  顶部联系人信息
 */
@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UILabel *infoLabel;

@property (strong, nonatomic) NSIndexPath *currentIndexPath;

@property (strong, nonatomic) UMFeedback *feedback;
@property (strong, nonatomic) UIColor *titleColor;

@property (assign, nonatomic) BOOL isObserving;
@property (assign, nonatomic) BOOL isKeyboardShow;

@property (strong, nonatomic) UMFullScreenPhotoView *fullScreenView;
@property (assign, nonatomic) UIInterfaceOrientation currentOrientation;
@end

@implementation UMFeedbackViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        self.title = UM_Local(@"Feedback");
        _feedback = [UMFeedback sharedInstance];
        _delegate = (id<ChatViewDelegate>)self.feedback;
    }
    return self;
}

- (void)reloadViewFrame{
    CGSize size = [self getViewSize:_currentOrientation];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    frame.origin.y = self.topViewOffset;
    frame.size.height -= self.topViewOffset;
    
    _feedbackView.frame = frame;
}

- (void)loadViewFrame{
    self.feedbackView = [[UIView alloc] init];
    _feedbackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_feedbackView];
    [self reloadViewFrame];
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    _currentOrientation = UIInterfaceOrientationUnknown;
    
    [self loadViewFrame];
    
    CGFloat height = _feedbackView.frame.size.height - 44 - 0;
    self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _feedbackView.frame.size.width, height)];
    [self.mTableView registerClass:[UMPostTableViewCell class] forCellReuseIdentifier:@"postCellId"];
    [self.mTableView registerClass:[UMChatTableViewCell class] forCellReuseIdentifier:@"chatCellId"];
    self.mTableView.dataSource = self;
    self.mTableView.delegate = self;
    self.mTableView.allowsSelection = YES;
    [self.mTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.mTableView setSeparatorColor:[UIColor redColor]];
    [_feedbackView addSubview:self.mTableView];
    
    CGFloat y = _feedbackView.frame.size.height - 44;
    self.inputToolBar = [[UMChatToolBar alloc] initWithFrame:CGRectMake(0, y, _feedbackView.frame.size.width, 44)];
    self.inputToolBar.isAudioEnabled = [[UMFeedback sharedInstance] audioEnabled];
    [_feedbackView addSubview:self.inputToolBar];
    [self.inputToolBar.rightButton addTarget:self
                                      action:@selector(sendButtonPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
    [self.inputToolBar.plusButton addTarget:self
                                     action:@selector(presentPhotoLibrary:)
                           forControlEvents:UIControlEventTouchUpInside];
    [self.inputToolBar.leftButton addTarget:self
                                     action:@selector(leftButtonPressed:)
                           forControlEvents:UIControlEventTouchUpInside];
    if (self.titleColor) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.titleColor};
    }
    [self setHidesBottomBarWhenPushed:YES];
    [self updateLayoutWithOrientation:self.interfaceOrientation];
}

- (NSMutableDictionary*) mutableDeepCopy:(NSDictionary *)dict {
    NSUInteger count = [dict count];
    NSMutableArray *cObjects = [[NSMutableArray alloc] initWithCapacity:count];
    NSMutableArray *cKeys = [[NSMutableArray alloc] initWithCapacity:count];;
    
    NSEnumerator *e = [dict keyEnumerator];
    unsigned int i = 0;
    id thisKey;
    while ((thisKey = [e nextObject]) != nil) {
        id obj = [dict objectForKey:thisKey];
        // Try to do a deep mutable copy, if this object supports it
        if ([[obj class] isKindOfClass:[NSDictionary class]])
            cObjects[i] = [self mutableDeepCopy:obj];
        // Then try a shallow mutable copy, if the object supports that
        else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)])
            cObjects[i] = [obj mutableCopy];
        // If all else fails, fall back to an ordinary copy
        else
            cObjects[i] = [obj copy];
        // I don't think mutable keys make much sense, so just do an ordinary copy
        cKeys[i] = [thisKey copy];
        ++i;
    }
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithObjects:cObjects forKeys:cKeys];
    // The newly-created dictionary retained these, so now we need to balance the above copies
    for (unsigned int i = 0; i < count; ++i) {
    }
    return ret;
}

- (void)setBackButton:(UIButton *)button {
    [button addTarget:self action:@selector(backToPrevious) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

- (void)setTitleColor:(UIColor *)color {
    _titleColor = color;
}

- (void)backToPrevious {
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self updateLayoutWithOrientation:toInterfaceOrientation];
}

- (void)updateLayoutWithOrientation:(UIInterfaceOrientation)orientation {
    CGSize viewSize = [self getViewSize:orientation];
    _currentOrientation = orientation;
    if (_fullScreenView){
        _fullScreenView.orientation = orientation;
        [_fullScreenView resetViewFrame];
    }
    [self reloadViewFrame];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            CGFloat viewWidth = viewSize.width;
            
            CGRect frame = self.inputToolBar.frame;
            frame.size.width = viewWidth;
            if (self.inputToolBar.isEditMode) {
                frame.size.height = 82;
            } else {
                frame.size.height = 44;
            }
            frame.origin.y = _feedbackView.frame.size.height - frame.size.height;
            self.inputToolBar.frame = frame;
            
            CGFloat inputToolbarHeight = self.inputToolBar.frame.size.height;
            self.mTableView.frame = CGRectMake(0, 0, viewWidth, _feedbackView.frame.size.height - inputToolbarHeight);
            self.infoButton.frame = CGRectMake(viewWidth - 100, 0, 100, 40);
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            CGFloat viewWidth = viewSize.width;
            if (self.inputToolBar.isEditMode) {
                self.inputToolBar.frame = CGRectMake(0, _feedbackView.frame.size.height - 82, viewWidth, 82);
            } else {
                self.inputToolBar.frame = CGRectMake(0, _feedbackView.frame.size.height - 44, viewWidth, 44);
            }
            self.infoButton.frame = CGRectMake(_feedbackView.frame.size.width - 100, 0, 100, 40);
            CGFloat inputToolbarHeight = self.inputToolBar.frame.size.height;
            self.mTableView.frame = CGRectMake(0, 0, viewWidth, _feedbackView.frame.size.height - inputToolbarHeight);
            break;
        }
        default:
            break;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.feedback.delegate = self;
    self.mTableView.delegate = self;
    [self refreshData];
    [self scrollToBottomAnimated:YES];
//    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.inputToolBar.contactInfo = [self mutableDeepCopy:[[UMFeedback sharedInstance] getUserInfo]];
    NSString *strPhoneTemp=[self.inputToolBar.contactInfo valueForKeyPath:@"contact.phone"];
    if (strPhoneTemp.length!=0) {
        [self.inputToolBar.contactInfo setObject:self.strContactPhone forKey:@"contact.phone"];
    }
    NSString *strPhone = strPhoneTemp.length ? strPhoneTemp : self.strContactPhone;
    self.infoLabel.text = [NSString stringWithFormat:UM_Local(@"QQ: %@ Phone: %@ \nEmail: %@ Other: %@"),
                           [self.inputToolBar.contactInfo valueForKeyPath:@"contact.qq"],
                           strPhone,
                           [self.inputToolBar.contactInfo valueForKeyPath:@"contact.email"],
                           [self.inputToolBar.contactInfo valueForKeyPath:@"contact.plain"]];
    self.inputToolBar.inputTextView.text = @"";
    UIEdgeInsets insets = self.mTableView.contentInset;
    insets.bottom = 0;
    self.mTableView.contentInset = insets;
//    [self.view endEditing:YES];
    [self updateLayoutWithOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self jsq_addObservers];
    [self scrollToBottomAnimated:YES];
//    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self.mTableView becomeFirstResponder];
    [self.inputToolBar.inputTextView endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self jsq_removeObservers];
    self.mTableView.delegate = nil;
    [self.inputToolBar.inputTextView endEditing:YES];
//    [self.view endEditing:YES];
}

- (NSMutableArray *)topicAndReplies {
    return self.feedback.topicAndReplies;
}

- (void)tapViewAction:(UITapGestureRecognizer *)tapGesture {
    [self.view endEditing:YES];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:self.mTableView];
    
    NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self setIsEditMode:YES];
    } else {
    }
}

- (void)setIsEditMode:(BOOL)isEditMode {
    [self.inputToolBar setIsEditMode:isEditMode];
    [self.inputToolBar.inputTextView resignFirstResponder];
    [self updateLayoutWithOrientation:self.interfaceOrientation];
    if (isEditMode) {
        [self.inputToolBar.inputTextView becomeFirstResponder];
    } else {
        self.inputToolBar.inputTextView.keyboardType = UIKeyboardTypeDefault;
        [self.inputToolBar.inputTextView resignFirstResponder];
    }
}

- (void)leftButtonPressed:(UIButton *)sender {
    if (self.inputToolBar.isEditMode) {
        [self setIsEditMode:NO];
        [self.inputToolBar cleanInputText];
        self.inputToolBar.contactInfo = [self mutableDeepCopy:[[UMFeedback sharedInstance] getUserInfo]];
    }
}

- (void)presentPhotoLibrary:(UIButton *)button
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum | UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary
        || picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum){
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [_feedback post:@{UMFeedbackMediaTypeImage: image}];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendButtonPressed:(UIButton *)button {
    if (self.inputToolBar.isEditMode) {
        [self setIsEditMode:NO];
        
        self.infoLabel.text = [NSString stringWithFormat:UM_Local(@"QQ: %@ Phone: %@ \nEmail: %@ Other: %@"),
                               [self.inputToolBar.contactInfo valueForKeyPath:@"contact.qq"],
                               [self.inputToolBar.contactInfo valueForKeyPath:@"contact.phone"],
                               [self.inputToolBar.contactInfo valueForKeyPath:@"contact.email"],
                               [self.inputToolBar.contactInfo valueForKeyPath:@"contact.plain"]];
        [self.inputToolBar cleanInputText];
        if ([self.delegate respondsToSelector:@selector(updateUserInfo:)]) {
            [self.delegate updateUserInfo:self.inputToolBar.contactInfo];
        }
        return;
    }
    
    NSDictionary *info;
    if ([self.inputToolBar textValid]) {
        NSString *content = [self.inputToolBar textContent];
        [self.inputToolBar cleanInputText];
        
        info = @{@"content": content};
        [self setIsEditMode:NO];
    } else {
        info = @{};
    }
    [self sendData:info];
    
}

- (void)sendData:(NSDictionary *)info{
    [self.mTableView reloadData];
    [self scrollToBottomAnimated:YES];
    self.currentIndexPath = [NSIndexPath indexPathForRow:self.topicAndReplies.count-1 inSection:0];
    
    if ([self.delegate respondsToSelector:@selector(sendButtonPressed:)]) {
        [self.delegate sendButtonPressed:info];
    }
    self.currentIndexPath = [NSIndexPath indexPathForRow:self.topicAndReplies.count-1 inSection:0];
    [self.mTableView reloadData];
    [self scrollToBottomAnimated:YES];
}

#pragma mark Umeng Feedback delegate
- (void)updateTableView:(NSError *)error{
    [self.mTableView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)getFinishedWithError:(NSError *)error{
    [self updateTableView:error];
}

- (void)postFinishedWithError:(NSError *)error{
    if (error != nil) {
        if (error.code == -1009) {
            NSString *info = error.userInfo[NSLocalizedDescriptionKey];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:info
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:UM_Local(@"OK"), nil];
            [alertView show];
        }
    }
    if ([[[UMFeedback sharedInstance] getUserInfo][@"is_failed"] boolValue]) {
        self.infoLabel.textColor = [UIColor redColor];
    } else {
        self.infoLabel.textColor = [UIColor blackColor];
    }
    if (self.currentIndexPath) {
        [self.mTableView reloadData];
    }
    
    [_feedback get];
}

#pragma mark - Keybaord Show Hide Notification
- (void)keyboardWillShow:(NSNotification *)notification{
    [self keyboardAction:notification isShow:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    self.isKeyboardShow = NO;
    [self keyboardAction:notification isShow:NO];
}

- (void)keyboardDidShow:(NSNotification *)notification{
    self.isKeyboardShow = YES;
}

- (void)keyboardAction:(NSNotification *)aNotification isShow:(BOOL)isShow {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect frame = self.inputToolBar.frame;
    
    if (UM_IOS_8_OR_LATER) {
        frame.origin.y = (_feedbackView.frame.size.height - (isShow ? keyboardEndFrame.size.height : 0)) - self.inputToolBar.frame.size.height;
    } else {
        if (isShow) {
            frame.origin.y = _feedbackView.frame.size.height - keyboardFrame.size.height - frame.size.height;
        } else {
            frame.origin.y = _feedbackView.frame.size.height - frame.size.height;
        }
    }
    self.inputToolBar.frame = frame;
    
    UIEdgeInsets inset = [self.mTableView contentInset];
    if (isShow) {
        inset.bottom = keyboardFrame.size.height + 10 + self.inputToolBar.frame.size.height - 44;
    } else {
        inset.bottom = 10 + self.inputToolBar.frame.size.height - 44;
    }
    [self.mTableView setContentInset:inset];
    
    if (isShow) {
        [self scrollToBottomAnimated:YES];
    }
    
    [UIView commitAnimations];
}

- (CGSize)getViewSize:(UIInterfaceOrientation) interfaceOrientation {
    // for iOS < 8.0
    CGFloat viewWidth, viewHeight, navHeight;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            viewWidth = [UIScreen mainScreen].bounds.size.width;
            viewHeight= [UIScreen mainScreen].bounds.size.height;
            navHeight = 44;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            navHeight = 32;
            viewWidth = [UIScreen mainScreen].bounds.size.height;
            viewHeight = [UIScreen mainScreen].bounds.size.width;
            break;
        }
        default:break;
    }
    viewHeight -= 20;
    viewHeight -= navHeight;
    return CGSizeMake(viewWidth, viewHeight);
}

- (void)close:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)jsq_addObservers{
    if (self.isObserving) {
        return;
    }
    [self.inputToolBar.inputTextView addObserver:self
                                      forKeyPath:NSStringFromSelector(@selector(contentSize))
                                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                         context:kJSQMessagesKeyValueObservingContext];
    
    self.isObserving = YES;
}

- (void)jsq_removeObservers{
    if (!_isObserving) {
        return;
    }
    @try {
        [_inputToolBar.inputTextView removeObserver:self
                                         forKeyPath:NSStringFromSelector(@selector(contentSize))
                                            context:kJSQMessagesKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    _isObserving = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context == kJSQMessagesKeyValueObservingContext) {
        if (self.inputToolBar.isEditMode) {
            return;
        }
        if (object == self.inputToolBar.inputTextView
            && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
            [self adjustInputToolbarForComposerTextViewContentSizeChange:dy];
            //            if (self.automaticallyScrollsToMostRecentMessage) {
            [self scrollToBottomAnimated:NO];
            //            }
        }
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.mTableView numberOfRowsInSection:0] > 1){
        NSUInteger lastRowNumber = [self.mTableView numberOfRowsInSection:0] - 1;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.mTableView scrollToRowAtIndexPath:ip
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:animated];
    }
}

- (CGFloat)topViewOffset {
    CGFloat top = 0;
    
    switch (_currentOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            top = 0;//64
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            top = 32;
            return top;
            break;
        default:
            break;
    }
    return top;
}

- (BOOL)inputToolbarHasReachedMaximumHeight{
    return (CGRectGetMinY(self.inputToolBar.frame) == self.topViewOffset);
}

- (void)adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy{
    BOOL contentSizeIsIncreasing = (dy > 0);
    //        NSLog(@"offset: %f", self.inputToolBar.inputTextView.contentOffset.y);
    
    if ([self inputToolbarHasReachedMaximumHeight]) {
        BOOL contentOffsetIsPositive = (self.inputToolBar.inputTextView.contentOffset.y > -dy);
        //        NSLog(@"offset: %f", self.inputToolBar.inputTextView.contentOffset.y);
        
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self scrollComposerTextViewToBottomAnimated:YES];
            return;
        }
        dy += self.inputToolBar.inputTextView.contentOffset.y + 8;
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputToolBar.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
    //  attempted to increase origin.Y above topLayoutGuide
    if (newToolbarOriginY <= self.topViewOffset) {
        dy = toolbarOriginY - self.topViewOffset;
        [self scrollComposerTextViewToBottomAnimated:YES];
    }
    
    //    NSLog(@"%s: %f", __func__, dy);
    [self adjustInputToolbarHeightByDelta:dy];
    
    if (dy < 0) {
        [self scrollComposerTextViewToBottomAnimated:NO];
    }
}

- (void)adjustInputToolbarHeightByDelta:(CGFloat)dy{
    NSInteger offset = dy;
    CGRect frame = self.inputToolBar.frame;
    frame.size.height += dy;
    if (frame.size.height < kMessagesInputToolbarHeightDefault) {
        dy = 0;
        frame.size.height = kMessagesInputToolbarHeightDefault;
        if (self.inputToolBar.isAudioInput) {
            frame.origin.y = _feedbackView.frame.size.height - kMessagesInputToolbarHeightDefault;
        }
    }
    
    frame.origin.y -= dy;
    self.inputToolBar.frame = frame;
    
    CGRect inputTextViewFrame = self.inputToolBar.inputTextView.frame;
    inputTextViewFrame.size.height += dy;
    self.inputToolBar.inputTextView.frame = inputTextViewFrame;
    [self.inputToolBar.inputTextView scrollsToTop];
    
    CGRect sendButtonFrame = self.inputToolBar.rightButton.frame;
    sendButtonFrame.origin.y += dy;
    self.inputToolBar.rightButton.frame = sendButtonFrame;
    sendButtonFrame = self.inputToolBar.plusButton.frame;
    sendButtonFrame.origin.y += dy;
    self.inputToolBar.plusButton.frame = sendButtonFrame;
    
    UIEdgeInsets inset =  self.mTableView.contentInset;
    // 当编辑框回位时，重置tableview bottom
    inset.bottom += (offset < 0) ? -inset.bottom : dy;
    [self.mTableView setContentInset:inset];
}

- (void)scrollComposerTextViewToBottomAnimated:(BOOL)animated{
    UITextView *textView = self.inputToolBar.inputTextView;
    CGPoint contentOffsetToShowLastLine = textView.contentOffset;
    contentOffsetToShowLastLine.y = textView.contentSize.height - CGRectGetHeight(textView.bounds);
    
    [textView setContentOffset:contentOffsetToShowLastLine animated:animated];
}

#pragma mark - UITableView DataSource & Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isKeyboardShow) {
        [self.view endEditing:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.topicAndReplies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"postCellId";
    UMPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                                forIndexPath:indexPath];
    [cell configCell:self.topicAndReplies[indexPath.row]];
    
    cell.thumbImageButton.tag = indexPath.row;
    [cell.thumbImageButton addTarget:self
                              action:@selector(thumbButtonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.infoView;
}

- (UIView *)infoView {
    if (_infoView == nil) {
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = UM_UIColorFromRGB(238.0, 238.0, 238.0);
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 5, _feedbackView.frame.size.width - 80 - 10, 30)];
        infoLabel.numberOfLines = 0;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.font = [UIFont systemFontOfSize:12.0];
        infoLabel.text = [NSString stringWithFormat:UM_Local(@"QQ: %@ Phone: %@ \nEmail: %@ Other: %@"),
                          [self.inputToolBar.contactInfo valueForKeyPath:@"contact.qq"],
                          [self.inputToolBar.contactInfo valueForKeyPath:@"contact.phone"],
                          [self.inputToolBar.contactInfo valueForKeyPath:@"contact.email"],
                          [self.inputToolBar.contactInfo valueForKeyPath:@"contact.plain"]];
        if ([self.inputToolBar.contactInfo[@"is_failed"] boolValue]) {
            infoLabel.textColor = [UIColor redColor];
        } else {
            infoLabel.textColor = [UIColor blackColor];
        }
        self.infoLabel = infoLabel;
        [view addSubview:infoLabel];
        
        UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(_feedbackView.frame.size.width - 100, 0, 100, 40)];
        infoButton.backgroundColor = [UIColor clearColor];
        infoButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        infoButton.titleLabel.numberOfLines = 0;
        [infoButton setTitle:UM_Local(@"Update info") forState:UIControlStateNormal];
        [infoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [infoButton addTarget:self action:@selector(sectionTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.infoButton = infoButton;
        [view addSubview:infoButton];
        
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionTapped:)]];
        
        _infoView = view;
    }
    return _infoView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndexPath = indexPath;
    if ([self.topicAndReplies[indexPath.row][@"is_failed"] boolValue]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UM_Local(@"Send again?")
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:UM_Local(@"Cancel")
                                                  otherButtonTitles:UM_Local(@"Resend"), nil];
        [alertView show];
    }
    [self.view endEditing:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSDictionary *info = self.topicAndReplies[self.mTableView.indexPathForSelectedRow.row];
        if ([self.delegate respondsToSelector:@selector(sendButtonPressed:)]) {
            [self.delegate sendButtonPressed:info];
        }
    }
}

- (void)sectionTapped:(UIButton *)btn {
    [self setIsEditMode:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *content = self.topicAndReplies[indexPath.row][@"content"];
    if (content.length > 0) {
        CGSize labelSize = [content boundingRectWithSize:CGSizeMake(self.mTableView.frame.size.width - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size;
        return labelSize.height + 28;
    } else {
        if (self.topicAndReplies[indexPath.row][@"pic_id"]){
            return 77;
        }
        return 60;
    }
}

#pragma mark - Events
- (void)thumbButtonPressed:(UIButton *) sender{
    UMPostTableViewCell *cell = (UMPostTableViewCell *)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    CGRect rectInView = [cell convertRect:cell.thumbImageButton.frame toView:self.view];
    
    //    CGRect rectInWindow = [self.view convertRect:rectInView toView:nil];
    
    [self.inputToolBar.inputTextView resignFirstResponder];
    UIImage *image = [_feedback imageByID:self.topicAndReplies[sender.tag][@"pic_id"]];
    if (image){
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        __block UMFeedbackViewController *weakSelf = self;
        self.fullScreenView = [[UMFullScreenPhotoView alloc] initWithFrame:window.bounds];
        _fullScreenView.orientation = _currentOrientation;
        [window addSubview:_fullScreenView];
        [_fullScreenView addImage:image forRect:rectInView dismissCallBack:^{
            weakSelf.fullScreenView = nil;
        }];
    }
}

- (void)refreshData {
    if ([self.delegate respondsToSelector:@selector(reloadData)]) {
        [self.delegate reloadData];
    }
}

@end
