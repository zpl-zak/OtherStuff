//=============================================================================
//								FORWARDED GLOBAL VARIABLES
//=============================================================================
local mainGamemode = null;

//=============================================================================
//								CLASSES
//=============================================================================
class Gamemode
{
	gamemodeName 					= null;
	gamemodeVersion 				= null;
	gamemodeAuthor 					= null;
	gamemodeType					= null;
	gamemodeWWW 				    = null;
	gamemodePassword 				= null;
	gamemodeAdminPassword 			= null;
	gamemodeMaxPlayers				= null;
	gamemodeCurrentPlayers			= null;
	gamemodePlayers					= null;
	
	constructor(Name, Version, Author, Type, WWW, Password, AdminPassword, MaxPlayers)
	{
		gamemodeName = Name;
		gamemodeVersion = Version;
		gamemodeAuthor = Author;
		gamemodeType = Type;
		gamemodeWWW = WWW;
		gamemodePassword = Password;
		gamemodeAdminPassword = AdminPassword;
		gamemodeMaxPlayers = MaxPlayers;
		gamemodeCurrentPlayers = 0;
		gamemodePlayers = [];
	}
	
	function gamemodeLog(message)
	{
		print("[" + gamemodeName + "] " + message);
	}
}

class Scoreboard
{	
}

class Votemap
{
}

class Player
{
	playerName 		= null;
	playerPassword  = null;
	playerID 		= null;
	playerPoints   	= null;
	playerWeapons 	= null;
	playerSkin      = null;
	playerIP 		= null;
	playerAdmin 	= null;
	
	function GetPlayerByID(GM, ID)
	{
		return GM.gamemodePlayers[ID];
	}
	
	function RemovePlayerByID(GM, ID)
	{
		GM.gamemodePlayers.remove(ID);
	}
	
	function GetFilePath()
	{
		return "players/" +  playerName +".ini";
	}
	constructor(GM, Name, Password, ID, Points, Weapons, Skin, IP, Admin)
	{
		playerName = Name;
		playerPassword = Password;
		playerID = ID;
		playerPoints = Points;
		playerWeapons = Weapons;
		playerSkin = Skin;
		playerIP = IP;
		playerAdmin = Admin;
		
		GM.gamemodePlayers.push(this)
	}
}

class Weapon
{
	weaponID 		= null;
	weaponCurrAmmo  = null;
	weaponMaxAmmo   = null;
	weaponName      = null;
} 

//=============================================================================
//								GAME COMMANDS
//=============================================================================
function registerFunc(id, params)
{
	local data = split(params, " ");
	
	if(data.len() == 2)
		if(iniFileExists(Player.GetPlayerByID(mainGamemode, id).GetFilePath()))
		{
			sendPlayerMessage(id, "[ACCOUNT] You are already registered! Use /login <password> to proceed.");
		}
		else if (data[0] == data[1])
		{
			iniSetParam(Player.GetPlayerByID(mainGamemode, id).GetFilePath(), "Name", playerGetName(id));
			iniSetParam(Player.GetPlayerByID(mainGamemode, id).GetFilePath(), "Password", data[1]);
			iniSetParam(Player.GetPlayerByID(mainGamemode, id).GetFilePath(), "Points", "0");
			iniSetParam(Player.GetPlayerByID(mainGamemode, id).GetFilePath(), "IP", playerGetIP(id));
			iniSetParam(Player.GetPlayerByID(mainGamemode, id).GetFilePath(), "Skin", playerGetSkinID(id).tostring());
			iniSetParam(Player.GetPlayerByID(mainGamemode, id).GetFilePath(), "Admin", "0");
			
			sendPlayerMessage(id, "[ACCOUNT] Registration was successful!");
		}
		else
		{
			sendPlayerMessage(id, "[ACCOUNT] Password mismatch!");
		}
	else
	{
		sendPlayerMessage(id, "[ACCOUNT] Invalid parameters! /register <password> <repeat pass>");
	}
}

function loginFunc(id, params)
{
	local data = split(params, " ");
	
	if(data.len() == 1)
		if(!iniFileExists(Player.GetPlayerByID(mainGamemode, id).GetFilePath()))
		{
			sendPlayerMessage(id, "[ACCOUNT] You are not registered! You should register.");
		}
		else if(data[0] == iniGetParam(Player.GetPlayerByID(mainGamemode, id).GetFilePath(), "Password", "↕").tostring())
		{
			local player = Player.GetPlayerByID(mainGamemode, id);
			player.playerName = iniGetParam(player.GetFilePath(), "Name", playerGetName(id));
			player.playerPoints = iniGetParam(player.GetFilePath(), "Points", "0").tointeger();
			player.playerIP = iniGetParam(player.GetFilePath(), "IP", playerGetIP(id));
			player.playerSkin = iniGetParam(player.GetFilePath(), "Skin", playerGetSkinID(id).tostring()).tointeger();
			player.playerAdmin = iniGetParam(player.GetFilePath(), "Admin", "0").tointeger();
			
			sendPlayerMessage(id, "[ACCOUNT] You are successfuly logged in!");
		}
		else
		{
			sendPlayerMessage(id, "[ACCOUNT] Password mismatch!");
		}
	else
	{
		sendPlayerMessage(id, "[ACCOUNT] Invalid parameters! /login <password>");
	}
}

//=============================================================================
//								GLOBAL VARIABLES
//=============================================================================

local mainGamemodeConfigFile = "gamemode_config.ini";
local consoleCommands = [];

//=============================================================================
//								EVENTS
//=============================================================================

function onServerInit()
{
	
	if(!iniFileExists(mainGamemodeConfigFile))
	{
		print("[GAMEMODE] creating default config file !");
		gamemodeGenerateDefaultFile();
	} 
	
	mainGamemode = Gamemode(
		iniGetParam(mainGamemodeConfigFile, "Name", "Default Server"),
		iniGetParam(mainGamemodeConfigFile, "Version", "1.0"),
		iniGetParam(mainGamemodeConfigFile, "Author", "Author"),
		iniGetParam(mainGamemodeConfigFile, "Type", "Default"),
		iniGetParam(mainGamemodeConfigFile, "WWW", "www.lh-mp.eu"),
		iniGetParam(mainGamemodeConfigFile, "Password", "-"),
		iniGetParam(mainGamemodeConfigFile, "AdminPassword", "guwno"),
		serverGetMaxPlayers()
	);
	
	print("\n\n\n\n");
	print("+=========================================+");
	print("\tGamemode: " 	+ mainGamemode.gamemodeName);
	print("\tCreated by: " 	+ mainGamemode.gamemodeAuthor);
	print("\tVersion: " 	+ mainGamemode.gamemodeVersion);
	print("\tWebsite: " 	+ mainGamemode.gamemodeWWW);
	print("\tType: " 		+ mainGamemode.gamemodeType);
	print("+=========================================+");
	
	registerConsoleCommand("register", registerFunc);
	registerConsoleCommand("login", loginFunc);
}	

function onPlayerConnect(ID)
{
	local newPlayer = Player(mainGamemode, playerGetName(ID), "", ID, 0, null, 0, playerGetIP(ID), "0");
	print("[SERVER] Player[" + ID + "] " + Player.GetPlayerByID(mainGamemode, ID).playerName + " has been connected to the server!");
}

function onPlayerSpawn(ID)
{
	
}

function onPlayerDisconnect(ID)
{
	print("[SERVER] Player[" + ID + "] " + Player.GetPlayerByID(mainGamemode, ID).playerName + " has been connected to the server!");
	Player.RemovePlayerByID(GM, ID);
}

function onPlayerText(ID, message)
{
	
}

function onPlayerThrowGranade(ID, wepID)
{
	
}

function onPlayerShoot(ID, wepID)
{

}

function onPlayerIsKilled(ID, killerID)
{
	
}

function onPlayerCommand(ID, message, params)
{
	local callable = getConsoleCommand(message);
	
	if(callable != null)
		callable(ID, params);
}

function onServerTickSecond(ticks)
{

}

//=============================================================================
//								HELPER FUNCTIONS
//=============================================================================

function gamemodeGenerateDefaultFile()
{
	iniSetParam(mainGamemodeConfigFile, "Name", "Default Server");
	iniSetParam(mainGamemodeConfigFile, "Version", "1.0");
	iniSetParam(mainGamemodeConfigFile, "Author", "Author");
	iniSetParam(mainGamemodeConfigFile, "Type", "Default");
	iniSetParam(mainGamemodeConfigFile, "WWW", "www.lh-mp.eu");
	iniSetParam(mainGamemodeConfigFile, "Password", "-");
	iniSetParam(mainGamemodeConfigFile, "AdminPassword", "guwno");
}

function getConsoleCommand(command)
{
	for(local i = 0; i < consoleCommands.len(); i++)
	{
		if(command == consoleCommands[i][0])
		{
			return consoleCommands[i][1];
		}
	}
	return null;
}

function registerConsoleCommand(name, func)
{
	local newfunction = [name, func];
	consoleCommands.push(newfunction);
}