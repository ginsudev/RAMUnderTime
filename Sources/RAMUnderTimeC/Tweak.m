#import <Orion/Orion.h>
#import <mach/mach.h>
#import "include/Tweak.h"

@implementation memoryInfo

+ (instancetype)sharedInstance {
    static memoryInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[memoryInfo alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (float)get_free_memory {
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
    
    return mem_free/1024/1024;
}

@end

__attribute__((constructor)) static void init() {
    // Initialize Orion - do not remove this line.
    orion_init();
    // Custom initialization code goes here.
}
