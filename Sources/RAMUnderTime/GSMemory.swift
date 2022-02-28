//
//  GSMemory.swift
//  
//
//  Created by Noah Little on 28/2/2022.
//

import Foundation

final class GSMemory: NSObject {
    
    public func get_free_mem() -> Int64 {
        
        var pagesize: vm_size_t = 0

        let host_port: mach_port_t = mach_host_self()
        var host_size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)
        host_page_size(host_port, &pagesize)

        var vm_stat: vm_statistics = vm_statistics_data_t()
        withUnsafeMutablePointer(to: &vm_stat) { (vmStatPointer) -> Void in
            vmStatPointer.withMemoryRebound(to: integer_t.self, capacity: Int(host_size)) {
                if (host_statistics(host_port, HOST_VM_INFO, $0, &host_size) != KERN_SUCCESS) {
                    NSLog("Error: Failed to fetch vm statistics")
                }
            }
        }

        let mem_free: Int64 = Int64(vm_stat.free_count) * Int64(pagesize)
        return mem_free/1024/1024
    }
    
}
