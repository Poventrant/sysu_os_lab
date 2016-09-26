#include "sema_lib.h"

char words[60];
char fruit_disk = 0;
int randFake = 0;
int start = 0;

void putwords(char *p) {
	int i = 0;
	while(*p != '\0') {
		words[i++] = *p;
		p++;
	}
	return;
}

char putfruit(){
	randFake ++;
	fruit_disk = (randFake%2 + '1');
}  

void main3(){
	int s=semaGet(0);
	if (fork()){
		while(1) { 
			P(s); 
			P(s); 
			if(start){
				cprintf(words,10);
				cprintf("Father enjoys fruit ",10);
				printChar(fruit_disk);
				cprintf(".\n\r",10);
				start = 0;
			} 
			fruit_disk=0;
		}
	}
	else if(fork()){
		while(1) { 
			cprintf("son1 sends words.\n\r",14);
			putwords("Father will live one year after anther for ever!\n\r");
			delay(1000);
			V(s);
		}
	}
	else{
		while(1) { 
			cprintf("son2 puts fruit into the disk.\n\r",14);
			putfruit(); 
			start = 1;
			delay(1000);
			V(s);
		}
	}
}


