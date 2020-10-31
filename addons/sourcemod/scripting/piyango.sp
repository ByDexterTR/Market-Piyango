#include <sourcemod>
#include <emitsoundany>
#include <store>
#pragma semicolon 1
#pragma newdecls required
public Plugin myinfo = 
{
	name = "[Market] Piyango", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
	
};
ConVar giris_ucreti = null, dusuk_kazanc = null, yuksek_kazanc = null, delay_command = null;
int Delay[MAXPLAYERS + 1] = 0;
bool KomutKAPATMA[MAXPLAYERS + 1] = false;
Handle delaytimer[MAXPLAYERS + 1] = null;
public void OnPluginStart()
{
	RegConsoleCmd("sm_piyango", Command_Piyango, "Piyango oyunu komudu");
	giris_ucreti = CreateConVar("sm_piyango_giris", "500", "Piyangoya giriş ücreti", FCVAR_NOTIFY, true, 0.0, false);
	dusuk_kazanc = CreateConVar("sm_piyango_dusuk", "250", "En az kazanılacak kredi/para", FCVAR_NOTIFY, true, 0.0, false);
	yuksek_kazanc = CreateConVar("sm_piyango_yuksek", "750", "En yuksek kazanılacak kredi/para", FCVAR_NOTIFY, true, 1.0, false);
	delay_command = CreateConVar("sm_piyango_delay", "10", "Kaç saniye arayla oynansın!", FCVAR_NOTIFY, true, 0.0);
	AutoExecConfig(true, "Piyango", "ByDexter");
}
public void OnMapStart()
{
	PrecacheSoundAny("ByDexter/piyango/lose.mp3");
	AddFileToDownloadsTable("sound/ByDexter/piyango/lose.mp3");
	PrecacheSoundAny("ByDexter/piyango/win.mp3");
	AddFileToDownloadsTable("sound/ByDexter/piyango/win.mp3");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (Delay[i] > 0)
			Delay[i] = 0;
		if (delaytimer[i] != null)
		{
			delete delaytimer[i];
			delaytimer[i] = null;
			KomutKAPATMA[i] = false;
		}
	}
}
public void OnClientDisconnect(int client)
{
	if (Delay[client] > 0)
		Delay[client] = 0;
	if (delaytimer[client] != null)
	{
		delete delaytimer[client];
		delaytimer[client] = null;
		KomutKAPATMA[client] = false;
	}
}
public Action Command_Piyango(int client, int args)
{
	if (args > 0)
	{
		ReplyToCommand(client, "[SM] \x01Kullanım: sm_piyango");
		return Plugin_Handled;
	}
	else
	{
		if (!KomutKAPATMA[client])
		{
			if (Store_GetClientCredits(client) >= giris_ucreti.IntValue)
			{
				KomutKAPATMA[client] = true;
				if (delaytimer[client] != null)
					delete delaytimer[client];
				delaytimer[client] = CreateTimer(delay_command.FloatValue, Engelikaldir, client, TIMER_FLAG_NO_MAPCHANGE);
				Store_SetClientCredits(client, Store_GetClientCredits(client) - giris_ucreti.IntValue);
				CreateTimer(0.1, Piyangosonuc, client, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
				return Plugin_Handled;
			}
			else
			{
				ReplyToCommand(client, "[SM] \x01Piyango giriş ücreti \x04%d kredi \x01sende o kadar yok -_-", giris_ucreti.IntValue);
				return Plugin_Handled;
			}
		}
		else
		{
			ReplyToCommand(client, "[SM] \x01Piyangoya girmek için biraz daha beklemelisin!");
			return Plugin_Handled;
		}
	}
}
public Action Engelikaldir(Handle timer, int client)
{
	PrintToChat(client, "[SM] \x01Tekrar piyango oynayabilirsin!");
	KomutKAPATMA[client] = false;
	delaytimer[client] = null;
	return Plugin_Stop;
}
public Action Piyangosonuc(Handle timer, int client)
{
	Delay[client]++;
	PrintHintText(client, "--> Piyango: %d <--", GetRandomInt(dusuk_kazanc.IntValue, yuksek_kazanc.IntValue));
	if (Delay[client] >= 25)
	{
		int Son = GetRandomInt(dusuk_kazanc.IntValue, yuksek_kazanc.IntValue);
		Delay[client] = 0;
		Store_SetClientCredits(client, Store_GetClientCredits(client) + Son);
		PrintHintText(client, "--> Piyango: %d Sayısını Çıkardın <--", Son);
		if (Son < giris_ucreti.IntValue)
		{
			EmitSoundToClientAny(client, "ByDexter/piyango/lose.mp3", SOUND_FROM_PLAYER, 1, 100);
			Give_Effect(client, { 255, 0, 0, 120 } );
			PrintToChat(client, "[SM] \x01Piyangodan \x07%d Kredi \x01zarara girdin!", giris_ucreti.IntValue - Son);
		}
		if (Son == giris_ucreti.IntValue)
		{
			EmitSoundToClientAny(client, "ByDexter/piyango/win.mp3", SOUND_FROM_PLAYER, 1, 100);
			Give_Effect(client, { 255, 255, 0, 120 } );
			PrintToChat(client, "[SM] \x01Piyangodan yatırdığın krediyi kurtardın sadece");
			
		}
		if (Son > giris_ucreti.IntValue)
		{
			EmitSoundToClientAny(client, "ByDexter/piyango/win.mp3", SOUND_FROM_PLAYER, 1, 100);
			Give_Effect(client, { 0, 255, 0, 120 } );
			PrintToChat(client, "[SM] \x01Piyangodan \x04%d Kredi \x01kâr-a geçtin!", Son - giris_ucreti.IntValue);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
void Give_Effect(int client, int Renk[4]) { int clients[1]; clients[0] = client; Handle message = StartMessageEx(GetUserMessageId("Fade"), clients, 1, 0); Protobuf pb = UserMessageToProtobuf(message); pb.SetInt("duration", 200); pb.SetInt("hold_time", 40); pb.SetInt("flags", 17); pb.SetColor("clr", Renk); EndMessage(); } 