#include "sema_lib.h"

int bankbalance = 1000;/*银行帐户余额1000元*/

void main2() {
	int pid, sem_id;
	int t, totalsave = 0, totaldraw = 0;
	sem_id = semaGet(1);
	pid = fork();
	if (pid == -1) {
		print("error in fork!");
		exit(-1);
	}
	if (pid)  {
		while (1)  {
			P(sem_id);
			t = bankbalance;           /*父进程反复存钱，每次10元*/
			delay(200);
			t += 10;
			delay(100);
			bankbalance = t; 
			totalsave += 10;
			print("bankbalance = "); printInt(bankbalance);
			print(",  totalsave = "); printInt(totalsave);
			print("\n\r");
			V(sem_id);
		}
	} 
	else {
		while(1){
			P(sem_id);
			t = bankbalance;           /*子进程反复取钱，每次20元*/
			delay(200);
			t -= 20;
			delay(100);
			bankbalance = t;
			totaldraw += 20;
			print("bankbalance = "); printInt(bankbalance);
			print(",  totaldraw = "); printInt(totaldraw);
			print("\n\r");
			V(sem_id);
		}
	}
}
