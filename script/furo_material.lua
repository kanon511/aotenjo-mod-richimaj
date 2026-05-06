local mod_id = require("constant").mod_id

-- 副露牌 (furo)
return CS.Aotenjo.LuaTileMaterialBuilder.Create(mod_id .. ":furo")
    :WithRarity(CS.Aotenjo.Rarity.COMMON)
    :BuildAndRegister()
