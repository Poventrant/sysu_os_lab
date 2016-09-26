void intput2filename(char *filename, char *inp){
	int i, j;
	for(i =0; inp[i] != '\0' ; ++ i){
		if(inp[i] == '.') {
			break;
		}
		filename[i] = inp[i];
	}
	j = i + 1;
	for(;i < 8; ++ i){
		filename[i] = ' ';
	}
	for(;; ++ j, ++i){
		if(inp[j] == '\0') break;
		filename[i] = inp[j];
	}
	filename[i]= '\0';
}

void nextDir0(char tempname[]){
	int namelen, tempj;
	if(strcmp(tempname, "root") || strcmp(tempname, "ROOT")){
		strcpy("root",current_dir.name);
		current_dir.cluster0 = 0; /*根目录的条目设为0*/
	}
	else {
		toupper(tempname);
		namelen = strlen(tempname);
		strlink(tempname, "          ");
		tempname[11] = '\0';	/*补空格*/
		tempj = ChangeDictionry(tempname, current_dir.cluster0);
		tempname[namelen] = '\0';
		if(tempj == -1){
			print("There is no such a dictionary.\n\r");
		} 
		else{
			current_dir.cluster0 = tempj;
			tolower(tempname);
			strlink(current_dir.name,"\\");
			strlink(current_dir.name,tempname);
		}
	}
}

void nextDir(char p[]){
	int cdi, cdj = 0, addspace ;
	char tempname[32];
	for(cdi = 0; ; ++ cdi){
		if(p[cdi] == '\\'){
			tempname[cdj] = '\0';
			nextDir0(tempname);
			cdj = 0;
			tempname[cdj] = '\0';
			continue;
		}
		if(p[cdi] == '\0' && p[cdi-1] != '\\'){
			tempname[cdj] = '\0';
			nextDir0(tempname);
			cdj = 0;
			tempname[cdj] = '\0';
			break;
		}
		if(p[cdi] == '\0') {
			if(cdj == 0) break;
			tempname[cdj] = '\0';
			break;
		}
		tempname[cdj ++] = p[cdi];
	}
}

void change_dictionary(char instr0[],int index0){
	int cdi;
	char dirname[30];
	for(cdi = 0; ; ++ cdi){
		if(instr0[index0 + cdi] == '\0') break;
		dirname[cdi] = instr0[index0 + cdi];
	}
	dirname[cdi] = '\0';
	nextDir(dirname);
}

void deleteFileinc(char instr0[],int index0){
	int cdi, retmark;
	char dirname[30];
	for(cdi = 0; ; ++ cdi){
		if(instr0[index0 + cdi] == '\0') break;
		dirname[cdi] = instr0[index0 + cdi];
	}
	dirname[cdi] = '\0';
	toupper(dirname);
	retmark = deleteFile(dirname, current_dir.cluster0);
	if(retmark == -1) print("There is no such a dictionary.\n\r");
}

void openfile(char instr0[],int index0){
	int cdi, retmark;
	char dirname[30], loadname[12];
	for(cdi = 0; ; ++ cdi){
		if(instr0[index0 + cdi] == '\0') break;
		dirname[cdi] = instr0[index0 + cdi];
	}
	dirname[cdi] = '\0';
	toupper(dirname);
	intput2filename(loadname, dirname);
	retmark = loadUserFile(loadname, createNewPCB(), USER_PRS_OFF, current_dir.cluster0);
	if(retmark){
		user_PCBStart(-1);/*-1表示进程没有时间寿命，只有按下esc才推出*/
		PCB_init();
		info(1);
	}
	else if(retmark == -1) print("There is no such a dictionary.\n\r");
}

