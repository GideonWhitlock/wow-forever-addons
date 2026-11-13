local _, MFO = ...

local colors = {
  green = {0.2, 1, 0.2}, amber = {1, 0.72, 0.1}, red = {1, 0.25, 0.25},
}

local function makeButton(parent, text, width)
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetSize(width, 24)
  button:SetText(text)
  return button
end

local function addSelectedTabStyle(button)
  button:SetNormalTexture("")
  button:SetPushedTexture("")
  button:SetDisabledTexture("")

  local base = button:CreateTexture(nil, "BACKGROUND", nil, 1)
  base:SetPoint("TOPLEFT", 2, -2)
  base:SetPoint("BOTTOMRIGHT", -2, 2)
  base:SetColorTexture(0.16, 0.16, 0.16, 0.96)
  button.baseFill = base

  local fill = button:CreateTexture(nil, "BACKGROUND", nil, 2)
  fill:SetPoint("TOPLEFT", 2, -2)
  fill:SetPoint("BOTTOMRIGHT", -2, 2)
  fill:SetColorTexture(0.58, 0.34, 0.03, 0.96)
  fill:Hide()
  button.selectedFill = fill

  button.selectedEdges = {}
  local top = button:CreateTexture(nil, "ARTWORK")
  top:SetPoint("TOPLEFT", 3, -2)
  top:SetPoint("TOPRIGHT", -3, -2)
  top:SetHeight(1)
  local bottom = button:CreateTexture(nil, "ARTWORK")
  bottom:SetPoint("BOTTOMLEFT", 3, 2)
  bottom:SetPoint("BOTTOMRIGHT", -3, 2)
  bottom:SetHeight(1)
  local left = button:CreateTexture(nil, "ARTWORK")
  left:SetPoint("TOPLEFT", 3, -2)
  left:SetPoint("BOTTOMLEFT", 3, 2)
  left:SetWidth(1)
  local right = button:CreateTexture(nil, "ARTWORK")
  right:SetPoint("TOPRIGHT", -3, -2)
  right:SetPoint("BOTTOMRIGHT", -3, 2)
  right:SetWidth(1)
  for _, edge in ipairs({top, bottom, left, right}) do
    edge:SetColorTexture(1, 0.76, 0.12, 0.68)
    table.insert(button.selectedEdges, edge)
  end


  local hover = button:CreateTexture(nil, "HIGHLIGHT")
  hover:SetPoint("TOPLEFT", 3, -3)
  hover:SetPoint("BOTTOMRIGHT", -3, 3)
  hover:SetColorTexture(1, 0.78, 0.18, 0.16)
end

local function setSelectedTab(button, selected)
  button:Enable()
  if selected then
    button.selectedFill:Show()
    for _, edge in ipairs(button.selectedEdges) do
      edge:SetColorTexture(1, 0.82, 0.20, 1)
    end
    local text = button:GetFontString()
    if text then text:SetTextColor(1, 1, 1) end
  else
    button.selectedFill:Hide()
    for _, edge in ipairs(button.selectedEdges) do
      edge:SetColorTexture(1, 0.76, 0.12, 0.68)
    end
    local text = button:GetFontString()
    if text then text:SetTextColor(1, 0.82, 0.18) end
  end
end

function MFO:CreateUI()
  if self.frame then return end
  local frame = CreateFrame("Frame", "MerchantsFavorOptimizerForeverFrame", UIParent, "PortraitFrameTemplate")
  frame:SetSize(470, 390)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(100)
  frame:SetPoint("CENTER")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:Hide()
  self.frame = frame

  if frame.TitleText then frame.TitleText:SetText("Merchant's Favor Optimizer: Forever") end
  if frame.TitleContainer and frame.TitleContainer.TitleText then
    frame.TitleContainer.TitleText:SetText("Merchant's Favor Optimizer: Forever")
  end
  if frame.portrait then frame.portrait:SetTexture("Interface\\Icons\\INV_Misc_Coin_01") end
  if frame.PortraitContainer and frame.PortraitContainer.portrait then
    frame.PortraitContainer.portrait:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
  end

  local status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  status:SetPoint("TOPLEFT", 18, -62)
  status:SetPoint("TOPRIGHT", -18, -62)
  status:SetJustifyH("LEFT")
  self.statusText = status

  local modes = {
    {"all", "Crate + materials"}, {"materials", "Missing materials"}, {"crate", "Crate only"},
  }
  self.modeButtons = {}
  for index, info in ipairs(modes) do
    local button = makeButton(frame, info[2], index == 1 and 142 or 138)
    if index == 1 then button:SetPoint("TOPLEFT", 16, -88)
    else button:SetPoint("LEFT", self.modeButtons[index - 1], "RIGHT", 4, 0) end
    button:SetScript("OnClick", function()
      MFO.db.mode = info[1]
      MFO.purchaseCycle = 1
      MFO.purchaseSignature = nil
      MFO:Refresh()
    end)
    button.mode = info[1]
    addSelectedTabStyle(button)
    self.modeButtons[index] = button
  end

  local card = CreateFrame("Frame", nil, frame)
  card:SetPoint("TOPLEFT", 18, -118)
  card:SetSize(434, 128)
  local cardFill = card:CreateTexture(nil, "BACKGROUND")
  cardFill:SetAllPoints()
  cardFill:SetColorTexture(0.08, 0.07, 0.05, 0.84)
  local cardBorder = card:CreateTexture(nil, "ARTWORK")
  cardBorder:SetPoint("TOPLEFT")
  cardBorder:SetPoint("TOPRIGHT")
  cardBorder:SetHeight(1)
  cardBorder:SetColorTexture(0.78, 0.58, 0.15, 0.85)

  local heading = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  heading:SetPoint("TOPLEFT", 10, -9)
  heading:SetText("Best crate + bundle")

  local crateText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  crateText:SetPoint("TOPLEFT", 10, -35)
  crateText:SetPoint("RIGHT", -10, 0)
  crateText:SetJustifyH("LEFT")
  self.crateText = crateText

  local materialText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  materialText:SetPoint("TOPLEFT", 10, -57)
  materialText:SetPoint("RIGHT", -10, 0)
  materialText:SetJustifyH("LEFT")
  self.materialText = materialText

  local totalText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  totalText:SetPoint("TOPLEFT", 10, -84)
  totalText:SetWidth(200)
  totalText:SetJustifyH("LEFT")
  self.totalText = totalText

  local perText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  perText:SetPoint("TOPLEFT", 220, -84)
  perText:SetPoint("RIGHT", -10, 0)
  perText:SetJustifyH("LEFT")
  self.perText = perText

  local ownershipText = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ownershipText:SetPoint("TOPLEFT", 10, -106)
  ownershipText:SetPoint("RIGHT", -10, 0)
  ownershipText:SetJustifyH("LEFT")
  self.ownershipText = ownershipText

  local purchaseButton = makeButton(frame, "Buy next item", 434)
  purchaseButton:SetPoint("TOPLEFT", 18, -254)
  purchaseButton:SetScript("OnClick", function() MFO:BuyNextPurchase() end)
  self.purchaseButton = purchaseButton

  local refresh = makeButton(frame, "Recalculate", 212)
  refresh:SetPoint("BOTTOMLEFT", 18, 42)
  refresh:SetScript("OnClick", function() MFO:ManualRecalculate() end)

  local scan = makeButton(frame, "Scan help", 212)
  scan:SetPoint("LEFT", refresh, "RIGHT", 10, 0)
  scan:SetScript("OnClick", function()
    if MFO:IsAutoScanEnabled() then
      MFO:Print("Auctionator autoscan is enabled. Open the Auction House and let its scan finish.")
    else
      MFO:Print("Open the Auction House and click Auctionator's Full Scan tab. This add-on will recalculate when its database updates.")
    end
  end)

  local note = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  note:SetPoint("BOTTOMLEFT", 20, 18)
  note:SetPoint("BOTTOMRIGHT", -20, 18)
  note:SetText("Open the exact item here, then press WoW's own Buy button. Success advances the bundle.")

  frame:SetScript("OnShow", function() MFO:AnchorFrame(); MFO:Refresh() end)
end

function MFO:AnchorFrame()
  if not self.frame then return end
  self.frame:ClearAllPoints()
  local waylaid = _G.WaylaidCratesPanel
  if waylaid and waylaid:IsShown() then
    self.frame:SetPoint("TOPLEFT", waylaid, "TOPRIGHT", 12, 0)
  elseif AuctionHouseFrame and AuctionHouseFrame:IsShown() then
    self.frame:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", 12, 0)
  elseif AuctionFrame and AuctionFrame:IsShown() then
    self.frame:SetPoint("TOPLEFT", AuctionFrame, "TOPRIGHT", 12, 0)
  else
    self.frame:SetPoint("CENTER")
  end
end

function MFO:Refresh(silent)
  if not self.frame or not self.frame:IsShown() then return end
  self.statusGeneration = (self.statusGeneration or 0) + 1
  self:AnchorFrame()
  local status, color = self:PriceStatus()
  self.statusText:SetText(status)
  self.statusText:SetTextColor(unpack(colors[color] or colors.amber))
  for _, button in ipairs(self.modeButtons) do
    setSelectedTab(button, button.mode == self.db.mode)
  end
  local keepSelection = self:IsPurchasePending() or (self.purchaseCycle or 1) > 1
  local lockedSelection = keepSelection and self.selected or nil
  local results = self:Rank(self.db.mode)
  self.results = results
  self.selected = lockedSelection or results[1]
  self:RefreshDetail()
  if not silent and #results == 0 then
    self:Print("No eligible recommendations. Run an Auctionator Full Scan or change mode.")
  end
end

function MFO:RecommendationSignature(result)
  if not result then return "none" end
  return table.concat({
    self.db.mode or "all",
    result.crate and result.crate.id or 0,
    result.bundle and result.bundle.itemID or 0,
    result.totalCost or 0,
  }, ":")
end

function MFO:ManualRecalculate()
  local before = self:RecommendationSignature(self.selected)
  self:Refresh(true)
  local changed = before ~= self:RecommendationSignature(self.selected)
  local generation = self.statusGeneration or 0
  local timeText = date and date("%H:%M") or "now"
  self.statusText:SetText(changed
    and ("Recalculated at " .. timeText .. " — recommendation updated")
    or ("Recalculated at " .. timeText .. " — still the best option"))
  self.statusText:SetTextColor(unpack(colors.green))
  if C_Timer and C_Timer.After then
    C_Timer.After(4, function()
      if MFO.frame and MFO.frame:IsShown() and MFO.statusGeneration == generation then
        MFO:Refresh(true)
      end
    end)
  end
end

function MFO:RefreshDetail()
  local result = self.selected
  if not result then
    self.crateText:SetText("No priced recommendation available")
    self.materialText:SetText("Run an Auctionator Full Scan or change mode.")
    self.totalText:SetText("")
    self.perText:SetText("")
    self.ownershipText:SetText("Artisan crates remain excluded until their Favor rewards are verified.")
    self.purchaseButton:Disable()
    return
  end
  local itemName = self:ItemName(result.bundle.itemID)
  local materialCount = self.db.mode == "materials" and result.bundle.missing or result.bundle.needed
  local signature = self.db.mode .. ":" .. result.crate.id .. ":" .. result.bundle.itemID
  if self.purchaseSignature ~= signature then
    self.purchaseSignature = signature
    self.purchaseCycle = 1
  end
  self.crateText:SetText("|cffffd100Crate:|r Waylaid Crate: " .. result.crate.name)
  self.materialText:SetText("|cffffd100Materials:|r " .. itemName .. " x" .. materialCount)
  self.totalText:SetText("Total: |cffffffff" .. self:Money(result.totalCost) .. "|r")
  self.perText:SetText("Per Favor: |cffffffff" .. self:Money(math.floor(result.costPerFavor + 0.5)) .. "|r")
  self.ownershipText:SetText(string.format("%d Favor • materials owned %s • coin return %s",
    result.crate.favor, self:OwnershipText(result.bundle.itemID, result.bundle.needed), self:Money(result.coinReward)))
  self.purchaseButton:Enable()
  self:UpdatePurchaseButton()
end

function MFO:CurrentPurchaseSteps()
  if self.db.mode == "materials" then return {"materials"} end
  if self.db.mode == "crate" then return {"crate"} end
  return {"crate", "materials"}
end

function MFO:UpdatePurchaseButton()
  if not self.purchaseButton then return end
  if self:IsPurchasePending() then
    local purchase = self.GetPendingPurchase and self:GetPendingPurchase() or nil
    if purchase and purchase.state == "itemdata_ready" then
      self.purchaseButton:SetText("Open: " .. purchase.searchName .. " x" .. purchase.quantity)
      self.purchaseButton:Enable()
    elseif purchase and purchase.state == "awaiting_native_buy" then
      self.purchaseButton:SetText("Waiting for WoW Buy — reopen " .. purchase.searchName .. " x" .. purchase.quantity)
      self.purchaseButton:Enable()
    else
      self.purchaseButton:SetText("Opening exact auction...")
      self.purchaseButton:Disable()
    end
    return
  end
  if not self.selected then
    self.purchaseButton:SetText("No purchase available")
    self.purchaseButton:Disable()
    return
  end
  local steps = self:CurrentPurchaseSteps()
  local index = self.purchaseCycle or 1
  local kind = steps[index] or steps[1]
  if kind == "crate" then
    self.purchaseButton:SetText("Buy next: Waylaid Crate x1")
  else
    local name = self:ItemName(self.selected.bundle.itemID)
    local count = self.db.mode == "materials" and self.selected.bundle.missing or self.selected.bundle.needed
    self.purchaseButton:SetText("Buy next: " .. name .. " x" .. count)
  end
  self.purchaseButton:Enable()
end

function MFO:BuyNextPurchase()
  local result = self.selected
  if self:IsPurchasePending() then return self:ConfirmPendingPurchase() end
  if self:IsScanning() then
    self:Print("Auctionator is still scanning. Wait for it to finish, then press the purchase button again.")
    return false
  end
  if not result then return false end
  local current = self:EvaluateCrate(result.crate, self.db.mode)
  if not current then self:Refresh(); return false end
  local changed = math.abs(current.totalCost - result.totalCost) / math.max(1, result.totalCost) * 100
  if changed >= self.db.materialChangePercent then
    self.selected = current
    self:Refresh()
    self:Print(string.format("Price changed by %.1f%%. Recommendation refreshed; click again to continue.", changed))
    return false
  end
  local steps = self:CurrentPurchaseSteps()
  local index = self.purchaseCycle or 1
  local kind = steps[index] or steps[1]
  local itemID, count, expectedTotal, searchName
  if kind == "crate" then
    itemID, count, expectedTotal = current.crate.id, 1, current.cratePrice
    searchName = "Waylaid Crate: " .. current.crate.name
  else
    itemID = current.bundle.itemID
    count = self.db.mode == "materials" and current.bundle.missing or current.bundle.needed
    expectedTotal = current.bundle.unitPrice * count
    if count <= 0 then
      self:Print("You already own the required materials.")
      return false
    end
  end
  return self:BeginNativePurchase(itemID, count, expectedTotal, kind, searchName)
end

function MFO:OnOptimizerPurchaseSucceeded(kind)
  local steps = self:CurrentPurchaseSteps()
  local index = self.purchaseCycle or 1
  if kind == "crate" and #steps > 1 then
    self.purchaseCycle = math.min(index + 1, #steps)
  else
    self.purchaseCycle = 1
    self.purchaseSignature = nil
    self:Refresh(true)
  end
  self:UpdatePurchaseButton()
end
