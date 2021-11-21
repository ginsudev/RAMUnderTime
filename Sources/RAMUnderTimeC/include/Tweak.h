#import <Foundation/Foundation.h>

@interface memoryInfo : NSObject
+ (instancetype)sharedInstance;
- (float)get_free_memory;
@end
