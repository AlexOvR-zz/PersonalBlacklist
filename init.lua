local _, core = ...; -- Namespace
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");


LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("PersonalBlacklist", {
	type = "launcher",
	icon = "Interface\\AddOns\\PersonalBlacklist\\Media\\Icon2",
	OnClick = function(PBL_Cont, PBL_MinimapButton)
		InterfaceOptionsFrame_OpenToFrame(core.Config.UIConfig);
	end,
})

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
	["show"] = core.Config.Toggle, -- this is a function (no knowledge of Config object)
	
	["help"] = function()
		print(" ");
		core:Print("List of slash commands:")
		core:Print("|cff00cc66/pbl show|r - shows config menu");
		core:Print("|cff00cc66/pbl help|r - shows help info");
		core:Print("|cff00cc66/pbl ban|r - add a player to the ban list");
		core:Print("|cff00cc66/pbl unban|r - removes a player from the ban list");
		core:Print("|cff00cc66/pbl banlist|r - show the banlist");
		print(" ");
	end,

	["ban"] = function()
		--core.Config.addBan();
	end;

	['unban'] = function()
		--core.Config.removeBan();
	end;

	['banlist'] = function()
		--core.Config.removeAddBan(2);
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
				ban_reason = {},
				ban_category = {},
				ban_categories = {},
				ban_reasons = {},
			 }
		} 
	end

	if(not PBL_.bans) then PBL_.bans = { }; end
	if(not PBL_.bans.ban_name) then PBL_.bans.ban_name = { }; end
	if(not PBL_.bans.ban_reason) then PBL_.bans.ban_reason = { }; end
	if(not PBL_.bans.ban_category) then PBL_.bans.ban_category = { }; end
	
	if(not PBL_.bans.ban_categories) then PBL_.bans.ban_categories = { }; end
	if(not PBL_.bans.ban_reasons) then PBL_.bans.ban_reasons = { }; end

	PBL_.bans.ban_categories = {"--Categories--","All","Guild","Raid","Mythic+","PvP","World"};
	PBL_.bans.ban_reasons = {"--Reasons--","All","Quiter","Toxic","Bad DPS","Bad Heal","Bad Tank","Bad Player","AFKer","Ninja","Spammer","Scammer","Racist"};

	StaticPopupDialogs.CONFIRM_LEAVE_IGNORE = {
		text = "%s is on your PBL banned list. Do you want to leave this group?",
		button1 = YES,
		button2 = NO,
		OnAccept = LeaveParty,
		whileDead = 1, hideOnEscape = 1, showAlert = 1,
	}

	local f = CreateFrame("Frame");

	function f:OnEvent(event)
		if event == "GROUP_ROSTER_UPDATE" then
			C_Timer.After(2, function()
				for i=1, GetNumGroupMembers() do
					local name,realm = UnitName("party".. i);								
					if (not realm) or (realm == " ") or (realm == "") then realm = GetRealmName(); end
					local fullName = strupper(name.."-"..realm);
						for j=1, table.getn(PBL_.bans.ban_name) do
							if PBL_.bans.ban_name[j] == fullName then -- found an ignored player
								StaticPopup_Show("CONFIRM_LEAVE_IGNORE", fullName);
							end	
						end						
				end
			end)
		end
	end



GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local name, unit = self:GetUnit()
	if UnitIsPlayer(unit) and not UnitIsUnit(unit, "player") and not UnitIsUnit(unit, "party") then
		local name, realm = UnitName(unit)
		name = name .. "-" .. (realm or GetRealmName())
		if has_value(PBL_.bans.ban_name, strupper(name)) then		
				self:AddLine("PBL Blacklisted!", 1, 0, 0, true)	
		end
	end
end)

local hooked = { }

local function OnEnterHook(self)
	if not self.tooltip then
			C_Timer.After(1, function()

				local appID = self.applicantID;

				local name = C_LFGList.GetApplicantMemberInfo(appID, 1);

				if not string.match(name, "-") then
					name = name.."-"..GetRealmName();
				end

				if has_value(PBL_.bans.ban_name, strupper(name)) then	
					DEFAULT_CHAT_FRAME:AddMessage("|cffffff00EasyMenu TEST Applicant ID ");			
					GameTooltip:AddLine("PBL Blacklisted!",1,0,0,true);
					GameTooltip:Show();
				end
			end,1)
	end	
end

local function OnLeaveHook(self)
		GameTooltip:Hide();
end

hooksecurefunc("LFGListApplicationViewer_UpdateResults", function(self)
	local buttons = self.ScrollFrame.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		if not hooked[button] then
			button:HookScript("OnEnter", OnEnterHook);
			button:HookScript("OnLeave", OnLeaveHook);
			hooked[button] = true;
		end
	end
end)

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
							
	if PBL_["minimap"] == nil then
		-- If the value is not true/false then set it to true to show initially.
			PBL_["minimap"] = true
	end

	if PBL_["minimap"] then
		-- show minimap
		PBL_MinimapButton:Show()
	else
		PBL_MinimapButton:Hide()
	end

function Minimap_Toggle()
	if PBL_["minimap"] then
		-- minimap is shown, set to false, and hide
		PBL_["minimap"] = false
		PBL_MinimapButton:Hide()
	else
		-- minimap is now shown, set to true, and show
		PBL_["minimap"] = true
		PBL_MinimapButton:Show()
	end
end

PBL_Settings = {
	MinimapPos = 80

}

function PBL_MinimapButton_Reposition()
	PBL_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(PBL_Settings.MinimapPos)),(80*sin(PBL_Settings.MinimapPos))-52)
end


function PBL_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70
	ypos = ypos/UIParent:GetScale()-ymin-70

	PBL_Settings.MinimapPos = math.deg(math.atan2(ypos,xpos))
	PBL_MinimapButton_Reposition();
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