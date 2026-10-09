local _, EGF = ...

-- Controls are intentionally registered here only after their CVar name,
-- accepted values and visible effect have been verified in WoW: Forever.
-- Video examples supplied by the owner will be translated into entries in
-- this catalogue and tested individually.

EGF.CATALOG_STATUS = "22 graphics controls loaded. Your original values are captured before the first change."

-- Entry shape:
-- EGF.RegisterSetting({
--     id = "stable-short-id",
--     cvar = "exactConsoleVariable",
--     kind = "slider", -- or "toggle"
--     label = "Player-facing label",
--     description = "What changes, including important performance cost.",
--     category = "Environment",
--     min = 0,
--     max = 10,
--     step = 1,
--     reload = false,
-- })

EGF.RegisterSetting({
    id = "ground-density",
    cvar = "groundEffectDensity",
    kind = "slider",
    label = "Ground detail density",
    description = "Controls how many grass, flower, pebble and similar ground-detail sprites are drawn. Higher values can reduce performance, especially with a long draw distance.",
    category = "Ground detail",
    min = 16,
    max = 256,
    step = 1,
})

EGF.RegisterSetting({
    id = "ground-distance",
    cvar = "groundEffectDist",
    kind = "slider",
    label = "Ground detail distance",
    description = "Controls how far from the character ground-detail sprites remain visible. Values beyond the normal options range increase GPU and CPU work.",
    category = "Ground detail",
    min = 40,
    max = 500,
    step = 5,
})

EGF.RegisterSetting({
    id = "ground-fade",
    cvar = "groundEffectFade",
    kind = "slider",
    label = "Ground detail fade distance",
    description = "Controls the foliage fade transition. Raising it reduces the obvious ring where distant ground detail fades or appears.",
    category = "Ground detail",
    min = 40,
    max = 500,
    step = 5,
})

EGF.RegisterPreset({
    id = "enhanced-ground",
    label = "Enhanced ground detail",
    description = "Density 256, distance 500, fade 370",
    values = {
        ["ground-density"] = 256,
        ["ground-distance"] = 500,
        ["ground-fade"] = 370,
    },
    showButton = false,
})

EGF.RegisterSetting({
    id = "object-fade-scale",
    cvar = "lodObjectFadeScale",
    kind = "slider",
    label = "Object detail fade scale",
    description = "Keeps detailed world objects visible farther away. WoW's Environment Detail setting may overwrite this value. Higher values cost performance.",
    category = "Distant world detail",
    min = 50,
    max = 300,
    step = 5,
})

EGF.RegisterSetting({
    id = "object-cull-size",
    cvar = "lodObjectCullSize",
    kind = "slider",
    label = "Small-object culling size",
    description = "Controls how small a distant object can become before it is hidden. Lower values retain more tiny props and therefore cost more performance.",
    category = "Distant world detail",
    min = 1,
    max = 30,
    step = 1,
})

EGF.RegisterSetting({
    id = "doodad-detail-scale",
    cvar = "doodadLodScale",
    kind = "slider",
    label = "World decoration detail scale",
    description = "Extends detail for trees, lamps, fences and other world decorations. Higher values can increase CPU, GPU and memory use.",
    category = "Distant world detail",
    min = 50,
    max = 300,
    step = 5,
})

EGF.RegisterSetting({
    id = "building-detail-distance",
    cvar = "wmoLodDist",
    kind = "slider",
    label = "Building detail distance",
    description = "Controls detailed rendering distance for large world structures. WoW may replace it when Environment Detail changes.",
    category = "Distant world detail",
    min = 100,
    max = 1000,
    step = 10,
})

EGF.RegisterSetting({
    id = "terrain-detail-distance",
    cvar = "terrainLodDist",
    kind = "slider",
    label = "Terrain detail distance",
    description = "Controls how far detailed terrain geometry remains visible. Higher values can substantially increase world-rendering cost.",
    category = "Distant world detail",
    min = 100,
    max = 1000,
    step = 10,
})

EGF.RegisterSetting({
    id = "horizon-start",
    cvar = "horizonStart",
    kind = "slider",
    label = "Horizon fog start",
    description = "Moves the point where distant horizon fog begins. The normal View Distance setting can overwrite it; extreme values may reveal unfinished distant scenery.",
    category = "Fog and horizon",
    min = 400,
    max = 4000,
    step = 100,
})

EGF.RegisterSetting({
    id = "always-sharpen",
    cvar = "ResampleAlwaysSharpen",
    kind = "toggle",
    label = "Always apply contrast-adaptive sharpening",
    description = "Enables the client's sharpening pass outside its usual resampling path. Results depend on render scale and resample settings and may produce shimmer or flicker.",
    category = "Sharpening and resolution",
    onApply = function(enabled)
        if enabled and EGF.settingsByID["render-scale"] then
            EGF.SetValue(EGF.settingsByID["render-scale"], 98)
        end
    end,
})

EGF.RegisterSetting({
    id = "render-scale",
    cvar = "RenderScale",
    kind = "slider",
    label = "3D render scale",
    description = "Controls internal 3D resolution. Enabling always-on sharpening moves this to 98%, which activates the sharpening/resampling path with a small resolution reduction.",
    category = "Sharpening and resolution",
    min = 50,
    max = 100,
    step = 1,
    format = "%d",
    fromRaw = function(raw) return (tonumber(raw) or 1) * 100 end,
    toRaw = function(value) return string.format("%.2f", value / 100) end,
})

EGF.RegisterSetting({
    id = "dynamic-render-minimum",
    cvar = "DynamicRenderScaleMin",
    kind = "slider",
    label = "Minimum dynamic render scale",
    description = "Sets the lowest resolution scale Dynamic Resolution may use while chasing the target frame rate. 1.00 prevents it dropping below native resolution.",
    category = "Sharpening and resolution",
    min = 0.5,
    max = 1,
    step = 0.05,
    format = "%.2f",
})

EGF.RegisterSetting({
    id = "ssao-method",
    cvar = "ssaoType",
    kind = "slider",
    label = "Ambient-occlusion method",
    description = "Selects method 0 or 1 for screen-space ambient occlusion. The appearance and performance difference depends on resolution and the standard SSAO quality setting.",
    category = "Advanced ambient occlusion",
    min = 0,
    max = 1,
    step = 1,
})

EGF.RegisterSetting({
    id = "ao-horizon-threshold",
    cvar = "assaoHorizonAngleThresh",
    kind = "slider",
    label = "AO horizon-angle threshold",
    description = "Advanced ambient-occlusion edge control. Small adjustments can alter halos and contact shading; use Restore if the result looks wrong.",
    category = "Advanced ambient occlusion",
    min = 0,
    max = 1,
    step = 0.05,
    format = "%.2f",
})

EGF.RegisterSetting({
    id = "ao-detail-strength",
    cvar = "assaoDetailShadowStrength",
    kind = "slider",
    label = "AO detail-shadow strength",
    description = "Controls very fine ambient-occlusion contact shading. High values exaggerate creases and may produce an unnatural image.",
    category = "Advanced ambient occlusion",
    min = 0,
    max = 5000,
    step = 100,
})

EGF.RegisterSetting({
    id = "ao-blur-passes",
    cvar = "assaoBlurPassCount",
    kind = "slider",
    label = "AO blur passes",
    description = "Controls ambient-occlusion filtering. One pass is sharper but noisier; more passes are smoother and may cost additional performance.",
    category = "Advanced ambient occlusion",
    min = 1,
    max = 4,
    step = 1,
})

EGF.RegisterSetting({
    id = "hdr-output",
    cvar = "HDROutput",
    kind = "toggle",
    label = "Native HDR output",
    description = "Only enable this with a correctly configured HDR display and operating system. Unsupported setups can become dark or show incorrect colours.",
    category = "HDR display",
})

EGF.RegisterSetting({
    id = "hdr-factor",
    cvar = "HDRFactor",
    kind = "slider",
    label = "HDR intensity factor",
    description = "Adjusts native HDR presentation. This is display-specific; begin at 1.00 and use Restore if colours or brightness become incorrect.",
    category = "HDR display",
    min = 1,
    max = 2,
    step = 0.05,
    format = "%.2f",
})

EGF.RegisterSetting({
    id = "shadow-cascades",
    cvar = "shadowNumCascades",
    kind = "slider",
    label = "Shadow cascade count",
    description = "Controls distant shadow coverage. Restricted to 1-4 because a zero-cascade experiment was reported to crash a Forever beta build. Shadow Quality may overwrite it.",
    category = "Shadows",
    min = 1,
    max = 4,
    step = 1,
})

EGF.RegisterSetting({
    id = "camera-zoom",
    cvar = "cameraDistanceMaxZoomFactor",
    kind = "slider",
    label = "Maximum camera zoom",
    description = "Changes how far the third-person camera can zoom out. Very large distances can reduce immersion and expose scenery not intended for close inspection.",
    category = "Camera",
    min = 1,
    max = 4,
    step = 0.1,
    format = "%.1f",
})

EGF.RegisterSetting({
    id = "weather-density",
    cvar = "weatherDensity",
    kind = "slider",
    label = "Weather effect density",
    description = "Controls rain, snow and similar atmospheric effect intensity from 0 to 3. WoW's Particle Density setting may overwrite it.",
    category = "Environment",
    min = 0,
    max = 3,
    step = 1,
})

EGF.RegisterSetting({
    id = "reflection-mode",
    cvar = "reflectionMode",
    kind = "slider",
    label = "Reflection detail mode",
    description = "Controls reflected scene detail from 0 (off) to 3 (maximum). Higher modes can add characters, spells and world objects to reflective surfaces at a performance cost.",
    category = "Reflections",
    min = 0,
    max = 3,
    step = 1,
})

EGF.RegisterPreset({
    id = "potato",
    label = "Potato",
    description = "Maximum performance for very limited or older hardware. HDR and camera preferences are left untouched.",
    values = {
        ["ground-density"] = 16, ["ground-distance"] = 40, ["ground-fade"] = 40,
        ["object-fade-scale"] = 50, ["object-cull-size"] = 30,
        ["doodad-detail-scale"] = 50, ["building-detail-distance"] = 100,
        ["terrain-detail-distance"] = 100, ["horizon-start"] = 400,
        ["always-sharpen"] = false, ["render-scale"] = 70,
        ["dynamic-render-minimum"] = 0.5, ["ssao-method"] = 0,
        ["ao-horizon-threshold"] = 0.5, ["ao-detail-strength"] = 0,
        ["ao-blur-passes"] = 1, ["shadow-cascades"] = 1,
        ["weather-density"] = 0, ["reflection-mode"] = 0,
    },
})

EGF.RegisterPreset({
    id = "low",
    label = "Low",
    description = "Performance-first settings with modest world detail. HDR and camera preferences are left untouched.",
    values = {
        ["ground-density"] = 32, ["ground-distance"] = 120, ["ground-fade"] = 70,
        ["object-fade-scale"] = 75, ["object-cull-size"] = 24,
        ["doodad-detail-scale"] = 75, ["building-detail-distance"] = 200,
        ["terrain-detail-distance"] = 300, ["horizon-start"] = 1200,
        ["always-sharpen"] = false, ["render-scale"] = 80,
        ["dynamic-render-minimum"] = 0.6, ["ssao-method"] = 0,
        ["ao-horizon-threshold"] = 0.5, ["ao-detail-strength"] = 1000,
        ["ao-blur-passes"] = 2, ["shadow-cascades"] = 2,
        ["weather-density"] = 1, ["reflection-mode"] = 1,
    },
})

EGF.RegisterPreset({
    id = "medium",
    label = "Medium",
    description = "Balanced image quality and performance for mainstream hardware. HDR and camera preferences are left untouched.",
    values = {
        ["ground-density"] = 48, ["ground-distance"] = 200, ["ground-fade"] = 70,
        ["object-fade-scale"] = 100, ["object-cull-size"] = 16,
        ["doodad-detail-scale"] = 100, ["building-detail-distance"] = 300,
        ["terrain-detail-distance"] = 500, ["horizon-start"] = 2000,
        ["always-sharpen"] = false, ["render-scale"] = 100,
        ["dynamic-render-minimum"] = 0.75, ["ssao-method"] = 0,
        ["ao-horizon-threshold"] = 0.5, ["ao-detail-strength"] = 2000,
        ["ao-blur-passes"] = 2, ["shadow-cascades"] = 3,
        ["weather-density"] = 2, ["reflection-mode"] = 2,
    },
})

EGF.RegisterPreset({
    id = "high",
    label = "High",
    description = "High fidelity for strong gaming hardware without applying every engine maximum. HDR and camera preferences are left untouched.",
    values = {
        ["ground-density"] = 128, ["ground-distance"] = 320, ["ground-fade"] = 320,
        ["object-fade-scale"] = 150, ["object-cull-size"] = 12,
        ["doodad-detail-scale"] = 150, ["building-detail-distance"] = 400,
        ["terrain-detail-distance"] = 650, ["horizon-start"] = 3500,
        ["always-sharpen"] = true, ["render-scale"] = 98,
        ["dynamic-render-minimum"] = 0.85, ["ssao-method"] = 1,
        ["ao-horizon-threshold"] = 0.5, ["ao-detail-strength"] = 3500,
        ["ao-blur-passes"] = 3, ["shadow-cascades"] = 4,
        ["weather-density"] = 3, ["reflection-mode"] = 2,
    },
})

EGF.RegisterPreset({
    id = "ufo",
    label = "UFO",
    description = "Maximum visual-fidelity targets for extremely powerful hardware. HDR and camera preferences are still left untouched.",
    values = {
        ["ground-density"] = 256, ["ground-distance"] = 500, ["ground-fade"] = 370,
        ["object-fade-scale"] = 200, ["object-cull-size"] = 8,
        ["doodad-detail-scale"] = 200, ["building-detail-distance"] = 600,
        ["terrain-detail-distance"] = 1000, ["horizon-start"] = 4000,
        ["always-sharpen"] = true, ["render-scale"] = 98,
        ["dynamic-render-minimum"] = 1, ["ssao-method"] = 1,
        ["ao-horizon-threshold"] = 0.5, ["ao-detail-strength"] = 5000,
        ["ao-blur-passes"] = 4, ["shadow-cascades"] = 4,
        ["weather-density"] = 3, ["reflection-mode"] = 3,
    },
})

EGF.RegisterPreset({
    id = "standard-ground",
    label = "Return ground detail to normal",
    description = "Density 48, distance 320, fade 70",
    values = {
        ["ground-density"] = 48,
        ["ground-distance"] = 320,
        ["ground-fade"] = 70,
    },
    showButton = false,
})
