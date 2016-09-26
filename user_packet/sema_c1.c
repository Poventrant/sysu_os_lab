#include "sema_lib.h"

int test_num = 0;

/*生产者-消费者问题*/
void main1() {
	int empty,full,pid;
	empty = semaGet(1);		/*在这个例子中，返回值empty=0*/
	full = semaGet(0);		/*在这个例子中，返回值full=1*/
	pid = fork();
	print("\n\r  pid == ");
	printInt(pid);
	print("\n\r");
	if(pid) {			/*父进程fork()返回的是pid>0,子进程fork()=0*/
		while(1) {		/*消费者*/
			P(full);			/*堵塞父进程*/
			/********************************************************/
			delay(500);				/*  在这个过程中如果切换进程  	*/
			printInt(test_num);		/*  那么P(empty)也会堵住子进程  */
			print("  ");			/*  父进程也会继续进行     	    */
			/********************************************************/
			V(empty);
		}
    }
	else {			/*子进程入口*/
		while(1) {	/*生产者*/
			P(empty);
			test_num ++;
			V(full);			/*释放父进程*/
			delay(100);
		}
	}
}

