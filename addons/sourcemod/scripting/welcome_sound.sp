#pragma semicolon 1
#pragma newdecls required

#include <sdktools_stringtables>
#include <sdktools_sound>
	
ArrayList
	hSoundList;
	
public Plugin myinfo =
{
	name		= "[Any] Welcome Sound/Музыка при входе",
	author		= "Nek.'a 2x2 | ggwp.site ",
	description	= "Музыка при входе",
	version		= "1.0",
	url			= "https://ggwp.site/"
};
	
public void OnPluginStart() 
{
	//hSoundList = CreateArray();
	hSoundList = new ArrayList(ByteCountToCells(128));
	HookEvent("player_activate", Event_Activate, EventHookMode_Pre);
}

public void OnMapStart()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/welcome_sound.ini");
	
	Handle hFile = OpenFile(sPath, "r");
	
	if(hFile == INVALID_HANDLE)
		ThrowError("Файл [%s] не существует !", sPath);
	
	ClearArray(hSoundList);		//Очищаем список
		
	while(!IsEndOfFile(hFile))		//Был ли достигнут конец файла
	{
		if (!ReadFileLine(hFile, sPath, sizeof(sPath)))		//Считываем сроки
			continue;
	
		int iComments = StrContains((sPath), "//");
		if (iComments != -1)
		{
			sPath[iComments] = '\0';
		}
	
		iComments = StrContains((sPath), "#");
		if (iComments != -1)
		{
			sPath[iComments] = '\0';
		}
			
		iComments = StrContains((sPath), ";");
		if (iComments != -1)
		{
			sPath[iComments] = '\0';
		}
	
		TrimString(sPath);		//Удаляем пробелы
		
		if (sPath[0] == '\0')
		{
			continue;
		}
		
		if(sPath[0])
		{
			char sBuffer[512];
			Format(sBuffer, sizeof(sBuffer), "sound/%s", sPath);
			AddFileToDownloadsTable(sBuffer);
			PrecacheSound(sPath, true);
			PushArrayString(hSoundList, sPath);
		}
	}
}

public Action Event_Activate(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsFakeClient(client))
		return;
		
	char sSound[128];
	GetArrayString(hSoundList, GetRandomInt(0, GetArraySize(hSoundList) - 1), sSound, sizeof(sSound));
	EmitSoundToClient(client, sSound);
	//PrintToChatAll("Игроку [%N] проигрывается трек [%s]", client, sSound);
}