local _, MFO = ...

-- One alternative bundle fills one crate. Favor values for Apprentice,
-- Journeyman and Expert are verified from current Forever player guides.
-- Artisan rewards are deliberately nil until independently verified.
local favor = {
  Apprentice = { raw = 5, crafted = 10 },
  Journeyman = { raw = 10, crafted = 20 },
  Expert = { raw = 15, crafted = 30 },
  Artisan = { raw = nil, crafted = nil },
}

local coin = {
  Apprentice = { raw = 250, crafted = 500 },
  Journeyman = { raw = 500, crafted = 1000 },
  Expert = { raw = 750, crafted = 1500 },
  Artisan = { raw = nil, crafted = nil },
}

local function crate(id, name, tier, kind, bundles)
  return { id = id, name = name, tier = tier, kind = kind,
    favor = favor[tier][kind], coin = coin[tier][kind], bundles = bundles }
end

MFO.CRATES = {
  crate(248682, "Apprentice Herbs", "Apprentice", "raw", {{2447,20},{765,20},{2449,10},{785,10},{2450,10}}),
  crate(248683, "Apprentice Ore", "Apprentice", "raw", {{2770,20},{2771,20}}),
  crate(248684, "Apprentice Textiles", "Apprentice", "raw", {{2589,40},{2318,20}}),
  crate(248685, "Apprentice Curiosities", "Apprentice", "raw", {{10940,20},{10939,4},{10978,6},{11084,2}}),
  crate(248686, "Journeyman Herbs", "Journeyman", "raw", {{3820,10},{2453,10},{3355,10},{3369,10},{3356,10}}),
  crate(248687, "Journeyman Ore", "Journeyman", "raw", {{2775,10},{2772,20}}),
  crate(248688, "Journeyman Textiles", "Journeyman", "raw", {{2592,20},{4306,40},{2319,20}}),
  crate(248689, "Journeyman Curiosities", "Journeyman", "raw", {{11083,20},{11082,4},{11138,6},{11139,2}}),
  crate(248690, "Earthly Expert Herbs", "Expert", "raw", {{3357,20},{3818,10},{3821,10},{3358,10}}),
  crate(248691, "Flowering Expert Herbs", "Expert", "raw", {{3819,10},{4625,10},{8831,20},{8836,10}}),
  crate(248692, "Expert Ore", "Expert", "raw", {{2776,10},{3858,20}}),
  crate(248693, "Expert Textiles", "Expert", "raw", {{4338,40},{4234,20}}),
  crate(248694, "Expert Curiosities", "Expert", "raw", {{11137,20},{11135,4},{11177,6},{11178,2}}),
  crate(248695, "Earthly Artisan Herbs", "Artisan", "raw", {{13464,10},{8838,20},{8839,10},{8845,10},{8846,10}}),
  crate(248696, "Flowering Artisan Herbs", "Artisan", "raw", {{13463,20},{13465,20},{13466,20},{13467,20}}),
  crate(248697, "Artisan Ore", "Artisan", "raw", {{7911,10},{10620,20},{11370,20}}),
  crate(248698, "Artisan Textiles", "Artisan", "raw", {{14047,40},{4304,20},{8170,20}}),
  crate(248699, "Artisan Curiosities", "Artisan", "raw", {{11176,20},{11175,4},{14343,6},{14344,2}}),
  crate(248702, "Apprentice Fabrics", "Apprentice", "crafted", {{4231,2},{2996,20}}),
  crate(248703, "Apprentice Ingots", "Apprentice", "crafted", {{2840,20},{3576,20},{2841,10}}),
  crate(248704, "Apprentice Parts", "Apprentice", "crafted", {{4359,16},{4361,16},{4363,4}}),
  crate(248705, "Journeyman Fabrics", "Journeyman", "crafted", {{2997,6},{4305,10},{4233,2}}),
  crate(248706, "Journeyman Ingots", "Journeyman", "crafted", {{2842,10},{3575,20}}),
  crate(248707, "Journeyman Parts", "Journeyman", "crafted", {{4371,8},{4375,7},{4382,4},{10558,45}}),
  crate(248708, "Expert Fabrics", "Expert", "crafted", {{4339,8},{4236,2}}),
  crate(248709, "Expert Ingots", "Expert", "crafted", {{3860,20},{3859,15},{3577,10}}),
  crate(248710, "Expert Parts", "Expert", "crafted", {{4387,8},{10559,5},{10560,12},{10561,5}}),
  crate(248711, "Artisan Fabrics", "Artisan", "crafted", {{14048,8},{8172,2}}),
  crate(248712, "Artisan Ingots", "Artisan", "crafted", {{11371,2},{6037,10},{12359,20}}),
  crate(248713, "Artisan Parts", "Artisan", "crafted", {{15994,5},{18631,5},{16000,2}}),
}
