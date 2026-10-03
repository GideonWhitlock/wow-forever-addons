-- Length-prefixed data codec. Never evaluates imported text or Lua.
local _,ns=...
local C=ns.Core
local function encode(v,depth)
    if depth>20 then error("Backup is nested too deeply.") end
    local t=type(v)
    if t=="nil" then return "z" end
    if t=="boolean" then return v and "t" or "f" end
    if t=="number" then if not C.Finite(v) then error("Invalid backup number.") end; v=tostring(v); return "n"..#v..":"..v end
    if t=="string" then return "s"..#v..":"..v end
    if t=="table" then
        local keys={}; for k in pairs(v) do if type(k)~="string" and type(k)~="number" then error("Invalid backup key.") end; keys[#keys+1]=k end
        table.sort(keys,function(a,b) return type(a)..tostring(a)<type(b)..tostring(b) end)
        local out={"m",tostring(#keys),":"}
        for _,k in ipairs(keys) do out[#out+1]=encode(k,depth+1); out[#out+1]=encode(v[k],depth+1) end
        return table.concat(out)
    end
    error("Unsupported backup value.")
end
function C.ExportAccount(db)
    local data={schema=C.SCHEMA,stories=db.stories,pacing=db.pacing,channel=db.channel,
        paused=db.paused,autoSourceReplies=db.autoSourceReplies,minimap=db.minimap,window=db.window,performance=db.performance,lastOpening=db.lastOpening}
    local ok,result=pcall(encode,data,0); if not ok then return nil,result end
    return "CAMPFIRE-BACKUP:1\n"..result
end
function C.ImportAccount(text)
    if type(text)~="string" or #text>2000000 or text:sub(1,18)~="CAMPFIRE-BACKUP:1\n" then return nil,"Expected a CAMPFIRE-BACKUP:1 export (at most 2 MB)." end
    local pos,nodes=19,0
    local function read(depth)
        nodes=nodes+1; if depth>20 or nodes>100000 then error("Backup is too complex.") end
        local tag=text:sub(pos,pos); pos=pos+1
        if tag=="z" then return nil elseif tag=="t" then return true elseif tag=="f" then return false end
        local first,last,length=text:find("^(%d+):",pos)
        if not first or #length>7 then error("Malformed length in backup.") end
        length=tonumber(length); pos=last+1
        if tag=="s" or tag=="n" then
            if pos+length-1>#text then error("Truncated backup.") end
            local v=text:sub(pos,pos+length-1); pos=pos+length
            if tag=="n" then v=tonumber(v); if not C.Finite(v) then error("Invalid number.") end end
            return v
        elseif tag=="m" then
            if length>10000 then error("Too many records.") end
            local result={}
            for _=1,length do
                local k=read(depth+1); if type(k)~="string" and type(k)~="number" then error("Invalid key.") end
                if result[k]~=nil then error("Duplicate key.") end
                result[k]=read(depth+1)
            end
            return result
        end
        error("Unknown data tag.")
    end
    local ok,value=pcall(read,0)
    if not ok then return nil,"Invalid backup: "..tostring(value) end
    if pos~=#text+1 or type(value)~="table" or value.schema~=C.SCHEMA or not C.Pace(value.pacing) or type(value.stories)~="table" then return nil,"Unsupported or invalid backup." end
    local count=0
    for id,s in pairs(value.stories) do
        count=count+1
        if count>500 or type(id)~="string" or not id:match("^personal_[%w_%-]+$") or not C.ValidateStory(s) then return nil,"Backup contains an invalid personal story." end
    end
    return value
end
function C.Engine:RestoreAccount(text)
    local data,err=C.ImportAccount(text); if not data then return nil,err end
    local remap={}
    for id,s in pairs(data.stories) do local newID=self:SaveStory(s); remap[id]=newID end
    self.db.recovery.beforeRestore={pacing=C.Copy(self.db.pacing),performance=C.Copy(self.db.performance),minimap=C.Copy(self.db.minimap)}
    if type(data.autoSourceReplies)=="boolean" then self.db.autoSourceReplies=data.autoSourceReplies end
    self:SetPacing(data.pacing); self:SetChannel(data.channel=="PARTY" and "PARTY" or "SAY")
    self.db.paused=true
    if type(data.window)=="table" and C.Finite(data.window.x) and C.Finite(data.window.y)
        and math.abs(data.window.x)<=10000 and math.abs(data.window.y)<=10000 then self.db.window=C.Copy(data.window) end
    if type(data.minimap)=="table" then
        self.db.minimap.hidden=data.minimap.hidden==true
        if C.Finite(data.minimap.angle) then self.db.minimap.angle=data.minimap.angle%360 end
    end
    local p=data.performance
    if type(p)=="table" and C.ValidateStory(p.story) and type(p.opening)=="table"
        and C.Text(p.opening.emote) and C.Text("[Action] "..p.opening.emote) and C.Text(p.opening.intro)
        and C.Finite(p.step) and p.step==math.floor(p.step) and p.step>=1 and p.step<=#p.story.lines+3 then
        p.story.id=remap[p.story.id] or p.story.id
        self.db.performance=C.Copy(p); self.serial=self.serial+1; self.pending=nil
    end
    self:Preview(); return true,"Backup merged. Sending is paused; check the preview before resuming."
end
