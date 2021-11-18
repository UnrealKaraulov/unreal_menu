#include <amxmodx>
#include <amxmisc>

const MAX_CMDS = 40;
const MAX_MENU_ITEMS = 64;
const MAX_MENUITEM_LEN = 512;
new g_sMenus[MAX_CMDS][2][MAX_MENU_ITEMS][MAX_MENUITEM_LEN];
new g_sMenuNames[MAX_CMDS][MAX_MENUITEM_LEN];
new g_sMenuItemCount[MAX_CMDS] = {0,...};
 
public plugin_init()
{
	register_plugin("Unreal Menu", "1.3", "karaulov");
	new tmpConfigDir[128];
	new tmpMenuDir[128];
	get_configsdir(tmpConfigDir, charsmax(tmpConfigDir));
	formatex(tmpMenuDir,charsmax(tmpMenuDir),"%s/unrealmenu",tmpConfigDir);
	
	new tmpFileName[64];
	new tmpFullFileName[128];
	new tmpDirHandle = open_dir(tmpMenuDir, tmpFileName, charsmax(tmpFileName));
	new tmpCmdID = 0;
	new tmpCmdName[64];

	do
    {
		if(containi(tmpFileName, ".txt") == -1)
		{
			continue;
		}
		tmpFileName[strlen(tmpFileName) - 4] = '^0';
		formatex(tmpCmdName,charsmax(tmpCmdName),"cmd%i",tmpCmdID + 1);
		register_clcmd(tmpFileName,tmpCmdName);
		formatex(tmpFullFileName,charsmax(tmpFullFileName),"%s/unrealmenu/%s.txt",tmpConfigDir,tmpFileName);
		
		new szParse[MAX_MENUITEM_LEN + MAX_MENUITEM_LEN];
		new iLine = 0, iNum;
		
		read_file(tmpFullFileName, iLine, g_sMenuNames[tmpCmdID], charsmax( g_sMenuNames[] ), iNum);
		
		for(iLine = 1; read_file(tmpFullFileName, iLine, szParse, charsmax( szParse ), iNum); iLine++)
		{
			split2(szParse,g_sMenus[tmpCmdID][0][g_sMenuItemCount[tmpCmdID]],charsmax(g_sMenus[][][]),g_sMenus[tmpCmdID][1][g_sMenuItemCount[tmpCmdID]],charsmax(g_sMenus[][][]),"=");
			g_sMenuItemCount[tmpCmdID]++;
		}
		
		tmpCmdID++;
		if (tmpCmdID == 32)
			break;
    }   
    while(next_file(tmpDirHandle, tmpFileName, charsmax(tmpFileName)));
}

new LAST_CALLED_CMD[MAX_PLAYERS + 1] = {0, ...};

public CALL_CMD(id,cmdid)
{
	LAST_CALLED_CMD[id] = cmdid - 1;
	new tmpmenuitem[MAX_MENUITEM_LEN];
	new tmpmenuid[32];
	
	format(tmpmenuitem,charsmax(tmpmenuitem),"[Menu]: %s", g_sMenuNames[cmdid - 1]);
		
	new vmenu = menu_create(tmpmenuitem, "CALL_MENU")

	for(new i = 0; i < g_sMenuItemCount[cmdid - 1 ];i++)
	{
		num_to_str(i,tmpmenuid,charsmax(tmpmenuid));
		menu_additem(vmenu, g_sMenus[cmdid - 1][0][i],tmpmenuid);
	}

	
	menu_setprop(vmenu, MPROP_NEXTNAME, "\yДAЛEE");
	menu_setprop(vmenu, MPROP_BACKNAME, "\yHA3AД");
	menu_setprop(vmenu, MPROP_EXITNAME, "\rBЫXOД");
	menu_setprop(vmenu, MPROP_EXIT,MEXIT_ALL);
	
	menu_display(id,vmenu,0);
	return PLUGIN_HANDLED;
}

public EXECUTE_COMMAND(id, const cmd[])
{
	if (containi(cmd,"EXECUTE_WITH_ID:") == 0)
	{
		new tmpLeftPart[MAX_MENUITEM_LEN];
		new tmpRigtPart[MAX_MENUITEM_LEN];
		split2(cmd,tmpLeftPart,charsmax(tmpLeftPart),tmpRigtPart,charsmax(tmpRigtPart),":");
		
		new num_of_plugins = get_pluginsnum()
		for (new i = 0; i < num_of_plugins; ++i)
		{
			new tmpFuncID = get_func_id(tmpRigtPart,i);
			if ( tmpFuncID >= 0 )
			{
				callfunc_begin_i(tmpFuncID,i);
				callfunc_push_int(id);
				callfunc_end();
			}
		}
	}
	else if (containi(cmd,"EXECUTE_WITH_ARGS:") == 0)
	{
		new tmpFuncName[64];
		new tmpArgType[32];
		new tmpArgValue[MAX_MENUITEM_LEN];
		new tmpLeftPart[MAX_MENUITEM_LEN];
		new tmpRigtPart[MAX_MENUITEM_LEN];
		split2(cmd,tmpLeftPart,charsmax(tmpLeftPart),tmpRigtPart,charsmax(tmpRigtPart),":");
		split2(tmpRigtPart,tmpFuncName,charsmax(tmpFuncName),tmpLeftPart,charsmax(tmpLeftPart),":"); 
		new num_of_plugins = get_pluginsnum()
		for (new i = 0; i < num_of_plugins; ++i)
		{
			new tmpFuncID = get_func_id(tmpFuncName,i);
			if ( tmpFuncID >= 0 )
			{
				callfunc_begin_i(tmpFuncID, i);
				while(containi(tmpLeftPart,":") != -1)
				{	
					split2(tmpLeftPart,tmpArgType,charsmax(tmpArgType),tmpLeftPart,charsmax(tmpLeftPart),":");
					if ( containi(tmpLeftPart,":") == -1 )
					{
						copy(tmpArgValue,charsmax(tmpArgValue),tmpLeftPart);
					}
					else 
					{
						split2(tmpLeftPart,tmpArgValue,charsmax(tmpArgValue),tmpLeftPart,charsmax(tmpLeftPart),":");
					}
					if (equal(tmpArgType,"INTEGER"))
					{
						new tmpvar = 0;
						if (equal(tmpArgValue,"CALLERID"))
						{
							tmpvar = id;
						}
						else 
						{
							tmpvar = str_to_num(tmpArgValue);
						}
						
						callfunc_push_int(tmpvar);
					}
					else if (equal(tmpArgType,"STRING"))
					{
						callfunc_push_str(tmpArgValue);
					}
					else 
					{
						new Float:tmpvar = str_to_float(tmpArgValue);
						callfunc_push_float(tmpvar);
					}
				}
				callfunc_end();
			}
		}
	}
	else 
	{
		client_cmd(id,"%s",cmd);
	}
}

public TEST_CALL_MENU(id)
{
	client_cmd(id,"say test call menu %i",id);
}

public TEST_CALL_MENU2(int,str[],Float:flt,id)
{
	client_cmd(0,"say test call menu %i %s %f %i",int, str, flt, id);
}

public CALL_MENU(id, vmenu, item)
{
	if(item == MENU_EXIT || !is_user_connected(id) || !is_user_alive(id)) 
	{
		menu_destroy(vmenu);
		return PLUGIN_HANDLED;
	}
	new data[64], iName[128], access, callback
	menu_item_getinfo(vmenu, item, access, data, charsmax(data), iName, charsmax(iName), callback)
	     
	new cmdid = str_to_num(data)
	EXECUTE_COMMAND(id, g_sMenus[LAST_CALLED_CMD[id]][1][cmdid]);
	
	menu_destroy(vmenu);
	return PLUGIN_HANDLED;
}

public cmd1(id)
{
	return CALL_CMD(id,1);
}

public cmd2(id)
{
	return CALL_CMD(id,2);
}

public cmd3(id)
{
	return CALL_CMD(id,4);
}

public cmd4(id)
{
	return CALL_CMD(id,4);
}

public cmd5(id)
{
	return CALL_CMD(id,5);
}

public cmd6(id)
{
	return CALL_CMD(id,6);
}

public cmd7(id)
{
	return CALL_CMD(id,7);
}

public cmd8(id)
{
	return CALL_CMD(id,8);
}

public cmd9(id)
{
	return CALL_CMD(id,9);
}

public cmd10(id)
{
	return CALL_CMD(id,10);
}

public cmd11(id)
{
	return CALL_CMD(id,11);
}

public cmd12(id)
{
	return CALL_CMD(id,12);
}

public cmd13(id)
{
	return CALL_CMD(id,13);
}

public cmd14(id)
{
	return CALL_CMD(id,14);
}

public cmd15(id)
{
	return CALL_CMD(id,15);
}

public cmd16(id)
{
	return CALL_CMD(id,16);
}

public cmd17(id)
{
	return CALL_CMD(id,17);
}

public cmd18(id)
{
	return CALL_CMD(id,18);
}

public cmd19(id)
{
	return CALL_CMD(id,19);
}

public cmd20(id)
{
	return CALL_CMD(id,20);
}

public cmd21(id)
{
	return CALL_CMD(id,21);
}

public cmd22(id)
{
	return CALL_CMD(id,22);
}

public cmd23(id)
{
	return CALL_CMD(id,23);
}

public cmd24(id)
{
	return CALL_CMD(id,24);
}

public cmd25(id)
{
	return CALL_CMD(id,25);
}

public cmd26(id)
{
	return CALL_CMD(id,26);
}

public cmd27(id)
{
	return CALL_CMD(id,27);
}

public cmd28(id)
{
	return CALL_CMD(id,28);
}

public cmd29(id)
{
	return CALL_CMD(id,29);
}

public cmd30(id)
{
	return CALL_CMD(id,30);
}

public cmd31(id)
{
	return CALL_CMD(id,31);
}

public cmd32(id)
{
	return CALL_CMD(id,32);
}

public cmd33(id)
{
	return CALL_CMD(id,33);
}

public cmd34(id)
{
	return CALL_CMD(id,34);
}

public cmd35(id)
{
	return CALL_CMD(id,35);
}

public cmd36(id)
{
	return CALL_CMD(id,36);
}

public cmd37(id)
{
	return CALL_CMD(id,37);
}

public cmd38(id)
{
	return CALL_CMD(id,38);
}

public cmd39(id)
{
	return CALL_CMD(id,39);
}

public cmd40(id)
{
	return CALL_CMD(id,40);
}

stock split2(const szInput[], szLeft[], sL_Max, szRight[], sR_Max, const szDelim[])
{
	new i = containi(szInput,szDelim);
	if (i <= 0)
	{
		szLeft[0] = '^0';
		szRight[0] = '^0';
		return 0;
	}
	copy(szLeft,sL_Max,szInput);
	szLeft[i] = '^0';
	copy(szRight,sR_Max,szInput[i + 1]);
	return 1;
}