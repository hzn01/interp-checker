#include <sourcemod>

float g_fMinUpdateRate;
float g_fMaxUpdateRate;
float g_fMinInterpRatio;
float g_fMaxInterpRatio;

public Plugin myinfo =
{
	name = "Interp Checker",
	author = "hzn",
	description = "checks interp of every client",
	version = "1.1.0",
	url = "automix.me"
};

public void OnPluginStart()
{
	HookEvent("player_team", Event_Player_Team, EventHookMode_PostNoCopy);

	Handle hMinUpdateRate = FindConVar("sv_minupdaterate");
	Handle hMaxUpdateRate = FindConVar("sv_maxupdaterate");
	Handle hMinInterpRatio = FindConVar("sv_client_min_interp_ratio");
	Handle hMaxInterpRatio = FindConVar("sv_client_max_interp_ratio");
	
	if(hMinUpdateRate != null)
	{
		g_fMinUpdateRate = GetConVarFloat(hMinUpdateRate);
		HookConVarChange(hMinUpdateRate, OnMinUpdateRate);
	}
	
	if(hMaxUpdateRate != null)
	{
		g_fMaxUpdateRate = GetConVarFloat(hMaxUpdateRate);
		HookConVarChange(hMaxUpdateRate, OnMaxUpdateRate);
	}

	if(hMinInterpRatio != null)
	{
		g_fMinInterpRatio = GetConVarFloat(hMinInterpRatio);
		HookConVarChange(hMinInterpRatio, OnMinInterpRatio);
	}
	
	if(hMaxInterpRatio != null)
	{
		g_fMaxInterpRatio = GetConVarFloat(hMaxInterpRatio);
		HookConVarChange(hMaxInterpRatio, OnMaxInterpRatio);
	}
}

public void OnMinUpdateRate(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_fMinUpdateRate = GetConVarFloat(convar);
}

public void OnMaxUpdateRate(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_fMaxUpdateRate = GetConVarFloat(convar);
}

public void OnMinInterpRatio(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_fMinInterpRatio = GetConVarFloat(convar);
}

public void OnMaxInterpRatio(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_fMaxInterpRatio = GetConVarFloat(convar);
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
	if(!IsClientInGame(client) || IsClientSourceTV(client))
		return Plugin_Stop;

	if(IsPlayerAlive(client))
	{
		char sInterp[9];
		char sInterpRatio[9];
		char sUpdateRate[16];
		char sMessage[128];
		
		GetClientInfo(client, "cl_interp", sInterp, sizeof(sInterp));
		GetClientInfo(client, "cl_interp_ratio", sInterpRatio, sizeof(sInterpRatio));
		GetClientInfo(client, "cl_updaterate", sUpdateRate, sizeof(sUpdateRate));
		
		float fInterp = StringToFloat(sInterp);
		float fInterpRatio = StringToFloat(sInterpRatio);
		float fUpdateRate = StringToFloat(sUpdateRate);
		
		if(fInterpRatio < g_fMinInterpRatio)
			fInterpRatio = g_fMinInterpRatio;
			
		if(fInterpRatio > g_fMaxInterpRatio)
			fInterpRatio = g_fMaxInterpRatio;
			
		if(fUpdateRate < g_fMinUpdateRate)
			fUpdateRate = g_fMinUpdateRate;
			
		if(fUpdateRate > g_fMaxUpdateRate)
			fUpdateRate = g_fMaxUpdateRate;
			
		float fLerp = fInterp + 0.00001;
		float minLerp = fInterpRatio / fUpdateRate + 0.00001;
		if(minLerp > fLerp)
			fLerp = minLerp;
		
		if(fLerp <= g_fMaxInterpRatio / 100.0 + 0.00001)
		{
			Format(sMessage, sizeof(sMessage), "You have good interp/lerp: %.4f", fLerp);
			PrintToConsole(client, "[INTERP CHECKER] You have good interp/lerp: %.4f", fLerp);
		}
		else
		{
			Format(sMessage, sizeof(sMessage), "WARNING!\nYour interp/lerp is high: %.4f\nSet cl_interp to 0 and rejoin.", fLerp);
			PrintToConsole(client, "[INTERP CHECKER] Your interp/lerp is high: %.4f\n[INTERP CHECKER] Set cl_interp to 0 and rejoin.", fLerp);
		}
		
		Handle hKeyHintText = StartMessageOne("KeyHintText", client);
		BfWriteByte(hKeyHintText, 1);
		BfWriteString(hKeyHintText, sMessage);
		EndMessage();
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
