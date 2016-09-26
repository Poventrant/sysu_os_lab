char timech[6]; /*在kliba.asm中声明的全局变量*/
extern char outstr[100];
int totaltime0;
int base = 0;
int row=3 , column=7;

void radomPos() {     					/*获取随机位置 用于OUCH! 出现时位置的随机*/
	gettime();
	totaltime0 =totaltime0 + bcd2dec(timech[5]) * 60;
	totaltime0 =totaltime0 + bcd2dec(timech[6]);
	column += totaltime0;
	column = (column * 5) % 76;
	row += totaltime0;
	row = (row * 5)% 24;
	return;
}

void timeType(char ch){
	int temp = bcd2dec(ch);
	if(temp == 0) print("00");
	else if(temp > 0 && temp < 10) printChar('0');
	itoa(outstr,temp);
	print(outstr);
}

void time(){
	int year;
	gettime();
	print("Current time : ");
	year = bcd2dec(timech[0])*100 + bcd2dec(timech[1]);	
	itoa(outstr,year);print(outstr);printChar('-');timeType(timech[2]);	printChar('-');timeType(timech[3]);
	print("  ");
	timeType(timech[4]);printChar(':');timeType(timech[5]);printChar(':');timeType(timech[6]);
	print("\n\n");
}

void info(int choice){
	if(choice == 1){
		clr();
		print("\n\r\n\r\n\r\n\r\n\r");
		menu();
	}
	else if(choice == 2){
		cprintf(" 1.exe : you can run the user programs like exe 312\n\r",LightGreen);
		cprintf(" 2.time : you can get the system time \n\r", LightGreen);
		cprintf(" 3.int : the interrupt of 33h - 36h\n\r", LightGreen);
		cprintf(" 4.21h : enter the interface interrupt 21h\n\r", LightGreen);
		cprintf(" 5.asc : input like asc aBc to get the character's ascii\n\r", LightGreen);
		cprintf(" 6.info : get the information of each choice\n\r", LightGreen);
		cprintf(" 7.clr : clean the screen\n\r", LightGreen);
		cprintf(" 8.hlt : jump to crash\n\r", LightGreen);
		cprintf(" 9.run : run the processes like run 1234\n\r", LightGreen);
		cprintf(" 10.fork : to get the string's length by running sub process\n\r", LightGreen);
		cprintf(" 11.semaphore : try the semaphore 1 or 2 or 3.\n\r", LightGreen);
	}
}


int jcf, icf;
int isLoadPro(int index, char instr0[], char Load_temp[], char limit){				/*获得EXE字符后面正确的运行程序*/
	int count_load;
	icf = strlen(instr0);
	if(index >= icf || checkspace(instr0,index,icf)) {
		print("please make a choice of programs.\n\n");
		return 0;
	}
	count_load = 0;
	for(jcf = index; jcf < icf; ++jcf){
		if(instr0[jcf] != ' ' && (instr0[jcf] < '1' || instr0[jcf] > limit)){
			print("There is no program ");
			printChar(instr0[jcf]);
			print(", try integers which are stisfy the relation	of 1 <= int <= ");printChar(limit);print(".\n\n");
			return 0;
		}
		if(instr0[jcf] != ' ')Load_temp[count_load ++] = instr0[jcf];
	}
	Load_temp[count_load] = '\0';
	return 1;
}

void asc(char ch){
	int icf = ch;
	print("The ASCII of ");
	printChar(ch);
	print(" is :");
	itoa(outstr,icf);
	print(outstr);
	print("\n\r");
	return;
}

/*================================USER LOADER===================================*/
int userProgramLoader(int number, int seg, int offset){
	if(number == 1) return loadUserFile("PRO1    BIN", seg, offset, current_dir.cluster0);
	else if(number == 2) return loadUserFile("PRO2    BIN", seg, offset,current_dir.cluster0);
	else if(number == 3) return loadUserFile("PRO3    BIN", seg, offset, current_dir.cluster0);
}

int userProcessLoader(int number, int seg, int offset){
	if(number == 1)return loadUserFile("PROCES1 BIN", seg, offset, current_dir.cluster0);
	else if(number == 2)return loadUserFile("PROCES2 BIN", seg, offset, current_dir.cluster0);
	else if(number == 3)return loadUserFile("PROCES3 BIN", seg, offset, current_dir.cluster0);
	else if(number == 4)return loadUserFile("PROCES4 BIN", seg, offset, current_dir.cluster0);
}

int userForkLoader(int seg, int offset) {
	return loadUserFile("UOS     COM", seg, offset, current_dir.cluster0);
}

int userGameLoader(int seg, int offset){
	return loadUserFile("SNK     COM", seg, offset, current_dir.cluster0);
}

int userSemaLoader(int number, int seg, int offset) {
	if(number == 1)return loadUserFile("SOS1    COM", seg, offset, current_dir.cluster0);
	else if(number == 2)return loadUserFile("SOS2    COM", seg, offset, current_dir.cluster0);
	else if(number == 3)return loadUserFile("SOS3    COM", seg, offset, current_dir.cluster0);
}
/*================================USER LOADER===================================*/