#include <config.h>
#include <mach/mach.h>
#include <mach/mach_error.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/mman.h>

char            *mach_error_string(mach_error_t error_value)
{
  return "Unknown mach error";
}

mach_port_t mach_host_self(void)
{
  return 0;
}

kern_return_t host_info
(
 host_t host,
 host_flavor_t flavor,
 host_info_t host_info_out,
 mach_msg_type_number_t *host_info_outCnt
 )
{
  if(flavor == HOST_BASIC_INFO) {
    host_basic_info_t      basic_info;

    basic_info = (host_basic_info_t) host_info_out;
    memset(basic_info, 0x00, sizeof(*basic_info));
    basic_info->cpu_type = EMULATED_HOST_CPU_TYPE;
    basic_info->cpu_subtype = EMULATED_HOST_CPU_SUBTYPE;
  }

  return 0;
}

mach_port_t     mach_task_self_ = 0;

kern_return_t mach_port_deallocate
(
 ipc_space_t task,
 mach_port_name_t name
 )
{
  return 0;
}

kern_return_t vm_allocate
(
 vm_map_t target_task,
 vm_address_t *address,
 vm_size_t size,
        int flags
 )
{

  vm_address_t addr = 0;

  addr = (vm_address_t)calloc(size, sizeof(char));
  if(addr == 0)
    return 1;

  *address = addr;

  return 0;
}

kern_return_t vm_deallocate
(
 vm_map_t target_task,
 vm_address_t address,
        vm_size_t size
 )
{
  free((void *)address);

  return 0;
}

kern_return_t map_fd(
                     int fd,
                     vm_offset_t offset,
                     vm_offset_t *va,
                     boolean_t findspace,
                     vm_size_t size)
{

  void *addr = NULL;
  int pagesize = getpagesize();
  
  //  size = ((size + pagesize - 1) / pagesize) * pagesize;

  addr = mmap(0, size, PROT_READ,
	      MAP_SHARED|MAP_FILE, fd, offset);

  if(addr == (void *)-1) {
    return 1;
  }

  *va = (vm_offset_t)addr;

  return 0;
}
