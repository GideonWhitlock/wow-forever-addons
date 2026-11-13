local addonName, MFO = ...

MFO.name = addonName
MFO.label = "Merchant's Favor Optimizer: Forever"
MFO.callerID = addonName
MFO.defaults = { mode = "all", staleMinutes = 60, materialChangePercent = 10 }

function MFO:CopyDefaults()
  MerchantsFavorOptimizerForeverDB = MerchantsFavorOptimizerForeverDB or {}
  for key, value in pairs(self.defaults) do
    if MerchantsFavorOptimizerForeverDB[key] == nil then
      MerchantsFavorOptimizerForeverDB[key] = value
    end
  end
  self.db = MerchantsFavorOptimizerForeverDB
end

function MFO:Money(copper)
  if not copper then return "no price" end
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = copper % 100
  if g > 0 then return string.format("%dg %ds %dc", g, s, c) end
  if s > 0 then return string.format("%ds %dc", s, c) end
  return string.format("%dc", c)
end

function MFO:ItemName(itemID)
  local name
  if C_Item and C_Item.GetItemNameByID then name = C_Item.GetItemNameByID(itemID) end
  if not name and GetItemInfo then name = GetItemInfo(itemID) end
  return name or ("item:" .. tostring(itemID))
end

function MFO:RequestItemData()
  if not C_Item or not C_Item.RequestLoadItemDataByID then return end
  local requested = {}
  for _, crate in ipairs(self.CRATES or {}) do
    if not requested[crate.id] then
      C_Item.RequestLoadItemDataByID(crate.id)
      requested[crate.id] = true
    end
    for _, bundle in ipairs(crate.bundles or {}) do
      local itemID = bundle[1]
      if not requested[itemID] then
        C_Item.RequestLoadItemDataByID(itemID)
        requested[itemID] = true
      end
    end
  end
end

function MFO:Print(message)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cffd6a84bMerchant's Favor Optimizer:|r " .. tostring(message))
  end
end

function MFO:EvaluateCrate(crate, mode)
  if not crate.favor then
    return { crate = crate, excluded = true, reason = "Artisan Favor reward not yet verified" }
  end
  local cratePrice = self:GetPrice(crate.id)
  local crateBags, crateTotal = self:GetOwned(crate.id)
  local best
  for _, bundle in ipairs(crate.bundles) do
    local itemID, needed = bundle[1], bundle[2]
    local price = self:GetPrice(itemID)
    local bags, total = self:GetOwned(itemID)
    if price then
      local candidate = {
        itemID = itemID, needed = needed, unitPrice = price,
        bags = bags, total = total, fullCost = price * needed,
        missing = math.max(0, needed - total),
      }
      candidate.missingCost = candidate.missing * price
      local choose = false
      if not best then
        choose = true
      elseif mode == "materials" then
        choose = candidate.missingCost < best.missingCost
      elseif mode == "crate" then
        local candidateComplete = candidate.total >= candidate.needed
        local bestComplete = best.total >= best.needed
        choose = (candidateComplete and not bestComplete) or
          (candidateComplete == bestComplete and candidate.fullCost < best.fullCost)
      else
        choose = candidate.fullCost < best.fullCost
      end
      if choose then best = candidate end
    end
  end
  if not best then return { crate = crate, reason = "Auctionator price missing" } end

  local eligible = true
  local grossCost
  if mode == "materials" then
    eligible = crateTotal > 0
    grossCost = best.missingCost
  elseif mode == "crate" then
    eligible = best.total >= best.needed and crateTotal == 0
    grossCost = cratePrice
  else
    grossCost = (cratePrice or 0) + best.fullCost
    eligible = cratePrice ~= nil
  end
  if not eligible or grossCost == nil then return nil end
  local totalCost = grossCost - (crate.coin or 0)
  return {
    crate = crate, bundle = best, cratePrice = cratePrice,
    crateBags = crateBags, crateTotal = crateTotal,
    grossCost = grossCost, coinReward = crate.coin or 0,
    totalCost = totalCost, costPerFavor = totalCost / crate.favor,
  }
end

function MFO:Rank(mode)
  local results, excluded = {}, {}
  for _, crate in ipairs(self.CRATES) do
    local result = self:EvaluateCrate(crate, mode or self.db.mode)
    if result then
      if result.costPerFavor then table.insert(results, result)
      elseif result.excluded then table.insert(excluded, result) end
    end
  end
  table.sort(results, function(a, b)
    if a.costPerFavor == b.costPerFavor then return a.totalCost < b.totalCost end
    return a.costPerFavor < b.costPerFavor
  end)
  return results, excluded
end

function MFO:BuildQueue(result, mode)
  if not result then return {} end
  local queue = {}
  mode = mode or self.db.mode
  if (mode == "all" or mode == "crate") and result.crateTotal == 0 then
    table.insert(queue, { itemID = result.crate.id, count = 1, kind = "crate" })
  end
  if mode == "all" or mode == "materials" then
    local missing = result.bundle.missing
    if missing > 0 then
      table.insert(queue, { itemID = result.bundle.itemID, count = missing, kind = "materials" })
    end
  end
  return queue
end
