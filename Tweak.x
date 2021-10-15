#import <mach/mach.h>

@interface _UIStatusBarStringView : UILabel
@property (nullable, nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, assign) BOOL shouldUpdateTime;
@property (nonatomic, assign) BOOL isUsingDotFormat;
- (void)amIUsingDotTimeFormat:(NSString *)stringToSearch separator:(NSString *)separator;
@end

@interface UIDevice (RUT)
+ (BOOL)tf_deviceHasFaceID;
+ (BOOL)currentIsIPad;
@end

static unsigned int freeMemory;

#pragma mark - Logic
void get_free_memory() {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);        

    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    }

    /* Stats in bytes */ 
    natural_t mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);

    freeMemory = mem_free/1024/1024;
}

#pragma mark - Status bar configuration.
%hook _UIStatusBarStringView
%property (nonatomic, assign) BOOL shouldUpdateTime;
%property (nonatomic, assign) BOOL isUsingDotFormat;

- (instancetype)initWithFrame:(CGRect)frame {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRam) name:@"RUT_refreshRam" object:nil];
    return %orig;
}

- (void)applyStyleAttributes:(id)arg1 {
    %orig;

    [self amIUsingDotTimeFormat:self.text separator:@"."];

    if ([self.text containsString:@":"] || ([self.text containsString:@"."] && self.isUsingDotFormat)) {
        if ([UIDevice tf_deviceHasFaceID] && ![UIDevice currentIsIPad]) {
            self.numberOfLines = 2;
            self.textAlignment = NSTextAlignmentCenter;
            self.font = [UIFont systemFontOfSize:12];      
            [self setText:self.text];
        }
    }
}

- (void)layoutSubviews {
    %orig;
    if (self.shouldUpdateTime) {
        [self amIUsingDotTimeFormat:self.text separator:@"."];

        if ([self.text containsString:@":"] || ([self.text containsString:@"."] && self.isUsingDotFormat)) {
            [self setText:self.text];
            self.shouldUpdateTime = NO;
        }
    }
}

-(void)setText:(NSString*)text{

    [self amIUsingDotTimeFormat:text separator:@"."];

    if ([text containsString:@":"] || ([text containsString:@"."] && self.isUsingDotFormat)) {
        get_free_memory();

        NSString *spacer = ([UIDevice tf_deviceHasFaceID] && ![UIDevice currentIsIPad]) ? @"\n" : @" - ";

        //Remove pre-existing RAM text, if it exists.
        if ([text containsString:@"MB"]) {
            NSRange range = [text rangeOfString:spacer];
            text = [text substringToIndex: range.location];
        }

        NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];

        if ([UIDevice tf_deviceHasFaceID] && ![UIDevice currentIsIPad]) {
            [finalString setAttributedString: [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]}]];
            [finalString appendAttributedString: [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%d MB", spacer, freeMemory] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}]];
        } else {
            [finalString setAttributedString: [[NSAttributedString alloc] initWithString:text]];
            [finalString appendAttributedString: [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%d MB", spacer, freeMemory]]];
        }
        self.attributedText = finalString;

    } else {
        %orig(text);
    }
}

%new - (void)refreshRam {
    self.shouldUpdateTime = YES;
    [self layoutSubviews];
}

%new - (void)amIUsingDotTimeFormat:(NSString *)stringToSearch separator:(NSString *)separator {
    int times = [[stringToSearch componentsSeparatedByString:separator] count]-1;

    BOOL isRussianiPadDateFormat;
    if (([[stringToSearch componentsSeparatedByString:@" "] count]-1 == 2) && [stringToSearch containsString:@"."]) {
        isRussianiPadDateFormat = YES;
    } else {
        isRussianiPadDateFormat = NO;
    }

    if (times == 1 && !isRussianiPadDateFormat) {
        self.isUsingDotFormat = YES;
    } else {
        self.isUsingDotFormat = NO;
    }
}
%end

#pragma mark - Update status bar when frontmost app changes.
%hook SpringBoard
-(void)frontDisplayDidChange:(id)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RUT_refreshRam" object:nil];
}
%end

%hook SBIconController
-(void)_controlCenterWillDismiss:(id)arg1{
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RUT_refreshRam" object:nil];
}
%end
