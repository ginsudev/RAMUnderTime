#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface _UIStatusBarStringView : UILabel
@property (nonatomic, assign, readwrite) NSInteger fontStyle;
@end

@interface SpringBoard : UIApplication

@end

@interface SBIconController : UIViewController

@end

@interface UIDevice (Private)
+ (BOOL)currentIsIPad;
+ (BOOL)tf_deviceHasFaceID;
@end
