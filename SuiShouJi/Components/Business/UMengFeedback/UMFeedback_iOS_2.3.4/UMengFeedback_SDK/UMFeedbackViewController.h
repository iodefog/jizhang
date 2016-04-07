

#import "SSJBaseViewController.h"

@protocol ChatViewDelegate <NSObject>

@optional
- (void)reloadData;
- (void)sendButtonPressed:(NSDictionary *)info;
- (void)updateUserInfo:(NSDictionary *)info;
@end

@interface UMFeedbackViewController : SSJBaseViewController
/**
 *  TODO: more description
 */
@property (nonatomic, strong) NSMutableArray *topicAndReplies;

@property (nonatomic, copy) NSString *strContactPhone;

- (void)refreshData;
- (void)setBackButton:(UIButton *)button;
- (void)setTitleColor:(UIColor *)color;
@end
