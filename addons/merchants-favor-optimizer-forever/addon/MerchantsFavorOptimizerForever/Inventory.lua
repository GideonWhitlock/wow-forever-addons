local _, MFO = ...

function MFO:GetOwned(itemID)
  local bags = 0
  local total = 0
  if GetItemCount then
    bags = GetItemCount(itemID, false) or 0
    total = GetItemCount(itemID, true) or bags
  end
  return bags, total
end

function MFO:OwnershipText(itemID, needed)
  local bags, total = self:GetOwned(itemID)
  if total >= needed and bags < needed then
    return string.format("%d/%d (in bank — withdraw first)", total, needed)
  end
  return string.format("%d/%d", total, needed)
end
