#include "user_lib.h"

char str[80] = "129djwqhdsajd128dw9i39ie93i8494urjoiew98kdkd";
int LetterNr = 0;
char incp;
int id = 0;

void main() {
   int pid;
   char ch;
   
   cprintf("\r\nUser father process : \r\n", 10);
   
   print("    fork() begin\r\n");
   pid = fork();
   if(id == 1) cprintf("\r\nUser sub process : \r\n", 13);
   print("    fork() end\r\n");
   print("    The pid is : ");printInt(pid);print("\r\n");
   if(pid == -1) {								/*创建子进程失败 返回值 AX = -1 */
	   print("    Error in fork()!. \r\n");
	   exit(-1); 
   }
   if(pid) {									/*父进程，创建子进程成功之后 返回值 AX = 子进程的ID号*/
	   id = 1;
	   print("    wait() begin\r\n");
	   ch = wait();								/*进入子进程*/
	   cprintf("User father process : \r\n", 10);
	   print("    wait() end\r\n");
	   print("    LetterNr=");
	   printInt(LetterNr);
	   print("\r\n\r\n");
	   print("    Now you can press esc or wait for some time to go back to kernal. \r\n");
	   incp = getchar();
	   if((int)incp == 27) exit(1);				/*ESC 键退出 或者等待一段时间自动退出*/
   }
   else {										/*子进程，这个时候因为子进程的AX = 0， 所以在子进程中进入*/
	   print("    Sub process is running to get the strlen of LetterNr.\r\n");
	   LetterNr = strlen(str);
	   id = 0;
	   print("    exit(0) begin \r\n");
	   exit(0);
	   print("    exit(0) end \r\n");
   }
}

