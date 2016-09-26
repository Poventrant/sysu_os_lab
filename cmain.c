#include "cextrn.h"
#include "cuser.h"
#include "cios.h"
#include "process.h"
typedef struct type_dictionary{
	int cluster0;
	char name[32];
}type_dictionary;

type_dictionary current_dir;
#include "cfunc.h"
#include "fileop.h"

char instr[100],realch[100];
int i, j, lent,pro;
char instr[100],tempch[100];

void cmain(){
	int ilen;
	info(1);
	strcpy("root", current_dir.name);
	while(1){
		printChar('\r'); print(current_dir.name); printChar('>');
	    getline(instr,32);
		ilen = strlen(instr);
		for(i = 0; i < ilen; ++i) {
			realch[i] = instr[i];												/*没有转成小写的原始字符*/
		}
		realch[ilen] = '\0';
		uppertolower(instr);
		i=0;
	    if(strfind(instr,"time") != -1) {										/* 查找instr中是否有time这个子字符串*/
			i = strfind(instr,"time"); 											/*获得time在instr中的索引位置*/
			if(checkspace(instr,0,i) && checkspace(instr,i+4,ilen)) time();		/*time前后都是空格*/
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"clr") != -1) {
			i = strfind(instr,"clr");
			if(checkspace(instr,0,i) && checkspace(instr,i+3,ilen)) info(1);
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"info") != -1){
			i = strfind(instr,"info");
			if(checkspace(instr,0,i) && checkspace(instr,i+4,ilen)) info(2);
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"hlt") != -1) {
			i = strfind(instr,"hlt");
			if(checkspace(instr,0,i) && checkspace(instr,i+3,ilen)) return;
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"int") != -1){
			i = strfind(instr,"int");
			if(checkspace(instr,0,i) && checkspace(instr,i+3,ilen)) {
				intCall();	
				info(1);															/*恢复菜单*/
			}
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"asc") != -1) {
		    i = strfind(instr,"asc");
			if(checkspace(instr,0,i) && checkspace(instr,i+3,i+4)){					/*检查ASC前面是否全是空格以及asc后一位是否是空格*/
				i += 4;
				for(; ;++i){
					if(realch[i] == '\0') break;
					else if(realch[i] != ' ') asc(realch[i]);							/*将asc+空格 之后的全部非空格字符打印出ASCII*/
				}
			}else print("wrong synax!\n");
	    }
		else if(strfind(instr,"exe") != -1){
			i = strfind(instr,"exe");
			if(checkspace(instr,0,i)){
				if(!isLoadPro(i+3,instr,tempch,'3')) {
					tempch[0] = '\0';
					continue;
				}
				lent = strlen(tempch);													/*获取EXE之后的全部1-3的字符储存到tempch中*/
				for(j = 0; j < lent; ++j){
					pro = tempch[j] - '0';							
					userProgramLoader(pro, KERNAL_SEG, USER_PRO_OFF);
					exe();
					info(1); 
				}
				tempch[0] = '\0';															/*init*/
			}else print("wrong synax!\n");
		}
		else if(strfind(instr,"21h") != -1){
			i = strfind(instr,"21h");
			if(checkspace(instr,0,i) && checkspace(instr,i+3,ilen)) {
				clr();
				cint21h();
				info(1);
			}
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"run") != -1){
			i = strfind(instr,"run");
			if(checkspace(instr,0,i)){
				if(!isLoadPro(i+3,instr,tempch,'4')) {
					tempch[0] = '\0';
					continue;
				}
				lent = strlen(tempch);													/*获取EXE之后的全部1-3的字符储存到tempch中*/
				for(j = 0; j < lent; ++j){
					if(tempch[j] >= '1' && tempch[j] <= '4'){
						pro = tempch[j] - '0';
						if(!userProcessLoader(pro, createNewPCB(), USER_PRS_OFF)) break;
					}
				}
				if(j == lent){
					user_PCBStart(700);			/*初始化回来到操作系统内核的寄存器数据*/
				}
				PCB_init();
				info(1);
				tempch[0] = '\0';
			}else print("wrong synax!\n");
		}
		else if(strfind(instr,"fork") != -1){
			i = strfind(instr,"fork");
			if(checkspace(instr,0,i) && checkspace(instr,i+4,ilen)) {
				if(userForkLoader(createNewPCB(), USER_PRS_OFF)) {
					user_PCBStart(700);
				}
				PCB_init();
				info(1);
			}
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"semaphore") != -1){
			i = strfind(instr,"semaphore");
			if(checkspace(instr,0,i)){
				if(!isLoadPro(i+9,instr,tempch,'3')) {
					tempch[0] = '\0';
					continue;
				}
				lent = strlen(tempch);													/*获取EXE之后的全部1-3的字符储存到tempch中*/
				if(lent > 1) {
					print ("Only one choice. \n");
					tempch[0] = '\0';
					continue;
				}
				pro = tempch[0] - '0';
				userProcessLoader(4, createNewPCB(), USER_PRS_OFF);
				if(userSemaLoader(pro, createNewPCB(), USER_PRS_OFF)){
					initSema();
					user_PCBStart(700);
				}
				PCB_init();
				info(1);
				tempch[0] = '\0';
			}else print("wrong synax!\n");
		}
		else if(strfind(instr,"list") != -1) {										
			i = strfind(instr,"list"); 										
			if(checkspace(instr,0,i) && checkspace(instr,i+4,ilen)) listFileInfo(current_dir.cluster0);	
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"cd") != -1) {										
			i = strfind(instr,"cd"); 										
			if(checkspace(instr,0,i) && checkspace(instr,i+2,i+3)) change_dictionary(instr, i+3);	
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"del") != -1) {										
			i = strfind(instr,"del"); 										
			if(checkspace(instr,0,i) && checkspace(instr,i+3,i+4)) deleteFileinc(instr, i+4);	
			else print("wrong synax!\n");
		}
		else if(strfind(instr,"game") != -1){
			i = strfind(instr,"game");
			if(checkspace(instr,0,i) &&checkspace(instr,i+4,ilen)){					
				userGameLoader(createNewPCB(), USER_PRS_OFF);
				user_PCBStart(-2);/*-2表示进程没时间寿命，但是不利用中断里面的ESC判定，而是用户程序自身的系统调用退出进程*/
				info(1); 
			}else print("wrong synax!\n");
		}
		else if(strfind(instr,"open") != -1) {										
			i = strfind(instr,"open"); 										
			if(checkspace(instr,0,i) && checkspace(instr,i+4,i+5)) openfile(instr, i+5);	
			else print("wrong synax!\n");
		}
	    else{
			print("Error: invalid cmd of \"");
		    print(instr);
			print("\" \n\n");
	    }
	}
}