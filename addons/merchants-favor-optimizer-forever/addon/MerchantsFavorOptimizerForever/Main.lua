local _, MFO = ...

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("AUCTION_HOUSE_SHOW")
events:RegisterEvent("AUCTION_HOUSE_CLOSED")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
events:RegisterEvent("COMMODITY_PURCHASE_SUCCEEDED")
events:RegisterEvent("COMMODITY_PURCHASE_FAILED")
events:SetScript("OnEvent", function(_, event, ...)
  local name = ...
  if event == "ADDON_LOADED" and name == MFO.name then
    MFO:CopyDefaults()
    MFO:RequestItemData()
    MFO:CreateUI()
    MFO:RegisterAuctionatorUpdates()
    SLASH_MERCHANTSFAVOROPTIMIZER1 = "/mfo"
    SLASH_MERCHANTSFAVOROPTIMIZER2 = "/merchantsfavor"
    SlashCmdList.MERCHANTSFAVOROPTIMIZER = function()
      if MFO.frame:IsShown() then MFO.frame:Hide() else MFO.frame:Show() end
    end
    MFO:Print("Loaded. Type /mfo at the Auction House.")
  elseif event == "AUCTION_HOUSE_SHOW" then
    if MFO.frame then MFO.frame:Show() end
  elseif event == "AUCTION_HOUSE_CLOSED" then
    if MFO.CancelPendingPurchase then MFO:CancelPendingPurchase() end
    if MFO.frame then MFO.frame:Hide() end
  elseif event == "BAG_UPDATE_DELAYED" then
    if MFO.Refresh then MFO:Refresh(true) end
  elseif event == "GET_ITEM_INFO_RECEIVED" then
    if MFO.ResumePendingItemData then MFO:ResumePendingItemData(...) end
    if MFO.Refresh then MFO:Refresh(true) end
  elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    if MFO.OpenNativeWanted then MFO:OpenNativeWanted() end
  elseif event == "COMMODITY_PURCHASE_SUCCEEDED" or event == "COMMODITY_PURCHASE_FAILED" then
    if MFO.HandlePurchaseEvent then MFO:HandlePurchaseEvent(event, ...) end
  end
end)

local anchorTicker = 0
events:SetScript("OnUpdate", function(_, elapsed)
  anchorTicker = anchorTicker + elapsed
  if anchorTicker > 0.5 then
    anchorTicker = 0
    if MFO.frame and MFO.frame:IsShown() then MFO:AnchorFrame() end
  end
end)
