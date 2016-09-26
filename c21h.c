extern void OUCH_21H();
extern void L2U_21H();
extern int A2I_21H();
extern int I2A_21H();
extern void DSP_21H();
extern int LEN_21H();

int i_21h,esc_press=0,ilen_21h;
char instr_21h[100], chlen_21h[100], hang_21h[5], lie_21h[5];

void beupper(char *p){
	toupper(p);
}
void belower(char *p){
	tolower(p);
}
int beint(char *p){
	return atoi(p);
}
void bestr(char *p, int n){
	itoa(p, n);
}
int bestrlen(char *p){
	return strlen(p);
}


void print_menu_21h(){
	print("\r\n         ah0.print \"OUCH!\"       ah1.lower2upper       ah2.upper2lower\n\r");
	print("         ah3.alp2int             ah4.int2string        ah5.disp2pos   \n\r");
	print("         ah6.strlen        PRESS ESC TO BACK TO LAST INTERFACE!       \n\n");
}

void esc_op(){
	esc_press = 0;
	clr();
	print_menu_21h();
}

void cint21h_0(){
	OUCH_21H();
	clr();
	print_menu_21h();
}

void cint21h_1(){
	while(1){
		print("\r\nINT 21H_1>");
		esc_press = getline(instr_21h,32);
		if(esc_press == 1) {
			esc_op();
			return;
		}
		L2U_21H(instr_21h);
		print("The upper is: ");
		print(instr_21h);
	}
}

void cint21h_2(){
	while(1){
		print("\r\nINT 21H_2>");
		esc_press = getline(instr_21h,32);
		if(esc_press == 1) {
			esc_op();
			return;
		}
		U2L_21H(instr_21h);
		print("The lower is: ");
		print(instr_21h);
	}
}

void cint21h_3(){
	while(1){
		print("\r\nINT 21H_3>");
		esc_press = getline(instr_21h,32);
		if(esc_press == 1) {
			esc_op();
			return;
		}
		if(!isDigit(instr_21h)){
			print("Only digital!");
			continue;
		}
		print("The int is: ");
		itoa(chlen_21h, A2I_21H(instr_21h));
		print(chlen_21h);
	}
}

void cint21h_4(){
	while(1){
		print("\r\nINT 21H_4>");
		esc_press = getline(instr_21h,32);
		if(esc_press == 1) {
			esc_op();
			return;
		}
		if(!isDigit(instr_21h)){
			print("Only digital!");
			continue;
		}
		print("The int is: ");
		I2A_21H(chlen_21h, atoi(instr_21h));
		print(chlen_21h);
	}
}

void cint21h_5(){
	while(1){
		print("\n\r input the string which you want to print. ");
		print("\r\nINT 21H_5>");
		esc_press = getline(instr_21h,32);
		if(esc_press == 1) {
			esc_op();
			return;
		}
		while(1){	
			print(" Then input the output position with row and column.\r\n ");
			print("$row>");
			esc_press = getline(hang_21h,3);
			if(esc_press == 1) {
				esc_op();
				return;
			}
			print("$column>");
			esc_press = getline(lie_21h,3);
			if(esc_press == 1) {
				esc_op();
				return;
			}
			i_21h = atoi(hang_21h);
			ilen_21h = atoi(lie_21h);
			if((i_21h < 24 && i_21h > 0) && (ilen_21h <78 && ilen_21h > 0)) break;
			else print("Erro : 0 < row < 24 and 0 < column < 78 .");
		}
		clr();
		DSP_21H(instr_21h, i_21h, ilen_21h, strlen(instr_21h));
		esc_op();
	}
}

void cint21h_6(){
	while(1){
		print("\r\nINT 21H_6>");
		esc_press = getline(instr_21h,32);
		if(esc_press == 1) {
			esc_op();
			return;
		}
		print("The len is: ");
		itoa(chlen_21h, LEN_21H(instr_21h));
		print(chlen_21h);
	}
}

void cint21h(){
	print_menu_21h();
	while(1){
		print("\rINT 21H>");
	    esc_press = getline(instr_21h,32);
		if(esc_press == 1){
			clr();
			break;
		}
		ilen_21h = strlen(instr_21h);
		if(strfind(instr_21h,"ah0") != -1) {
			i_21h = strfind(instr_21h,"ah0");
			if(checkspace(instr_21h,0,i_21h) && checkspace(instr_21h,i_21h+3,ilen_21h)) cint21h_0();
			else print("wrong synax!\n");
		}
		else if(strfind(instr_21h,"ah1") != -1) {
			i_21h = strfind(instr_21h,"ah1");
			if(checkspace(instr_21h,0,i_21h) && checkspace(instr_21h,i_21h+3,ilen_21h)) cint21h_1();
			else print("wrong synax!\n");
		}
		else if(strfind(instr_21h,"ah2") != -1) {
			i_21h = strfind(instr_21h,"ah2");
			if(checkspace(instr_21h,0,i_21h) && checkspace(instr_21h,i_21h+3,ilen_21h)) cint21h_2();
			else print("wrong synax!\n");
		}
		else if(strfind(instr_21h,"ah3") != -1) {
			i_21h = strfind(instr_21h,"ah3");
			if(checkspace(instr_21h,0,i_21h) && checkspace(instr_21h,i_21h+3,ilen_21h)) cint21h_3();
			else print("wrong synax!\n");
		}
		else if(strfind(instr_21h,"ah4") != -1) {
			i_21h = strfind(instr_21h,"ah4");
			if(checkspace(instr_21h,0,i_21h) && checkspace(instr_21h,i_21h+3,ilen_21h)) cint21h_4();
			else print("wrong synax!\n");
		}
		else if(strfind(instr_21h,"ah5") != -1) {
			i_21h = strfind(instr_21h,"ah5");
			if(checkspace(instr_21h,0,i_21h) && checkspace(instr_21h,i_21h+3,ilen_21h)) cint21h_5();
			else print("wrong synax!\n");
		}
		else if(strfind(instr_21h,"ah6") != -1) {
			i_21h = strfind(instr_21h,"ah6");
			if(checkspace(instr_21h,0,i_21h) && checkspace(instr_21h,i_21h+3,ilen_21h)) cint21h_6();
			else print("wrong synax!\n");
		}
		else{
			print(" Please input valid choice. \r\n");
		}
	}
}