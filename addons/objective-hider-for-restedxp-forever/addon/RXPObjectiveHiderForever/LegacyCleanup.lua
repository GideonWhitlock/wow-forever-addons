local _, addon = ...

-- Recovery for the short-lived 0.1.1 test build only. This never creates a frame,
-- registers a key, or touches the player's normal binding table. It can only
-- release input state owned by this add-on's exact legacy global frame names.
function addon.ReleaseLegacyInput()
    local owner = _G.RXPObjectiveHiderForeverBindingOwner
    if owner and type(_G.ClearOverrideBindings) == "function" then
        pcall(_G.ClearOverrideBindings, owner)
    end
    if owner and type(owner.ClearBindings) == "function" then
        pcall(owner.ClearBindings, owner)
    end

    local panel = _G.RXPObjectiveHiderForeverSettingsPanel
    if panel then
        panel.capturingKey = nil
        if type(panel.EnableKeyboard) == "function" then pcall(panel.EnableKeyboard, panel, false) end
        if type(panel.SetPropagateKeyboardInput) == "function" then
            pcall(panel.SetPropagateKeyboardInput, panel, true)
        end
        if type(panel.SetScript) == "function" then
            pcall(panel.SetScript, panel, "OnKeyDown", nil)
            pcall(panel.SetScript, panel, "OnKeyUp", nil)
        end
    end

    local getFocus = _G.GetCurrentKeyBoardFocus
    if type(getFocus) == "function" then
        local ok, focus = pcall(getFocus)
        if ok and focus and type(focus.GetName) == "function" and type(focus.ClearFocus) == "function" then
            local nameOK, name = pcall(focus.GetName, focus)
            if nameOK and type(name) == "string" and
                    name:find("RXPObjectiveHiderForever", 1, true) == 1 then
                pcall(focus.ClearFocus, focus)
            end
        end
    end
end

addon.ReleaseLegacyInput()
