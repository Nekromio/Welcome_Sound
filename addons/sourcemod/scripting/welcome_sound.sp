#pragma semicolon 1
#pragma newdecls required

#include <sdktools_stringtables>
#include <sdktools_sound>
	
ArrayList hSoundList;
	
public Plugin myinfo =
{
	name		= "[Any] Welcome Sound/Музыка при входе",
	author		= "Nek.'a 2x2 | ggwp.site ",
	description	= "Музыка при входе",
	version		= "1.0.1",
	url			= "https://ggwp.site/"
};
	
public void OnPluginStart() 
{
	hSoundList = new ArrayList(ByteCountToCells(512));
	HookEvent("player_activate", Event_Activate, EventHookMode_Pre);
}

public void OnMapStart()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/welcome_sound.ini");

	File hFile = OpenFile(sPath, "r");
	if (hFile == null)
	{
		ThrowError("Файл [%s] не существует!", sPath);
	}

	hSoundList.Clear();

	char line[512];
	while (!IsEndOfFile(hFile))
	{
		if (!ReadFileLine(hFile, line, sizeof(line)))
			continue;

		StripComments(line);
		TrimString(line);

		if (line[0] == '\0')
			continue;

		char sBuffer[512];
		Format(sBuffer, sizeof(sBuffer), "sound/%s", line);
		AddFileToDownloadsTable(sBuffer);
		PrecacheSound(line, true);
		hSoundList.PushString(line);
	}
	delete hFile;
}

void StripComments(char[] line)
{
    int pos;
    if ((pos = StrContains(line, "//")) != -1) line[pos] = '\0';
    if ((pos = StrContains(line, "#")) != -1) line[pos] = '\0';
    if ((pos = StrContains(line, ";")) != -1) line[pos] = '\0';
}

public void Event_Activate(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(!(0 < client <= MaxClients && IsClientInGame(client)) || IsFakeClient(client))
		return;
		
	if(!hSoundList.Length)
    	return;

	char sSound[512];
	hSoundList.GetString(GetRandomInt(0, hSoundList.Length - 1), sSound, sizeof(sSound));
	EmitSoundToClient(client, sSound);
}