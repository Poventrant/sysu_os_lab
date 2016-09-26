extern int fork();
extern int wait();
extern void exit();
extern void getChar();
extern void printchar();
extern void backspace();
extern void cprintf();

int strlen(char *str1){
	int k;
	for(k = 0; ; ++ k){
		if(str1[k] == '\0') return k;
	}
}

void reverse(char *target){
	int rev_len = 0, count;
	char cu_tempch[100];
	rev_len = strlen(target);
	for(count = 0;count < rev_len;++count) cu_tempch[count] = target[rev_len-count-1];
	for(count = 0;count < rev_len;++count) target[count] = cu_tempch[count];
}

void print(char *p){
	while(*p != '\0'){
		printChar(*p);
		p++;
	}
}

void itoa(char str[], int n){
	int i = 0;
	if(n == 0){
		str[0] = '0';
		i++;
	}
	while(n){
		int t = n%10;
		str[i++] = '0'+t;
		n/=10;
	}
	str[i] = '\0';
	reverse(str);
}

void printInt(int num) {
	char t_str[100];
	itoa(t_str, num);
	print(t_str);
}
