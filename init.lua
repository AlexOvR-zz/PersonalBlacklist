local _, core = ...; -- Namespace
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local L = LibStub("AceLocale-3.0"):GetLocale("PBL")

local addon = LibStub("AceAddon-3.0"):NewAddon("PBL", "AceConsole-3.0")
local pblLDB = LibStub("LibDataBroker-1.1"):NewDataObject("PBL!", {
	type = "data source",
	text = "PBL!",
	icon = "Interface\\AddOns\\PersonalBlacklist\\media\\newIcon.blp",
	OnTooltipShow = function(tooltip)
          tooltip:SetText("Personal BlackList")
          tooltip:AddLine("(PBL)", 1, 1, 1)
          tooltip:Show()
     end,
	OnClick = function() PBL_MinimapButton_OnClick() end,
})
local icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("PBL_", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})
	icon:Register("PBL!", pblLDB, self.db.profile.minimap)
	self:RegisterChatCommand("PBL", "CommandThePBL")
end

function addon:CommandThePBL()
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	if self.db.profile.minimap.hide then
		icon:Hide("PBL!")
	else
		icon:Show("PBL!")
	end
end

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
	["show"] = core.Config.Toggle, -- this is a function (no knowledge of Config object)
	
	["help"] = function()
		print(" ");
		core:Print(L["commandsListChat"]..":")
		core:Print("|cff00cc66/pbl show|r - "..L["commandShowChat"]);
		core:Print("|cff00cc66/pbl help|r - shows help info");
		--core:Print("|cff00cc66/pbl ban|r - add a player to the ban list");
		--core:Print("|cff00cc66/pbl unban|r - removes a player from the ban list");
		core:Print("|cff00cc66/pbl banlist|r - "..L["commandBanListChat"]);
		print(" ");
	end,

	["ban"] = function()
		--core.Config.addBan();
	end;

	['unban'] = function()
		--core.Config.removeBan();
	end;

	['banlist'] = function()
		core.Config.checkBanList();
	end;

};

local function HandleSlashCommands(str)	
	if (#str == 0) then	
		-- User just entered "/at" with no additional args.
		core.commands.help();
		return;		
	end	
	
	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = core.commands; -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower();			
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))); 
					return;					
				elseif (type(path[arg]) == "table") then				
					path = path[arg]; -- another sub-table found!
				end
			else
				-- does not exist!
				core.commands.help();
				return;
			end
		end
	end
end

function core:Print(...)
    local hex = select(4, self.Config:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), "Personal Black List:");	
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

-- WARNING: self automatically becomes events frame!
function core:init(event, name)
	if (name ~= "PersonalBlacklist") then return end 

	-- allows using left and right buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end
	
	----------------------------------
	-- Register Slash Commands!
	----------------------------------

	SLASH_PersonalBlacklist1 = "/pbl";
	SlashCmdList.PersonalBlacklist = HandleSlashCommands;

	if(not PBL_) then
		PBL_ = {
			bans = {
				ban_name = {},
				ban_class = {},
				ban_category = {},
				ban_categories = {},
				ban_clases = {},
			 }
		} 
	end

	if(not PBL_.bans) then PBL_.bans = { }; end
	if(not PBL_.bans.ban_name) then PBL_.bans.ban_name = { }; end
	if(not PBL_.bans.ban_class) then PBL_.bans.ban_class = { }; end
	if(not PBL_.bans.ban_category) then PBL_.bans.ban_category = { }; end
	
	if(not PBL_.bans.ban_categories) then PBL_.bans.ban_categories = { }; end
	if(not PBL_.bans.ban_clases) then PBL_.bans.ban_clases = { }; end

	PBL_.bans.ban_categories = {
		L["dropDownCat"],
		L["dropDownAll"],
		L["dropDownGuild"],
		L["dropDownRaid"],
		L["dropDownMythic"],
		L["dropDownPvP"],
		L["dropDownWorld"]
	};
	PBL_.bans.ban_clases = {
		"WARRIOR",
		"PALADIN",
		"HUNTER",
		"ROGUE",
		"PRIEST",
		"SHAMAN",
		"MAGE",
		"WARLOCK",
		"MONK",
		"DRUID",
		"DEMONHUNTER",
		"DEATHKNIGHT"
	};

	StaticPopupDialogs.CONFIRM_LEAVE_IGNORE = {
		text = "%s",
		button1 = L["confirmYesBtn"],
		button2 = L["confirmNoBtn"],
		OnAccept = LeaveParty,
		whileDead = 1, hideOnEscape = 1, showAlert = 1,
	}

	local defaultBL =
	{
		LeaveAllert = false,
	}
	local indexBL =
	{
		[1] = "LeaveAllert",
	}

	local f = CreateFrame("Frame");

	local was = "";
	function f:OnEvent(event)
		if event == "GROUP_ROSTER_UPDATE" then
			C_Timer.After(2, function()
				local pjs = {};
				local fullName="";
				local name,realm="";
				for i=1, GetNumGroupMembers() do
					if GetNumGroupMembers() < 6 then
						name,realm = UnitName("party".. i)
						--print("party=",i,"name=",name,"server=",realm)
					else
						name,realm = UnitName("raid".. i)
						--print("raid=",i,"name=",name,"server=",realm)
					end
					if name then
						if (not realm) or (realm == " ") or (realm == "") then realm = GetRealmName(); realm=realm:gsub(" ",""); end
						local fullName = strupper(name.."-"..realm);
						for j=1, table.getn(PBL_.bans.ban_name) do
							if PBL_.bans.ban_name[j] == fullName then -- found an ignored player
								pjs[table.getn(pjs) + 1] = fullName
								if was ~= fullName then
									print("|cffff0000".."Here is",fullName,"who is in your BlackList")
									was = fullName;
								end
							end	
						end
					end						
				end
				if PBL_.BL_SavedVariables[indexBL[1]] == false then
					if table.getn(pjs) ~= 0 then
						text = ""
						for j=1, table.getn(pjs) do
							text = text..pjs[j].."\n"
						end
						if table.getn(pjs) > 1 then
							text = text..L["confirmMultipleTxt"]
						else
							text = text..L["confirmSingleTxt"]
						end
						StaticPopup_Show("CONFIRM_LEAVE_IGNORE", text);
					end
				end

			end)
		end
	end

	GameTooltip:HookScript("OnTooltipSetUnit", function(self)
		local name, unit = self:GetUnit()
		if UnitIsPlayer(unit) and not UnitIsUnit(unit, "player") and not UnitIsUnit(unit, "party") then
			local name, realm = UnitName(unit)
			if realm == nil then
				realm=GetRealmName()
				realm=realm:gsub(" ","");
			end
			name = name .. "-" .. realm;
			if has_value(PBL_.bans.ban_name, strupper(name)) then
				self:AddLine("PBL Blacklisted!", 1, 0, 0, true)	
			end
		end
	end)

	local hooked = { }

	local function OnLeaveHook(self)
		GameTooltip:Hide();
	end

	hooksecurefunc("LFGListApplicationViewer_UpdateResults", function(self)
		local buttons = self.ScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not hooked[button] then
				if button.applicantID and button.Members then
					for j = 1, #button.Members do
						local b = button.Members[j]
						if not hooked[b] then
							hooked[b] = 1
							b:HookScript("OnEnter", function()
								local appID = button.applicantID;
								local name = C_LFGList.GetApplicantMemberInfo(appID, 1);
								if not string.match(name, "-") then
									local realm = GetRealmName();
									realm=realm:gsub(" ","");
									name = name.."-"..realm;
								end
								if has_value(PBL_.bans.ban_name, strupper(name)) then			
									GameTooltip:AddLine("PBL Blacklisted!",1,0,0,true);
									GameTooltip:Show();
								end
							end)
							b:HookScript("OnLeave", OnLeaveHook)
						end
					end
				end
			end
		end
	end)
-----------------
--
-----------------
local PopUpBan = CreateFrame("Frame","PopUpBanFrame")
PopUpBan:SetScript("OnEvent", function() hooksecurefunc("UnitPopup_OnClick", AddToBan) end)
PopUpBan:RegisterEvent("PLAYER_LOGIN")
local PopupUnits = {}
UnitPopupButtons["GiveABan"] = { text = "Give a ban", }
table.insert( UnitPopupMenus["SELF"] ,1 , "GiveABan" )

for i,UPMenus in pairs(UnitPopupMenus) do
  for j=1, #UPMenus do
    if UPMenus[j] == "WHISPER" then
      PopupUnits[#PopupUnits + 1] = i
      pos = j + 1
      table.insert( UnitPopupMenus[i] ,pos , "GiveABan" )
      break
    end
  end
end

function AddToBan (self)
 local button = self.value;
 if ( button == "GiveABan" ) then
  local dropdownFrame = UIDROPDOWNMENU_INIT_MENU;
  local unit = dropdownFrame.unit;
  local name = dropdownFrame.name;
  local server = "";
  server = dropdownFrame.server;
  local className,classFile,classID = UnitClass(unit);
  --print ("name=",name,"server=",server);
	if server==nil or server=="" then
		local realm = GetRealmName();
		server=realm:gsub(" ","");
		--print("server=",server);
	end
   local fullname = name.."-"..server;
   --print("fullname=",fullname)
  if (fullname ~= nil or fullname ~= "") then
		local banexist = 0;
		for i=1, table.getn(PBL_.bans.ban_name) do
			--print("banname=",PBL_.bans.ban_name[i])
			if PBL_.bans.ban_name[i] == strupper(fullname) then
				table.remove(PBL_.bans.ban_name, i);
				table.remove(PBL_.bans.ban_category, i);
				table.remove(PBL_.bans.ban_class, i);
				populateBanLists();
				print("|cffff0000"..fullname.."remove from BlackList")
				--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Unable to add "..fullname.." to the ban list - the user is already banned.");
				banexist = 1;
			end
		end
		if (banexist == 0) then	
			
				table.insert(PBL_.bans.ban_name,strupper(fullname));
				table.insert(PBL_.bans.ban_category,"PopUp");
				table.insert(PBL_.bans.ban_class,classFile);

				populateBanLists();
				print("|cffff0000"..fullname.." Succesfully Banned for PBL!")
				--local string3 = strjoin("",fullname," Succesfully Banned for PBL!");
				--DEFAULT_CHAT_FRAME:AddMessage(strjoin("|cffffff00", string3));
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Error: No name provided.");
	end
 end
end
--------------------
---
--------------------

if PBL_.BL_SavedVariables == nil then
	--print(defaultBL)
	PBL_.BL_SavedVariables = defaultBL;
else
	--print("2")
	for key, value in pairs(defaultBL) do
		if PBL_.BL_SavedVariables[key] == nil then
			PBL_.BL_SavedVariables[key] = value
		end
	end
end

BL = {}
BL.panel = CreateFrame("Frame", "BL_Panel", UIParent)
BL.panel.name = "Black list"
InterfaceOptions_AddCategory (BL.panel)

local buttonList = {}

function createCheckButton(i, x, y)
	local list = 
	{
		" Leave Allert",
		" Disable double click targeting in combat",
		" Disable right click targeting out of combat",
		" Disable double click targeting out of combat",
	}
	local checkButton = CreateFrame("CheckButton", "BL_CheckButton" .. i, BL.panel, "UICheckButtonTemplate")
	buttonList[i] = checkButton
	checkButton:ClearAllPoints()
	checkButton:SetPoint("TOPLEFT", x * 32, y * -32)
	checkButton:SetSize(32, 32)
	_G[checkButton:GetName() .. "Text"]:SetText(list[i])
	_G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
	buttonList[i]:SetScript("OnClick", function()
		if buttonList[i]:GetChecked() then
			--print("get1",i,PBL_.BL_SavedVariables[indexBL[i]])
			PBL_.BL_SavedVariables[indexBL[i]] = false
		else
			--print("get2",i,PBL_.BL_SavedVariables[indexBL[i]])
			PBL_.BL_SavedVariables[indexBL[i]] = true
		end
		--print("ss",i)
		setupButtons()
	end)
end

createCheckButton(1, 1, 1)
--createCheckButton(2, 1, 2)
--createCheckButton(3, 1, 3)
--createCheckButton(4, 1, 4)

function setupButtons()
	for i = 1, #buttonList do
		--print("set1",i)
		--if i % 2 == 1 then
			-- if PBL_.BL_SavedVariables[indexBL[i]] then
			-- 	buttonList[i]:SetChecked(false)
			-- 	buttonList[i + 1]:SetAlpha(.5)
			-- 	buttonList[i + 1]:Disable()
			-- else
			-- 	buttonList[i]:SetChecked(true)
			-- 	buttonList[i + 1]:SetAlpha(1)
			-- 	buttonList[i + 1]:Enable()
			-- end
		--else
			if PBL_.BL_SavedVariables[indexBL[i]] then
				buttonList[i]:SetChecked(false)
			else
				buttonList[i]:SetChecked(true)
			end
		--end
	end
end

local func1 = CreateFrame("Frame")
func1:RegisterEvent("ADDON_LOADED")
func1:SetScript("OnEvent", setupButtons)
-----------------------
---
-----------------------
function has_value (tab, val)
    for indexBL, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
							
	
function PBL_MinimapButton_OnClick()
	 core.commands.show();
end


	f:RegisterEvent("GROUP_ROSTER_UPDATE");
	f:SetScript("OnEvent", f.OnEvent);

end

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", core.init);