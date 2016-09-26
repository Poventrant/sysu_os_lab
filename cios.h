int icp, jcp;
int esc_press_cp = 0;
char incp;

void print(char *p){
	while(*p != '\0'){
		printChar(*p);
		p++;
	}
}

int only_esc(){
	while(1){
		incp = getchar();
		if((int)incp == 27) break;
	}
}

int getline(char arr[],int overlen){
	if(overlen == 0) return esc_press_cp;
	icp = 0;
	incp = getchar();
	for( ;incp != '\n' && incp != '\r'; ){   				/* 回车键*/
		esc_press_cp = 0;
		if((int)incp == 27){								/*ESC键*/
			esc_press_cp = 1;
			break;
		}
		if((int)incp == 8){                   			 /* 退格键*/
			if(icp <= 0) {
				incp = getchar();
				continue;
			}
			icp--;
			backspace();
			incp = getchar();
			continue;
		}
		printChar(incp);
		arr[icp++] = incp;
		if(icp >= overlen){
			arr[icp] = '\0';
			printChar('\n');
			return esc_press_cp;
		}
		incp = getchar();
	}
	arr[icp] = '\0';
	print("\n\r");
    return esc_press_cp;
}



void getch(char *ch){
	char te[32];
	getline(te,32);
	*ch = te[0];
}

void gets(char * str){
	getline(str, 100);
}


void scanf(char *type0, int *n){
	char t_type0[32],num[10];
	strcpy(type0,t_type0);			/*right*/
	getline(num, 10);
	icp = strfind(type0, "%d");		/*right*/
	strinsert(t_type0, num, icp);
	strremove(t_type0, icp + strlen(num), 2);
	print(t_type0);
	*n = atoi(num);
}

int putch(char ch){
	printChar(ch);
	return ch;
}

int puts(char *str){
	jcp = strlen(str);
	for(icp = 0; icp < jcp; ++ icp){
		printChar(str[icp]);
	}
	print("\n\r");
	return 1;
}

void printint(char *t_type0, char ch, int n, char *str){
	char num[32],type0[100];
	strcpy(t_type0,type0);
	icp = strfind(type0, "%c");
	strinsert(type0, &ch, icp);
	strremove(type0, icp+1, 2);
	
	itoa(num, n);
	icp = strfind(type0, "%d");
	strinsert(type0, num, icp);
	strremove(type0, icp+strlen(num), 2);
	
	icp = strfind(type0, "%s");
	strinsert(type0, str, icp);
	strremove(type0, icp+strlen(str), 2);
	print(type0);
}

void asc2char(char *ascii, int len0){
	int times = len0;
	while(times --) {
		printChar(*ascii);
		++ ascii;
	}
	print("\n\r");
}