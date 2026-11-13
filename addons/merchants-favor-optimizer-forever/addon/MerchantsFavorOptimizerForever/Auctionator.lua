local _, MFO = ...

function MFO:AuctionatorReady()
  return Auctionator and Auctionator.API and Auctionator.API.v1
end

function MFO:GetPrice(itemID)
  if not self:AuctionatorReady() then return nil end
  return Auctionator.API.v1.GetAuctionPriceByItemID(self.callerID, itemID)
end

function MFO:GetAge(itemID)
  if not self:AuctionatorReady() then return nil end
  return Auctionator.API.v1.GetAuctionAgeByItemID(self.callerID, itemID)
end

function MFO:IsAutoScanEnabled()
  return Auctionator and Auctionator.Config and Auctionator.Config.Get and
    Auctionator.Config.Options and
    Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN) == true
end

function MFO:IsScanning()
  local frame = Auctionator and Auctionator.State and Auctionator.State.IncrementalScanFrameRef
  return frame and frame.doingFullScan == true
end

function MFO:PriceStatus()
  if not self:AuctionatorReady() then
    return "Auctionator required", "red"
  end
  if self:IsScanning() then return "Auctionator scan in progress", "amber" end
  local lastScan = Auctionator and Auctionator.SavedState and Auctionator.SavedState.TimeOfLastBrowseScan
  local minutes = lastScan and math.floor((time() - lastScan) / 60) or nil
  if not minutes then
    return "Full Scan recommended (no completed scan recorded)", "amber"
  end
  if minutes > self.db.staleMinutes then
    if self:IsAutoScanEnabled() then
      return "Waiting for Auctionator autoscan (oldest price " .. minutes .. "m)", "amber"
    end
    return "Full Scan recommended (oldest price " .. minutes .. "m)", "amber"
  end
  return "Auctionator prices current (oldest " .. minutes .. "m)", "green"
end

local nativeWanted
local nativeBuyHooked = false
local pendingPurchase

local function resetModernFilters(ah)
  local bar = ah and ah.SearchBar
  if not bar then return end
  local filter = bar.FilterButton
  if bar.ResetFilters then
    bar:ResetFilters()
  elseif filter and filter.Reset then
    filter:Reset()
  elseif filter and filter.ClearFiltersButton and filter.ClearFiltersButton:IsShown() then
    filter.ClearFiltersButton:Click()
  end
  local categories = ah.CategoriesList
  if categories and categories.SetSelectedCategory then categories:SetSelectedCategory(nil) end
end

local function resetClassicFilters()
  if AuctionFrameBrowse_Reset and BrowseResetButton then
    AuctionFrameBrowse_Reset(BrowseResetButton)
    return
  end
  if BrowseMinLevel then BrowseMinLevel:SetText("") end
  if BrowseMaxLevel then BrowseMaxLevel:SetText("") end
  if IsUsableCheckButton then IsUsableCheckButton:SetChecked(false) end
  if BrowseDropDown and UIDropDownMenu_SetSelectedValue then
    UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
  end
end

function MFO:SetNativeBuyQuantity(itemID)
  if not nativeWanted or not itemID or not AuctionHouseFrame then return end
  local name = self:ItemName(itemID)
  if name ~= nativeWanted.name then return end
  local quantity = nativeWanted.quantity
  if quantity and quantity > 0 and AuctionHouseFrame.TriggerEvent and
      AuctionHouseFrameMixin and AuctionHouseFrameMixin.Event then
    AuctionHouseFrame:TriggerEvent(
      AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, quantity)
  end
end

function MFO:HookNativeBuyFrame()
  local buyFrame = not nativeBuyHooked and AuctionHouseFrame and AuctionHouseFrame.CommoditiesBuyFrame
  if not buyFrame or not buyFrame.SetItemIDAndPrice then return end
  nativeBuyHooked = true
  hooksecurefunc(buyFrame, "SetItemIDAndPrice", function(_, itemID)
    C_Timer.After(0.05, function() MFO:SetNativeBuyQuantity(itemID) end)
  end)
end

function MFO:OpenNativeWanted()
  if not (nativeWanted and nativeWanted.open and AuctionHouseFrame and
      AuctionHouseFrame.SelectBrowseResult and C_AuctionHouse) then return end
  for _, result in ipairs(C_AuctionHouse.GetBrowseResults()) do
    local info = C_AuctionHouse.GetItemKeyInfo(result.itemKey)
    local name = info and info.itemName or self:ItemName(result.itemKey.itemID)
    if name and string.lower(name) == string.lower(nativeWanted.name) then
      nativeWanted.open = false
      AuctionHouseFrame:SelectBrowseResult(result)
      local itemID = result.itemKey.itemID
      C_Timer.After(0.08, function()
        MFO:SetNativeBuyQuantity(itemID)
      end)
      return
    end
  end
end

function MFO:SearchItem(itemID, quantity, searchName)
  if not ((AuctionHouseFrame and AuctionHouseFrame:IsShown()) or
      (AuctionFrame and AuctionFrame:IsShown())) then
    self:Print("Open the Auction House first.")
    return false
  end
  local itemName = searchName or self:ItemName(itemID)
  if string.sub(itemName, 1, 5) == "item:" then
    self:Print("Waiting for item data; try again in a moment.")
    return false
  end
  nativeWanted = { name = itemName, quantity = quantity or 1, open = true }
  if AuctionHouseFrame and AuctionHouseFrame:IsShown() and AuctionHouseFrame.SearchBar then
    self:HookNativeBuyFrame()
    if AuctionHouseFrame.SetDisplayMode and AuctionHouseFrameDisplayMode then
      AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.Buy)
    end
    resetModernFilters(AuctionHouseFrame)
    local bar = AuctionHouseFrame.SearchBar
    bar.SearchBox:SetText(itemName)
    bar:StartSearch()
    return true
  end
  if AuctionFrame and AuctionFrame:IsShown() and BrowseName then
    if AuctionFrameTab1 and PanelTemplates_GetSelectedTab(AuctionFrame) ~= 1 then
      AuctionFrameTab1:Click()
    end
    resetClassicFilters()
    BrowseName:SetText(itemName)
    AuctionFrameBrowse_Search()
    return true
  end
  self:Print("The normal Auction House Buy page is not available.")
  return false
end

function MFO:IsPurchasePending()
  return pendingPurchase ~= nil
end

function MFO:GetPendingPurchase()
  return pendingPurchase
end

function MFO:ClearPendingPurchase()
  pendingPurchase = nil
  nativeWanted = nil
  if self.UpdatePurchaseButton then self:UpdatePurchaseButton() end
end

function MFO:BeginNativePurchase(itemID, quantity, expectedTotal, kind, searchName)
  if pendingPurchase then return false end
  if not itemID or not quantity or quantity < 1 or not expectedTotal or expectedTotal < 1 then
    self:Print("The recommendation does not have a valid item, quantity, or price.")
    return false
  end
  pendingPurchase = {
    itemID = itemID,
    quantity = quantity,
    expectedTotal = expectedTotal,
    kind = kind,
    searchName = searchName,
    state = "opening",
  }
  if self.UpdatePurchaseButton then self:UpdatePurchaseButton() end
  local resolvedName = searchName or self:ItemName(itemID)
  if string.sub(resolvedName, 1, 5) == "item:" then
    pendingPurchase.state = "itemdata"
    if C_Item and C_Item.RequestLoadItemDataByID then
      C_Item.RequestLoadItemDataByID(itemID)
    end
    return true
  end
  if not self:SearchItem(itemID, quantity, resolvedName) then
    self:ClearPendingPurchase()
    return false
  end
  pendingPurchase.state = "awaiting_native_buy"
  if self.UpdatePurchaseButton then self:UpdatePurchaseButton() end
  return true
end

function MFO:ResumePendingItemData(itemID, success)
  local purchase = pendingPurchase
  if not purchase or purchase.state ~= "itemdata" or purchase.itemID ~= itemID then return end
  if success == false then
    self:Print("WoW could not load that item's name. Nothing was purchased.")
    self:ClearPendingPurchase()
    return
  end
  local name = purchase.searchName or self:ItemName(itemID)
  if string.sub(name, 1, 5) == "item:" then return end
  purchase.state = "itemdata_ready"
  purchase.searchName = name
  if self.UpdatePurchaseButton then self:UpdatePurchaseButton() end
end

function MFO:CancelPendingPurchase()
  nativeWanted = nil
  self:ClearPendingPurchase()
end

function MFO:ConfirmPendingPurchase()
  local purchase = pendingPurchase
  if not purchase then return false end
  if purchase.state ~= "itemdata_ready" and purchase.state ~= "awaiting_native_buy" then
    return false
  end
  purchase.state = "opening"
  if self.UpdatePurchaseButton then self:UpdatePurchaseButton() end
  if not self:SearchItem(purchase.itemID, purchase.quantity, purchase.searchName) then
    self:ClearPendingPurchase()
    return false
  end
  purchase.state = "awaiting_native_buy"
  if self.UpdatePurchaseButton then self:UpdatePurchaseButton() end
  return true
end

function MFO:HandlePurchaseEvent(event, ...)
  local purchase = pendingPurchase
  if not purchase then return end
  if event == "COMMODITY_PURCHASE_SUCCEEDED" then
    local kind = purchase.kind
    self:ClearPendingPurchase()
    if self.OnOptimizerPurchaseSucceeded then self:OnOptimizerPurchaseSucceeded(kind) end
  elseif event == "COMMODITY_PURCHASE_FAILED" then
    self:Print("The Auction House purchase failed. Nothing was bought; try again.")
    self:ClearPendingPurchase()
  end
end

function MFO:RegisterAuctionatorUpdates()
  if self:AuctionatorReady() and Auctionator.API.v1.RegisterForDBUpdate then
    Auctionator.API.v1.RegisterForDBUpdate(self.callerID, function()
      if MFO.Refresh then MFO:Refresh(true) end
    end)
  end
end
