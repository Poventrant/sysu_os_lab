char outstr[100],cu_tempch[100];
int count, rev_len;
int strcmp(char* str1,char* str2){
	while(*str1 != '\0' && *str2 != '\0'){
		if(*str1 != *str2) return 0;
		str1++;str2++;
	}
	if(*str1 == '\0' && *str2 == '\0') return 1;
	return 0;
}

void strcpy(char *str1,char *str2){
	int i = 0;
	while(str1[i] != '\0'){
		str2[i] = str1[i];
		i++;
	}
	str2[i] = '\0';
}

int strlen(char *str1){
	int k;
	for(k = 0; ; ++ k){
		if(str1[k] == '\0') return k;
	}
}

int substr(char str1[],char str2[],int start,int len){
	int i;
	for(i = start;i < start+len;++i) str2[i-start] = str1[i];
	str2[start+len] = '\0';
}

void strlink(char *p1, char *p2){
	int i;
	int len1 = strlen(p1);
	for(i = 0; ; ++i){
		if(p2[i] == '\0') break;
		p1[len1 + i] = p2[i];
	}
	p1[len1+i] = '\0';
}

void strinsert(char *str1, char *str2, int start){
	int i;
	char insert_ch[50];
	i = strlen(str1);
	substr(str1, insert_ch, start, i-start);
	for(i = start,count = 0; ;++i, count ++){
		if(str2[count] == '\0')break;
		str1[i] = str2[count];
	}
	for(count = 0 ; ;++i, ++count){
		if(insert_ch[count] == '\0') break;
		str1[i] = insert_ch[count];
	}
	str1[i] = '\0';
}

void strremove(char str[], int index0, int len0){
	int tlen = strlen(str);
	for(count = 0; count< len0; ++count){
		for(rev_len = index0; ; ++rev_len){
			if(str[rev_len+1] == '\0') break;
			str[rev_len] = str[rev_len + 1];
		}
		str[tlen - count] = '\0';
	}
	str[tlen - len0] = '\0';
}

int strfind(char str1[], char *str2){/*STR2是字串*/
	int index;
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	for(index = 0; index <= len1 - len2; index ++){
		char temp_ch[50];
		substr(str1, temp_ch, index, len2);
		if(strcmp(str2, temp_ch)) {
			return index; /*str1取下来的子字符串cu_tempch与str2比较*/
		}
	}
	return -1;
}

int checkspace(char str1[],int start ,int index){/*全空格就返回1*/
	int k;
	for(k = start; k < index; ++ k){
		if(str1[k] != ' ') return 0;
	}
	return 1;
}


void reverse(char *target){
	rev_len = strlen(target);
	for(count = 0;count < rev_len;++count) cu_tempch[count] = target[rev_len-count-1];
	for(count = 0;count < rev_len;++count) target[count] = cu_tempch[count];
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

int isDigit(char *str){
	while(*str != '\0'){
		if(*str > '9' || *str < '0') return 0;
		++str;
	}
	return 1;
}

void uppertolower(char str0[]){
	int k;
	for(k = 0; ; ++k) {
		if(str0[k] == '\0') return;
		if(str0[k] >= 'A' && str0[k] <= 'Z') {
			str0[k] = (char)(str0[k] + 32);
		}
	}
}

void toupper(char *p){
	while(*p != '\0'){
		if(*p >= 'a' && *p <= 'z') *p = *p - 32;
		p++;
	}
}

void tolower(char *p) {
	while(*p != '\0'){
		if(*p >= 'A' && *p <= 'Z') *p = *p + 32;
		p++;
	}
}

int atoi(char *str){
	int res = 0;
	if(!isDigit(str)) return 0;
	while(*str != '\0'){
		res *= 10;
		res += (*str - '0');
		++str;
	}	
	return res;
}

int bcd2dec(int n){
	return n/16*10 + n%16;
}

