#define MAX_PROCESS 10
int current_PCB = 0;/*当前进程编号 */
int processNum = 1;/*进程数量*/
int current_Seg = 0x1000;	/* 操作系统内核段地址 */		
int Timer_status=1;/* 时钟状态*/
int active_time;/* 总的用户进程活动时间*/
typedef enum ProcessStatus{NEW, RUNNING, READY, BLOCKED, EXIT}ProcessStatus;
typedef struct asmRegs{
	int SS, GS,FS,ES,DS,DI,SI,BP,SP;
	int BX,DX,CX,AX,IP,CS,Flags;
	int firstRun;			/*是否是第一次运行*/
	int father_id;		/*子进程的父进程的对于的ID号*/
	ProcessStatus status;
}asmRegs;

asmRegs PCBs[MAX_PROCESS];		/*最多8个进程*/
asmRegs *PCB_ing; 

asmRegs* getCurrentPCB(){
	return &PCBs[current_PCB];
}

void PCB_store(int ax,int bx, int cx, int dx, int bp, int si,int di,int sp,
			  int ds ,int es,int fs,int gs, int ss,int ip, int cs,int fl){
	PCB_ing = getCurrentPCB();
	PCB_ing->AX = ax;
	PCB_ing->BX = bx;
	PCB_ing->CX = cx;
	PCB_ing->DX = dx;
	PCB_ing->DS = ds;
	PCB_ing->ES = es;
	PCB_ing->FS = fs;
	PCB_ing->GS = gs;
	PCB_ing->SS = ss;
	PCB_ing->IP = ip;
	PCB_ing->CS = cs;
	PCB_ing->Flags = fl;
	PCB_ing->DI = di;
	PCB_ing->SI = si;
	PCB_ing->SP = sp;
	PCB_ing->BP = bp;
}

void Schedule(){
	if(PCB_ing->status == RUNNING || PCB_ing->status == NEW)
		PCB_ing->status = READY;
	
	while(1){
		current_PCB  ++;
		if(current_PCB >= processNum) current_PCB = 1;
		if(PCBs[current_PCB].status == READY|| PCBs[current_PCB].status == NEW) 
			break;
	}
	PCB_ing = getCurrentPCB();
	PCB_ing->status = RUNNING;
}

void PCB_create(asmRegs *p, int seg, int isFirstRun){
	p->GS = 0xb800;
	p->ES = seg;
	p->DS = seg;
	p->FS = seg;
	p->SS = seg;
	p->DI = 0;
	p->SI = 0;
	p->BP = 0;
	p->SP = 0x100 - 4;		/*各个进程的堆栈都不同的段地址，分开考虑*/
	p->BX = 0;
	p->AX = 0;
	p->CX = 0;
	p->DX = 0;
	p->IP = 0x100;
	p->CS = seg;
	p->Flags = 512;
	p->firstRun = isFirstRun;
	p->status = NEW;
	p->father_id = 0;
}

int createNewPCB(){
	if(processNum > MAX_PROCESS) return;
	current_Seg += 0x1000;		 /*相对是先加再赋值*/
	PCB_create(&PCBs[processNum], current_Seg,1);/*用户进程段地址依次是0x2000   0x3000  0x4000 .....*/
	processNum++;
	return current_Seg;
}

void PCB_init() {
	processNum = 1;
	current_Seg = 0x1000;
	current_PCB = 0;
	active_time = 0;
}

void process_exit(){
	active_time = 0;
	return;
}

void user_PCBStart(int time){
	int delay1 =5000,delay2 =5000;
	active_time = time;
	clr();
	Timer_status = 0;						/*进如用户进程的真假值*/
	while(delay1--){						/*避免下一次时钟中断还没到就PCB_init()了，下一次时钟中断到了才能判断Timer_status进入用户进程*/
		while(delay2--);
	}
}

/**************************************************************************************************************************************************
***************************************************************************************************************************************************/
void memcopy(asmRegs *PCB0){				/* 父进程 PCB 复制到 子进程 */
	PCB0->status = READY;
	PCB0->firstRun = 0;
	PCB0->father_id = current_PCB;			/*这个子进程的父进程的current_PCB*/
	PCB0->GS = 0xb800;
	PCB0->ES = PCB_ing->ES;
	PCB0->DS = PCB_ing->DS;
	PCB0->FS = PCB_ing->FS;
	PCB0->SS = current_Seg;
	PCB0->DI = PCB_ing->DI;
	PCB0->SI = PCB_ing->SI;
	PCB0->BP = PCB_ing->BP;
	PCB0->SP = PCB_ing->SP;
	PCB0->AX = 0;							/*子进程的返回值 0 */
	PCB0->BX = PCB_ing->BX;
	PCB0->CX = PCB_ing->CX;
	PCB0->DX = PCB_ing->DX;
	PCB0->IP = PCB_ing->IP;
	PCB0->CS = PCB_ing->CS;
	PCB0->Flags = PCB_ing->Flags;
}

int do_fork() {										/*这个时候firstRun已经等于0*/
	print("        kernal begin -- forking -- ");
	if(processNum > MAX_PROCESS) {
		print("sub process create fail! -- kernal end\r\n");
		PCB_ing->AX = -1;
		return -1;
	}
	current_Seg += 0x1000;   				 	/*相对是先加再赋值*********************/
	memcopy(&PCBs[processNum]);					/* 创建子进程进程控制块  /*PCB_ing->AX就是返回值，赋值给pid*/ 
	PCB_ing->AX = processNum;
	stackCopy(PCBs[processNum].SS,PCB_ing->SS,0x100);		/* 复制父进程堆栈给子进程 */
	processNum ++;
	print("sub process created! -- kernal end\r\n");
}

int do_wait() {
	print("        kernal begin -- Waiting -- ");
	PCB_ing->status = BLOCKED;							/*父进程暂时结束*/
	Schedule();												/* 重新调度进程 */
	print("Schedule process -- kernal end\r\n");
}

void do_exit(int mark) {
	if(mark == 1 || mark == -1){
		process_exit();
	}
	else if( mark == 0) {
		print("        kernal begin -- exiting -- kernal end\r\n\r\n");
		PCBs[current_PCB].status = EXIT;
		PCBs[PCB_ing->father_id].status = READY;			/*重启父进程*/
		PCBs[PCB_ing->father_id].AX = mark;
		current_Seg -= 0x1000;
		processNum --;										/*删除进程2->1*/
		if(processNum == 1) Timer_status = 1;
		Schedule();											/* 进程退出后寻找下一个进程进行执行 */
	}
}
/**************************************************************************************************************************************************
**************************************************************************************************************************************************/

#define MAX_SEMA 100
#define MAX_BLOCKED_PCB 10

typedef struct do_blockedQueue {
	int bQueue[MAX_BLOCKED_PCB];
	int front, rear;
}do_blockedQueue;

typedef struct do_PhoreType {
	int count, used;
	do_blockedQueue blocq;
}do_PhoreType;

do_PhoreType sem_queue[MAX_SEMA];

void initSema() {
	int i;
	for(i = 0;i < MAX_SEMA;++i) {
		sem_queue[i].used = 0;
		sem_queue[i].count = 0;
		sem_queue[i].blocq.front = 0;
		sem_queue[i].blocq.rear = 0;
	}
}

int semaGet(int value) {
	int s = 0;
	while(sem_queue[s].used && s < MAX_SEMA) s++;
	if(s < MAX_SEMA) {
		sem_queue[s].used = 1;
		sem_queue[s].count = value;
		sem_queue[s].blocq.front = 0;
		sem_queue[s].blocq.rear = 0;
		PCBs[current_PCB].AX = s;
	}
	else PCBs[current_PCB].AX = -1; /* error 返回值为-1*/
}

int semaFree(int s) {/* 释放信号量 */
	sem_queue[s].used = 0;
}

int getBlockedQueueRear(int s){
	return sem_queue[s].blocq.rear;
}

void setBlockedQueueRear(int s){
	int s_rear = getBlockedQueueRear(s);
	sem_queue[s].blocq.bQueue[s_rear] = current_PCB;
	sem_queue[s].blocq.rear = (s_rear + 1)%MAX_BLOCKED_PCB;
}

int getBlockedQueueFront(int s){
	return sem_queue[s].blocq.front;
}

void setBlockedQueueFront(int s){
	int s_front = getBlockedQueueFront(s);
	PCBs[sem_queue[s].blocq.bQueue[s_front]].status = READY;
	sem_queue[s].blocq.front = (s_front + 1)%MAX_BLOCKED_PCB;
}

void semaBlock(int s) {/* 把进程加入对应信号量的阻塞队列 */
	int s_rear = getBlockedQueueRear(s);
	int s_front = getBlockedQueueFront(s);
	PCBs[current_PCB].status = BLOCKED;
	if((s_rear + 1)%MAX_BLOCKED_PCB == s_front) {
		print("Kernal: The blocked queue is full.\r\n");
		return;
	}
	setBlockedQueueRear(s);
}

void semaWakeUp(int s) {/* 从阻塞队列唤醒一个进程 */
	int s_rear = getBlockedQueueRear(s);
	int s_front = getBlockedQueueFront(s);
	if(s_rear == s_front) {
		print("Kernal: Empty queue.\r\n");
		return ;
	}
	setBlockedQueueFront(s);
}

void do_P(int s) {
	sem_queue[s].count--;
	if(sem_queue[s].count < 0) { 	/* count 小于 0 要阻塞 */
		semaBlock(s);
		schedule();
	}
}

void do_V(int s) {
	sem_queue[s].count++;
	if(sem_queue[s].count <= 0) { 	/* count 小于等于 0 要唤醒一个阻塞进程 */
		semaWakeUp(s);
		schedule();
	}
}
