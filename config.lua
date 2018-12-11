--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace
local L = LibStub("AceLocale-3.0"):GetLocale("PBL")

local Config = core.Config;
local UIConfig;
tmpCatSelected = "";
tmpReaSelected = "";

--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local defaults = {
	theme = {
		r = 0, 
		g = 0.8, -- 204/255
		b = 1,
		hex = "00ccff"
	}
}

--------------------------------------
-- Config functions
--------------------------------------
function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function removeAddBan(action)
	local tempName = editBox1:GetText();
		if(action == 2) then
			Config:removeBan(tempName);
		else
			Config:addBan(tempName);
		end
end

function Config:GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

function btnClickEvents(id)		
	if(id == 3) then-- Check Ban List
		checkBanList(id);
	else
		removeAddBan(id);
	end
end

function populateBanLists()	
	editBox2:SetText("");
	editBox3:SetText("");

		for i=table.getn(PBL_.bans.ban_name), 1, -1  do			
			editBox2:Insert(strjoin("|cffffff00",PBL_.bans.ban_name[i].."\n"));			
			editBox3:Insert(strjoin("|cffffff00",PBL_.bans.ban_category[i].."/"..PBL_.bans.ban_reason[i].."\n"));
		end

end

function Config:addBan(name)
	local charname, realmname = strsplit("-",name);
	local fullcharname = charname .."-".. realmname; -- Full Char Name included Realm and - symbol
	local insname = strupper(fullcharname);
	if (insname ~= nil or insname ~= "") then
		local banexist = 0;
		for i=1, table.getn(PBL_.bans.ban_name) do
			if PBL_.bans.ban_name[i] == insname then
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Unable to add "..insname.." to the ban list - the user is already banned.");
				banexist = 1;
			end
		end
		if (banexist == 0) and (tmpCatSelected ~= nil) and (tmpReaSelected ~= nil) then	
			if(tmpCatSelected ~= "") and ( not tmpReaSelected ~= "") then
				table.insert(PBL_.bans.ban_name,insname);
				table.insert(PBL_.bans.ban_category,tmpCatSelected);
				table.insert(PBL_.bans.ban_reason,tmpReaSelected);

				populateBanLists();

				local string3 = strjoin("",insname," Succesfully Banned for PBL!");
				DEFAULT_CHAT_FRAME:AddMessage(strjoin("|cffffff00", string3));

			else
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Unable to add "..insname.." to the ban list - You need to select a Caterogy & a Reason.");
			end
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Error: No name provided.");
	end
end

function Config:removeBan(name)
	local tempCat = tmpCatSelected;
	local tempRea = tmpReaSelected;
	local charname, realmname = strsplit("-",name);
	local fullcharname = charname .."-".. realmname;
	local insname = strupper(fullcharname);
	if (insname ~= nil or insname ~= "") then
		for i=1, table.getn(PBL_.bans.ban_name) do
			if strupper(PBL_.bans.ban_name[i]) == strupper(insname) then

				table.remove(PBL_.bans.ban_name, i);
				table.remove(PBL_.bans.ban_category, i);
				table.remove(PBL_.bans.ban_reason, i);	

				populateBanLists();
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..insname.." removed from PBL ban list successfully.");
				return;
			end
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Error: No name provided.");
	end
end

function Config:checkBanList()
	local bancnt = 0;
	--Print("", "", "|cffffff00To ban do /mr ban (Name) or to unban /mr unban (Name) - The Current Bans:");
	for i=1, table.getn(PBL_.bans.ban_name) do
		bancnt = 1;
		DEFAULT_CHAT_FRAME:AddMessage(strjoin("|cffffff00", "...", tostring(PBL_.bans.ban_name[i])));
	end
	if (bancnt == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00To ban do or unban open the PBL UI with /pbl show");
	end
end

function Config:CreateButton(point, relativeFrame, relativePoint, xOffset, yOffset, text, id)
	local btn = CreateFrame("Button", "btn"..id, relativeFrame, "GameMenuButtonTemplate");
	btn:SetBackdrop({
		bgFile = [[Interface\Buttons\WHITE8x8]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		edgeSize = 14,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	})
	btn:SetBackdropBorderColor(0.3, 0.3, 0.3,1);
	btn:SetBackdropColor(0,0,0,0.8);
	btn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset);
	btn:SetSize(80, 30);
	btn:SetText(text);
	btn:SetScript("OnClick", function(self)btnClickEvents(id);end);
	btn:SetNormalFontObject("GameFontNormal");
	btn:SetHighlightFontObject("GameFontHighlight");

	return btn;
end

function Config:CreateSlider(point, relativeFrame, relativePoint, yOffset , xOffset, minVal , maxVal, defaultVal, stepVal, id)
	local slider = CreateFrame("SLIDER", nil, relativeFrame, "OptionsSliderTemplate");
	slider:SetPoint(point, relativeFrame, relativePoint, yOffset, xOffset);
	slider:SetMinMaxValues(minVal, maxVal);
	slider:SetValue(defaultVal);
	slider:SetValueStep(stepVal);
	slider:SetObeyStepOnDrag(true);

	return slider;
end

function Config:CreateCheckbox(point, relativeFrame, relativePoint, yOffset, xOffset, text, toolTxt, checked, id)
	local checkbox = CreateFrame("CheckButton", nil, relativeFrame, "UICheckButtonTemplate");
	checkbox:SetPoint(point, relativeFrame, relativePoint, yOffset, xOffset);	
	checkbox:SetChecked(checked);
	checkbox.text:SetText(text);
	checkbox.tooltip = toolTxt;

	return checkBox;
end

function Config:CreateTxtInstance(point, relativeFrame,relativePoint, yOffset, xOffset, txt, id, gameFont)

	local txtFrame = CreateFrame("Frame", "txt"..id, relativeFrame);
		  txtFrame:SetPoint(point, relativeFrame, relativePoint, yOffset, xOffset);	
		  txtFrame:SetSize(80, 20);

	local textInstance = txtFrame:CreateFontString(nil, "ARTWORK", gameFont);
	  	  	textInstance:SetPoint("TOPLEFT", 0, 0);
		    textInstance:SetText(txt);

	 return txtFrame;

end

function Config:CreateEditBox(point, relativeFrame, relativePoint, yOffset, xOffset, width, height, autoFocus, multiline, id)
	local editBox = CreateFrame("EditBox", "editBox"..id ,relativeFrame);
	editBox:SetBackdrop({
		bgFile = [[Interface\Buttons\WHITE8x8]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		edgeSize = 14,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	})
	if(id == 1)then
		editBox:SetBackdropColor(0,0,0,0.8);
		editBox:SetBackdropBorderColor(0.3, 0.3, 0.3,1);
		editBox:SetJustifyH("LEFT");
	else
		editBox:SetBackdropColor(0, 0, 0,0);
		editBox:SetBackdropBorderColor(0, 0, 0,0);
		editBox:EnableMouse(false);
		editBox:EnableKeyboard(false);
		editBox:SetJustifyH("CENTER");
	end
	editBox:SetFrameStrata("DIALOG")
	editBox:SetSize(width,height);
	editBox:SetAutoFocus(autoFocus)
	editBox:SetPoint(point, xOffset, yOffset)
	editBox:SetMultiLine(multiline);
	editBox:SetCursorPosition(0);	
	editBox:SetFont("Fonts\\FRIZQT__.TTF", 12);
	editBox:SetJustifyV("CENTER");
	editBox:SetScript("OnEscapePressed", function(self)
			Config:Toggle();
	   end)

	return editBox;
end



function Config:CreateDropDownMenu(point, relativeFrame, relativePoint, yOffset, xOffset, width, height, id, text)
	-- Create the dropdown, and configure its appearance
	local dropDown = CreateFrame("FRAME", "dropDown"..id, relativeFrame, "UIDropDownMenuTemplate")
	dropDown:SetPoint(point, xOffset, yOffset);

	UIDropDownMenu_SetText(dropDown, text);
	-- Create and bind the initialization function to the dropdown menu
	UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)	 
	 local info = UIDropDownMenu_CreateInfo()
	 if (level or 1) == 1 then
		if(id == 1)then			
			for i=1, table.getn(PBL_.bans.ban_categories) do	
						info.isTitle = false;
						info.text  =  strjoin("|cffffff00", tostring(PBL_.bans.ban_categories[i]));
						info.checked = false;
						info.isNotRadio = true;
						info.notCheckable = true;			
						info.menuList, info.hasArrow = i, false;	
						UIDropDownMenu_AddButton(info);
						info.func = self.SetValue;							
				end			
			end
		if(id == 2)then
				for i=1, table.getn(PBL_.bans.ban_reasons) do			
						info.isTitle = false;
						info.text  =  strjoin("|cffffff00", tostring(PBL_.bans.ban_reasons[i]));
						info.checked = false;
						info.isNotRadio = true;
						info.notCheckable = true;
						info.menuList, info.hasArrow = i, false;	
						UIDropDownMenu_AddButton(info);
						info.func = self.SetValue;				
				end	
			end			

	 end	 
	end)	
	function dropDown:SetValue()
		UIDropDownMenu_SetText(dropDown, text.. ": " ..self.value);	
		if(id == 1)then
			tmpCatSelected = self.value;		
		end
		if(id == 2)then
			tmpReaSelected = self.value;
		end
		CloseDropDownMenus();
	end

	UIDropDownMenu_SetWidth(dropDown,width);
	UIDropDownMenu_SetButtonWidth(dropDown,width);
	UIDropDownMenu_JustifyText(dropDown, "LEFT")

	return dropDown;
end

function Config:CreateEasyMenu(point, relativeFrame, relativePoint, yOffset, xOffset, width, height, txt, id)
	local easyMenu = CreateFrame("Frame", "easyMenu"..id, relativeFrame, "UIDropDownMenuTemplate");
		  --easyMenu:SetPoint(point, xOffset, yOffset);
		  easyMenu:SetSize(width,height);

	local easyMenuButton = CreateFrame("Button", "easyMenuButton"..id, relativeFrame, "GameMenuButtonTemplate");
		  easyMenuButton:SetSize(width,height);
	
		  for i=1, table.getn(PBL_.bans.ban_categories) do	

		  end

		menuTbl = {
		{
		text = PBL_.bans.ban_categories[i],
		hasArrow = true,
		checked = function()

			end
		},
		{
		text = "Beta",
		hasArrow = true,
		--[[menuList = {
			{ text = "BetaAlpha", },
			{ text = "BetaBeta", },
			{ text = "BetaGamma", },
		},]]
		},
		{
		text = "Some Setting",
		checked = function()
			return SOME_SETTING
		end,
		func = function()
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00EasyMenu TEST");
		end,
		},
		}
		easyMenuButton:SetText(txt)
		easyMenuButton:SetPoint("CENTER", 0, 0)
		easyMenuButton:SetScript("OnClick", function(self, button)
		EasyMenu(menuTbl, easyMenu, "easyMenuButton"..id, 0, 0, nil, 10)
	end)

	return easyMenu;

end


local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 20);
	
	if (newValue < 0) then
		newValue = 0;
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange();
	end
	
	self:SetVerticalScroll(newValue);
end

local function Tab_OnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());
	
	local scrollChild = UIConfig.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end
	
	UIConfig.ScrollFrame:SetScrollChild(self.content);
	self.content:Show();	
end

local function SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs;
	
	local contents = {};
	local frameName = frame:GetName();
	
	for i = 1, numTabs do	
		local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "CharacterFrameTabButtonTemplate");
		tab:SetID(i);
		tab:SetText(select(i, ...));
		tab:SetScript("OnClick", Tab_OnClick);
	
		tab.content = CreateFrame("Frame", 'content'..i, UIConfig.ScrollFrame);
		tab.content:SetSize(400, 320); --250,500
		tab.content:SetPoint("RIGHT", -140, 0)
		tab.content:Hide();

	
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
		tab.content.bg:SetColorTexture(0,0,0,0);
		
		--[[if(i == 1)then
			tab.content.bg:SetColorTexture(0,0,0,0);
		else
			tab.content.bg:SetColorTexture(0.3,0.4,0.4,1);
		end]]
		
		table.insert(contents, tab.content);
		
		if (i == 1) then
			tab:SetPoint("TOPLEFT", UIConfig, "BOTTOMLEFT", 5, 7);
		else
			tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -14, 0);
		end	
	end
	
	Tab_OnClick(_G[frameName.."Tab1"]);
	
	return unpack(contents);
end

function Config:CreateMenu()
	UIConfig = CreateFrame("Frame", "PBL_Config_", UIParent, "UIPanelDialogTemplate");
	UIConfig:SetSize(620, 320);
	UIConfig:SetPoint("TOP"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")
	UIConfig:RegisterForDrag("LeftButton");
	UIConfig:SetMovable(true);
	UIConfig:EnableMouse(true);
	UIConfig:RegisterForDrag("LeftButton");
	UIConfig:SetScript("OnDragStart", UIConfig.StartMoving);
	UIConfig:SetScript("OnDragStop", UIConfig.StopMovingOrSizing);
	
	PBL_Config_TitleBG:SetColorTexture(0,0,0,0.7);
    PBL_Config_DialogBG:SetColorTexture(0,0,0,0.7);

	UIConfig.Title:ClearAllPoints();
	UIConfig.Title:SetFontObject("GameFontHighlight");	
	UIConfig.Title:SetPoint("CENTER", PBL_Config_TitleBG, "CENTER", 6, 1);
	UIConfig.Title:SetText("Personal Black List                                                               PBL v1.5");	
	
	UIConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UIConfig, "UIPanelScrollFrameTemplate");
	UIConfig.ScrollFrame:SetPoint("TOPLEFT", PBL_Config_DialogBG, "TOPLEFT", 200, -5);
	UIConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", PBL_Config_DialogBG, "BOTTOMRIGHT", -3, 4);
	UIConfig.ScrollFrame:SetClipsChildren(true);
	UIConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);
	
	UIConfig.ScrollFrame.ScrollBar:ClearAllPoints();
    UIConfig.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UIConfig.ScrollFrame, "TOPRIGHT", -12, -18);
	UIConfig.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UIConfig.ScrollFrame, "BOTTOMRIGHT", -7, 18);
		

	local content1, content2 = SetTabs(UIConfig, 2, L["pblListTab"], L["creditsTab"]);
	
	----------------------------------
	-- Content1
	----------------------------------

	-- BUTTONS!! -- Para: point, relativeFrame, relativePoint, xOffset, yOffset,  text, id
	-- Add Button: -- 
	addBtn = self:CreateButton("CENTER", UIConfig, "TOP", -250, -120, L["addBtn"], 1);  -- TODO: OPtimization Wrap parameters in a table
	-- Remove Button:	
	rmvBtn = self:CreateButton("TOPLEFT", addBtn, "TOPRIGHT", 15, 0, L["removeBtn"], 2);

	-- EDIT BOXES!! -- Para:  point, relativeFrame, relativePoint, yOffset, xOffset, width, height, autoFocus, multiline, id
	-- Edit Box 1: (Ban List) --
	banEditBox = self:CreateEditBox("BOTTOM", addBtn, "TOPLEFT", 55, 48, 170, 25, false, false, 1);
	-- Edit Box 2 (Category List)
	content1.catEditBox = self:CreateEditBox("TOP", content1, "RIGHT", -30, -95, 170, 450, false, true, 2);
	-- Edit Box 3 (Reason List)
	content1.reaEditBox = self:CreateEditBox("TOP", content1, "RIGHT", -30, 90, 130, 450, false, true, 3);

	-- DROPDOWN MENUS!! -- Para: point, relativeFrame, relativePoint, yOffset, xOffset, width, height, id, txt
	-- DropDown 1: (Category List) --
	catDrop = self:CreateDropDownMenu("TOP", addBtn, "BOTTOM", -50, 50, 165, 30, 1, L["dropDownCatTitle"].." ");
	-- DropDown 2: (Reason List) --
	reaDrop = self:CreateDropDownMenu("TOP", addBtn, "BOTTOM", -100, 50, 165, 30, 2, L["dropDownReaTitle"].." ");

	-- TEXTS!!!! -- Para: point, relativeFrame,relativePoint, yOffset, xOffset, txt, id, gameFont
	banText = self:CreateTxtInstance("TOPLEFT", addBtn, "TOP", -36, 70, L["insertCharTxt"], 1 , "GameFontNormalLarge");
	banTextDesc = self:CreateTxtInstance("TOPLEFT", addBtn, "TOP", -30, 22, L["textFormatTxt"], 2, "GameFontDisableSmall");
	content1.chaText = self:CreateTxtInstance("TOPLEFT", content1, "TOP", -175, -8, L["charNameRealmTxt"], 3, "GameFontNormalLarge");
	content1.catReaText = self:CreateTxtInstance("TOPLEFT", content1, "TOP", 30, -8, L["catReaTxt"], 4 ,"GameFontNormalLarge");
	authorText = self:CreateTxtInstance("BOTTOM", reaDrop, "BOTTOM", -58, -75, L["createdByTxt"].." Xyløns @ Ragnaros US", 5 , "QuestFontNormalSmall");
	----------------------------------
	-- Content2
	----------------------------------
	-- TEXTS!!!! -- Para: point, relativeFrame,relativePoint, yOffset, xOffset, txt, id, gameFont
	content2.collaText = self:CreateTxtInstance("TOP", content2, "BOTTOM", -30, 310, L["collaboratorsTxt"], 6, "GameFontNormalLarge");
	-- EDIT BOXES!! -- Para:  point, relativeFrame, relativePoint, yOffset, xOffset, width, height, autoFocus, multiline, id
	content2.collaBox = self:CreateEditBox("TOP", content2.collaText, "TOPLEFT", -35, 15, 385, 25, false, true, 4);
	content2.collaBox:SetText("Author: \nCreated by Xyløns @ Ragnaros US\n \nART/Design by Bexonight @ Ragnaros US \nDevelopment by Xyløns & Heomel @ Ragnaros US \n \nTesting \nGuild <Paradøx> @ Ragnaros US\nLeoras @ Ragnaros US \nAreda @ Ragnaros US\nErzuliee @ Ragnaros US\n \nTranslations:\nLeoras-Ragnaros (esMX,esES)");

	populateBanLists();
	UIConfig:Hide();
	return UIConfig;
end