extern void gettime();
extern void printChar();
int totaltime0 = 0;
char timech[6]; /*在kliba.asm中声明的全局变量*/
int row=4, column=6;

int bcd2dec(int n){
	return n/16*10 + n%16;
}

void radomPos() {     					/*获取随机位置 用于OUCH! 出现时位置的随机*/
	gettime();
	totaltime0 =totaltime0 + bcd2dec(timech[6]);
	column += totaltime0;
	column = 4 + (column * 5) % 72;/*55*/
	row += totaltime0;
	row = 4 + (row * 5)% 18;/*20*/
	if(column %2 != 0) ++column;
	if(row % 2 != 0)row++;
	if(row == 9999) row = 4;
	if(column == 19999) column = 4;
}
int strlen(char *str1){
	int k;
	for(k = 0; ; ++ k){
		if(str1[k] == '\0') return k;
	}
}

void reverse(char *target){
	int count;
	int rev_len = strlen(target);
	char cu_tempch[30];
	for(count = 0;count < rev_len;++count) cu_tempch[count] = target[rev_len-count-1];
	for(count = 0;count < rev_len;++count) target[count] = cu_tempch[count];
}

char *itoa(int n){
	char str[10];
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
	return *str;
}