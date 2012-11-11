#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/host_info.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
    struct host_basic_info host;
    struct vm_statistics vm_info;
    mach_msg_type_number_t count;
    kern_return_t kr;
    vm_size_t pagesize;

    count = HOST_BASIC_INFO_COUNT;
    kr = host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&host, &count);

    count = HOST_VM_INFO_COUNT;
    kr = host_statistics(mach_host_self(),HOST_VM_INFO,(host_info_t)&vm_info,&count);

    kr = host_page_size(mach_host_self(),&pagesize);

    uint64_t memory_size;
    size_t len = sizeof(memory_size);
    sysctlbyname("hw.memsize", &memory_size, &len, NULL, 0);

    if(kr == KERN_SUCCESS)
        printf("%5.1lf\n",(((double)(vm_info.wire_count + vm_info.active_count)*pagesize)/memory_size)*100);
        return 0;
}
