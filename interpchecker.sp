#include <sourcemod>

public Plugin myinfo =
{
	name = "interp checker",
	author = "hzn",
	description = "checks interp of every client",
	version = "1.0.0",
	url = "automix.me"
};

public void OnPluginStart()
{
	HookEvent("player_team", Event_Player_Team, EventHookMode_PostNoCopy);
}

public Action Event_Player_Team(Event event, const char[] name, bool dontBroadcast)
{
	int team = event.GetInt("team");
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(team > 1)
	{
		CreateTimer(1.0, ShowInterp, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE)
	}
	
	return Plugin_Continue;
}

public Action ShowInterp(Handle timer, any client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;

	if(IsPlayerAlive(client))
	{
		char sInterp[9];
		char sMessage[128];
		
		GetClientInfo(client, "cl_interp", sInterp, sizeof(sInterp));
		float fInterp = StringToFloat(sInterp);
		
		if (fInterp <= 0.0152)
		{
			Format(sMessage, sizeof(sMessage), "You have good interp: %.5f", fInterp);
			PrintToConsole(client, "[INTERP CHECKER] You have good interp: %.5f", fInterp);
		}
		else
		{
			Format(sMessage, sizeof(sMessage), "WARNING!\nYour interp is high: %.5f\nSet cl_interp to 0 and rejoin.", fInterp);
			PrintToConsole(client, "[INTERP CHECKER] Your interp is high: %.5f\n[INTERP CHECKER] Set cl_interp to 0 and rejoin.", fInterp);
		}
		
		Handle hKeyHintText = StartMessageOne("KeyHintText", client);
		BfWriteByte(hKeyHintText, 1);
		BfWriteString(hKeyHintText, sMessage);
		EndMessage();
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}