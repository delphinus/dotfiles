/* Show CPU Usage */
#include <mach/mach.h>
#include <mach/mach_error.h>
#include <stdio.h>

int main() {
	natural_t cpuCount;
	processor_info_array_t infoArray;
	mach_msg_type_number_t infoCount;
	kern_return_t kr;
	processor_cpu_load_info_data_t* cpuLoadInfo;
	unsigned long old_ticks,new_ticks,old_totalTicks,new_totalTicks;
	int cpu,state;
	FILE *file=fopen("/Users/delphinus/.screen/.cpu.old","r");
	if (file == NULL) old_ticks = old_totalTicks = 0;
	else fscanf(file,"%ld %ld",&old_ticks,&old_totalTicks);
	fclose(file);

	/* get information */
	kr = host_processor_info(mach_host_self(),
			PROCESSOR_CPU_LOAD_INFO, &cpuCount, &infoArray, &infoCount);
	if (kr) {
		mach_error("host_processor_info error:", kr);
		return kr;
	}

	cpuLoadInfo = (processor_cpu_load_info_data_t*) infoArray;

	new_ticks = new_totalTicks = 0;
	for (cpu = 0; cpu<cpuCount; cpu++){
		/* state 0:user, 1:system, 2:idle, 3:nice */
		for (state = 0; state<CPU_STATE_MAX; state++) {
			if(state != 2)
				new_ticks += cpuLoadInfo[cpu].cpu_ticks[state];
			new_totalTicks += cpuLoadInfo[cpu].cpu_ticks[state];
		}
	}

	printf("%5.1lf\n",(double)(new_ticks - old_ticks)/(new_totalTicks - old_totalTicks)*100);
	if((file = fopen("/Users/delphinus/.screen/.cpu.old","w")) != NULL){
		fprintf(file,"%lu %lu",new_ticks,new_totalTicks);
		fclose(file);
	}
	vm_deallocate(mach_task_self(), (vm_address_t)infoArray, infoCount);

	return 0;
}
