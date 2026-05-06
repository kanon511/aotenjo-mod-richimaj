local mod_id = require("constant").mod_id
local yaku_applicable_systems = { "bamboo" }

local furo = require("furo_material")
local richi_artifact_module = require("richi_artifact")

local is_menqing_block = function(player, block)
    local tiles = block.tiles
    for i = 0, tiles.Length - 1 do
        if player:DetermineMaterialCompatibility(tiles[i], furo) then
            return false
        end
    end
    return true
end

-- local is_menqing_jiang = function(player, perm)
--     return not (player:DetermineMaterialCompatibility(perm.jiang.tile1, furo) or
--         player:DetermineMaterialCompatibility(perm.jiang.tile2, furo))
-- end

local menqianqing_func = function(perm, player, max_furo_count)
    local blocks = perm.blocks
    local furo_count = 0
    for i = 0, blocks.Length - 1 do
        if i == blocks.Length - 1 then
            -- 最后面子判定不等于打出的面子
            --     local block_tiles = blocks[i].tiles
            --     for j = 0, block_tiles.Length - 1 do
            --         local block_tile = block_tiles[j]
            --         if player:DetermineMaterialCompatibility(block_tile, furo) then
            --             furo_count = furo_count + 1
            --             if furo_count > max_furo_count then
            --                 return false
            --             end
            --         end
            --     end
            if player:DetermineMaterialCompatibility(perm.jiang.tile1, furo) then
                furo_count = furo_count + 1
                if furo_count > max_furo_count then
                    return false
                end
            end
            if player:DetermineMaterialCompatibility(perm.jiang.tile2, furo) then
                furo_count = furo_count + 1
                if furo_count > max_furo_count then
                    return false
                end
            end
            -- return true
        end
        if blocks[i]:IsAAAA() then
            if not is_menqing_block(player, blocks[i]) then
                return false
            end
        else
            local block_tiles = blocks[i].tiles
            for j = 0, block_tiles.Length - 1 do
                local block_tile = block_tiles[j]
                if player:DetermineMaterialCompatibility(block_tile, furo) then
                    -- return false
                    furo_count = furo_count + 1
                    if furo_count > max_furo_count then
                        return false
                    end
                end
            end
        end
    end
    return true
end

local is_original_yaku = function(perm, player, yaku_name)
    return CS.Aotenjo.YakuTester.YAKUS_PREDICATE_MAP[CS.Aotenjo.YakuType.FromString(yaku_name)](perm, player)
end

local ankegang_func = function(perm, player, block_count, only_gang)
    local n_block_count = 0
    local blocks = perm.blocks
    for i = 0, blocks.Length - 1 do
        local block = blocks[i]
        if block:IsAAAA() or block:IsAAA() and not only_gang then
            if not is_menqing_block(player, block) then
                n_block_count = n_block_count - 1
            end
            n_block_count = n_block_count + 1
            if n_block_count >= block_count then
                return true
            end
        end
    end
    return false
end

local is_three_menqing_block_yaku = function(perm, player, judgment_func)
    local blocks = perm.blocks
    if blocks.Length < 3 then
        return false
    end
    for i = 0, blocks.Length - 1 do
        if is_menqing_block(player, blocks[i]) then
            for j = i + 1, blocks.Length - 1 do
                if is_menqing_block(player, blocks[j]) then
                    for k = j + 1, blocks.Length - 1 do
                        if is_menqing_block(player, blocks[k]) and judgment_func(blocks[i], blocks[j], blocks[k]) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- 自摸
-- 最后面子判定不等于打出的面子
-- CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
--     mod_id .. ":ZiMo",
--     2,
--     1,
--     1,
--     function(perm, player)
--         local block_tiles = perm:GetLastBlock().tiles
--         for i = 0, block_tiles.Length - 1 do
--             local block_tile = block_tiles[i]
--             if player:DetermineMaterialCompatibility(block_tile, furo) then
--                 return false
--             end
--         end
--         if player:DetermineMaterialCompatibility(perm.jiang.tile1, furo) or
--             player:DetermineMaterialCompatibility(perm.jiang.tile2, furo) then
--             return false
--         end
--         return true
--     end,
--     {},
--     yaku_applicable_systems,
--     { 0, 1, 2, 3 },
--     CS.Aotenjo.Rarity.COMMON,
--     "234m345m123p333s66s"
-- )

-- 门前清
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQianQing",
    24,
    4,
    3,
    function(perm, player)
        return menqianqing_func(perm, player, 1)
    end,
    {},
    yaku_applicable_systems,
    { 0, 1, 2, 3 },
    CS.Aotenjo.Rarity.RARE,
    "234m345m123p333s66s"
)

-- 门清自摸
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingZiMo",
    48,
    4,
    36,
    function(perm, player)
        return menqianqing_func(perm, player, 0)
    end,
    -- { mod_id .. ":MenQianQing", mod_id .. ":ZiMo" },
    { mod_id .. ":MenQianQing" },
    yaku_applicable_systems,
    { 0, 1, 2, 3 },
    CS.Aotenjo.Rarity.EPIC,
    "234m345m123p333s66s"
)

-- 门清平和
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingPingHu",
    48,
    4,
    36,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "PingHu")
    end,
    { mod_id .. ":MenQianQing", "PingHu" },
    yaku_applicable_systems,
    { 1 },
    CS.Aotenjo.Rarity.EPIC,
    "234m345m123p789s66s"
)

-- 门清混一色
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingHunYiSe",
    48,
    4,
    36,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "HunYiSe")
    end,
    { mod_id .. ":MenQianQing", "HunYiSe" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.EPIC,
    "234m345m777m444z66z"
)

-- 门清清一色
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingQingYiSe",
    88,
    4,
    68,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "QingYiSe")
    end,
    { mod_id .. ":MenQianQing", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QingYiSe" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.EPIC,
    "234m345m777m999m55m"
)

-- 门清一杯口
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingYiBeiKo",
    12,
    1,
    8,
    function(perm, player)
        local blocks = perm.blocks
        for i = 0, blocks.Length - 1 do
            for j = i + 1, blocks.Length - 1 do
                if blocks[i]:CompatWith(blocks[j]) and blocks[i]:IsABC() and is_menqing_block(player, blocks[i]) and is_menqing_block(player, blocks[j]) then
                    return true
                end
            end
        end
        return false
    end,
    { "YiBanGao" },
    yaku_applicable_systems,
    { 1 },
    CS.Aotenjo.Rarity.RARE,
    "345m345m"
)

-- 门清两杯口
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingLiangBeiKo",
    148,
    1,
    88,
    function(perm, player)
        local blocks = perm.blocks
        local is_yibeikou1 = false
        local is_yibeikou2 = false
        local block = nil
        for i = 1, blocks.Length - 1 do
            if blocks[i]:IsABC() and is_menqing_block(player, blocks[i]) then
                if blocks[0]:CompatWith(blocks[i]) and not is_yibeikou1 and is_menqing_block(player, blocks[0]) then
                    is_yibeikou1 = true
                else
                    if block == nil then
                        block = blocks[i]
                    else
                        if blocks[i]:CompatWith(block) and not is_yibeikou2 then
                            is_yibeikou2 = true
                        else
                            return false
                        end
                    end
                end
            end
        end
        if is_yibeikou1 and is_yibeikou2 then
            return true
        end
        return false
    end,
    { "YiBanGao", mod_id .. ":MenQingYiBeiKo", "LiangBanGao", "QiDui" },
    yaku_applicable_systems,
    { 1 },
    CS.Aotenjo.Rarity.LEGENDARY,
    "345m345m567s567s"
)

-- 门清混全带幺九
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingHunQuanDaiYaoJiu",
    68,
    4,
    48,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "QuanDaiYao")
    end,
    { mod_id .. ":MenQianQing", "QuanDaiYao" },
    yaku_applicable_systems,
    { 0 },
    CS.Aotenjo.Rarity.EPIC,
    "111m789m123p333z99s"
)

-- 门清纯全带幺九
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingChunQuanDaiYaoJiu",
    108,
    4,
    88,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "ChunQuanDaiYao")
    end,
    { mod_id .. ":MenQianQing", "QuanDaiYao", mod_id .. ":MenQingHunQuanDaiYaoJiu", "ChunQuanDaiYao" },
    yaku_applicable_systems,
    { 0 },
    CS.Aotenjo.Rarity.LEGENDARY,
    "111m789m123p789s99s"
)

-- 门清三色通贯
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingSanSeTongGuang",
    48,
    1,
    38,
    function(perm, player)
        return is_three_menqing_block_yaku(perm, player, function(i, j, k)
            local blocks = { i, j, k }
            local number_combination = { false, false, false }
            local categorys = { false, false, false }
            for _, block in ipairs(blocks) do
                if not block:IsABC() then
                    return false
                end
                local category = block:GetCategory()
                if category == CS.Aotenjo.Tile.Category.Wan then
                    categorys[1] = true
                elseif category == CS.Aotenjo.Tile.Category.Bing then
                    categorys[2] = true
                elseif category == CS.Aotenjo.Tile.Category.Suo then
                    categorys[3] = true
                end
                local numbers = { 0, 0, 0 }
                local tiles = block.tiles
                for m = 0, tiles.Length - 1 do
                    local order = tiles[m]:GetOrder()
                    local index = (order + 2) // 3
                    numbers[index] = numbers[index] + 1
                end
                for index, number in ipairs(numbers) do
                    if number == 3 then
                        number_combination[index] = true
                    end
                end
            end
            for _, number in ipairs(number_combination) do
                if not number then
                    return false
                end
            end
            for _, category in ipairs(categorys) do
                if not category then
                    return false
                end
            end
            return true
        end)
    end,
    { "HuaLong" },
    yaku_applicable_systems,
    { 1 },
    CS.Aotenjo.Rarity.EPIC,
    "123m789p456s"
)

-- 门清三色同顺
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingSanSeTongShun",
    58,
    1,
    48,
    function(perm, player)
        return is_three_menqing_block_yaku(perm, player, function(i, j, k)
            local blocks = { i, j, k }
            local block_number = 0
            local categorys = { false, false, false }
            for _, block in ipairs(blocks) do
                if not block:IsABC() then
                    return false
                end
                local category = block:GetCategory()
                if category == CS.Aotenjo.Tile.Category.Wan then
                    categorys[1] = true
                elseif category == CS.Aotenjo.Tile.Category.Bing then
                    categorys[2] = true
                elseif category == CS.Aotenjo.Tile.Category.Suo then
                    categorys[3] = true
                end
                local tiles = block.tiles
                local now_block_number = 0
                for m = 0, tiles.Length - 1 do
                    now_block_number = now_block_number + tiles[m]:GetOrder()
                end
                if block_number == 0 then
                    block_number = now_block_number
                elseif block_number ~= now_block_number then
                    return false
                end
            end
            for _, category in ipairs(categorys) do
                if not category then
                    return false
                end
            end
            return true
        end)
    end,
    { "SanSeSanTongShun" },
    yaku_applicable_systems,
    { 1 },
    CS.Aotenjo.Rarity.EPIC,
    "234m234p234s"
)

-- 门清一气通贯
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingYiQiTongGuang",
    68,
    1,
    48,
    function(perm, player)
        return is_three_menqing_block_yaku(perm, player, function(i, j, k)
            local blocks = { i, j, k }
            local number_combination = { false, false, false }
            local category = nil
            for _, block in ipairs(blocks) do
                if not block:IsABC() then
                    return false
                end
                local block_category = block:GetCategory()
                if category == nil then
                    category = block_category
                elseif category ~= block_category then
                    return false
                end
                local numbers = { 0, 0, 0 }
                local tiles = block.tiles
                for m = 0, tiles.Length - 1 do
                    local order = tiles[m]:GetOrder()
                    local index = (order + 2) // 3
                    numbers[index] = numbers[index] + 1
                end
                for index, number in ipairs(numbers) do
                    if number == 3 then
                        number_combination[index] = true
                    end
                end
            end
            for _, number in ipairs(number_combination) do
                if not number then
                    return false
                end
            end
            return true
        end)
    end,
    { "QingLong" },
    yaku_applicable_systems,
    { 1 },
    CS.Aotenjo.Rarity.EPIC,
    "123s456s789s"
)

-- 门清七对子
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingQiDuiZi",
    128,
    1,
    108,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "QiDui")
    end,
    { mod_id .. ":MenQianQing", "QiDui" },
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.LEGENDARY,
    "11m66m33p77p22s11z44z"
)

-- 门清国士无双
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingGuoShiWuShuang",
    588,
    1,
    688,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "ShiSanYao")
    end,
    { mod_id .. ":MenQianQing", "QuanDaiYao", mod_id .. ":MenQingHunQuanDaiYaoJiu", "ShiSanYao" },
    yaku_applicable_systems,
    { 0 },
    CS.Aotenjo.Rarity.ANCIENT,
    "19m19p19s123567z44z"
)

-- 门清九莲宝灯 不适配扩容麻将
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingJiuLianBaoDeng",
    588,
    1,
    388,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "JiuLianBaoDeng")
    end,
    { mod_id .. ":MenQianQing", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QingYiSe", mod_id .. ":MenQingQingYiSe",
        "JiuLianBaoDeng" },
    yaku_applicable_systems,
    { 1, 2 },
    CS.Aotenjo.Rarity.ANCIENT,
    "111m234m456m789m99m"
)

-- 门清小数邻
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingXiaoShuLin",
    488,
    1,
    428,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "XiaoShuLin")
    end,
    { mod_id .. ":MenQianQing", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QingYiSe", mod_id .. ":MenQingQingYiSe", "QiDui",
        mod_id .. ":MenQingQiDuiZi", "YiBanGao", mod_id .. ":MenQingYiBeiKo", "LiangBanGao", mod_id ..
    ":MenQingLiangBeiKo",
        "XiaoShuLin" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.ANCIENT,
    "11m22m33m44m55m66m77m"
)

-- 门清小车轮
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingXiaoCheLun",
    488,
    1,
    428,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "XiaoCheLun")
    end,
    { mod_id .. ":MenQianQing", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QingYiSe", mod_id .. ":MenQingQingYiSe", "QiDui",
        mod_id .. ":MenQingQiDuiZi", "YiBanGao", mod_id .. ":MenQingYiBeiKo", "LiangBanGao", mod_id ..
    ":MenQingLiangBeiKo",
        "XiaoCheLun" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.ANCIENT,
    "11p22p33p44p55p66p77p"
)

-- 门清小竹林
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingXiaoZhuLin",
    488,
    1,
    428,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "XiaoZhuLin")
    end,
    { mod_id .. ":MenQianQing", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QingYiSe", mod_id .. ":MenQingQingYiSe", "QiDui",
        mod_id .. ":MenQingQiDuiZi", "YiBanGao", mod_id .. ":MenQingYiBeiKo", "LiangBanGao", mod_id ..
    ":MenQingLiangBeiKo",
        "XiaoZhuLin" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.ANCIENT,
    "11s22s33s44s55s66s77s"
)

-- 门清大数邻
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingDaShuLin",
    588,
    1,
    488,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "DaShuLin")
    end,
    { mod_id .. ":MenQianQing", "DuanYao", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QingYiSe", mod_id ..
    ":MenQingQingYiSe",
        "QiDui", mod_id .. ":MenQingQiDuiZi", "YiBanGao", mod_id .. ":MenQingYiBeiKo", "LiangBanGao",
        mod_id .. ":MenQingLiangBeiKo", "DaShuLin" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.ANCIENT,
    "22m33m44m55m66m77m88m"
)

-- 门清大车轮
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingDaCheLun",
    588,
    1,
    488,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "DaCheLun")
    end,
    { mod_id .. ":MenQianQing", "DuanYao", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QingYiSe", mod_id ..
    ":MenQingQingYiSe",
        "QiDui", mod_id .. ":MenQingQiDuiZi", "YiBanGao", mod_id .. ":MenQingYiBeiKo", "LiangBanGao",
        mod_id .. ":MenQingLiangBeiKo", "DaCheLun" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.ANCIENT,
    "22p33p44p55p66p77p88p"
)

-- 门清大竹林
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingDaZhuLin",
    588,
    1,
    488,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "DaZhuLin")
    end,
    { mod_id .. ":MenQianQing", "DuanYao", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QingYiSe", mod_id ..
    ":MenQingQingYiSe",
        "QiDui", mod_id .. ":MenQingQiDuiZi", "YiBanGao", mod_id .. ":MenQingYiBeiKo", "LiangBanGao",
        mod_id .. ":MenQingLiangBeiKo", "DaZhuLin" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.ANCIENT,
    "22s33s44s55s66s77s88s"
)

-- 门清同七对
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":MenQingTongQiDui",
    1288,
    1,
    888,
    function(perm, player)
        return menqianqing_func(perm, player, 1) and is_original_yaku(perm, player, "QiTongDui")
    end,
    { mod_id .. ":MenQianQing", "HunYiSe", mod_id .. ":MenQingHunYiSe", "QiDui", mod_id .. ":MenQingQiDuiZi", "QiTongDui" },
    yaku_applicable_systems,
    { 2 },
    CS.Aotenjo.Rarity.ANCIENT,
    "22s22s22s22s22s22s22s"
)

-- 青天和 暂定不添加
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":QingTianHu",
    888,
    1,
    688,
    function(perm, player)
        richi_artifact_module.get_player_richi_artifact(player)
        return player:GetPlayerWind() == 1 and menqianqing_func(perm, player, 1) and false
    end,
    { mod_id .. ":MenQianQing", mod_id .. ":MenQingZiMo" },
    yaku_applicable_systems,
    { 0, 1, 2, 3 },
    CS.Aotenjo.Rarity.ANCIENT,
    "234m345m123p333s66s"
)

-- 暗刻
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":AnKe",
    4,
    1,
    2,
    function(perm, player)
        return ankegang_func(perm, player, 1, false)
    end,
    {},
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.COMMON,
    "333p"
)

-- 双暗刻
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":ShuangAnKe",
    18,
    1,
    12,
    function(perm, player)
        return ankegang_func(perm, player, 2, false)
    end,
    { "ShuangKe", mod_id .. ":AnKe" },
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.RARE,
    "333p666s"
)

-- 三暗刻
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":SanAnKe",
    48,
    1,
    38,
    function(perm, player)
        return ankegang_func(perm, player, 3, false)
    end,
    { "ShuangKe", mod_id .. ":AnKe", "SanKe", mod_id .. ":ShuangAnKe" },
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.EPIC,
    "333p222s666s"
)

-- 四暗刻
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":SiAnKe",
    128,
    1,
    88,
    function(perm, player)
        return ankegang_func(perm, player, 4, false)
    end,
    { "ShuangKe", mod_id .. ":AnKe", "SanKe", mod_id .. ":ShuangAnKe", "SiKe", mod_id .. ":SanAnKe" },
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.LEGENDARY,
    "111m333p222s666s"
)

-- 暗杠
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":AnGang",
    8,
    1,
    4,
    function(perm, player)
        return ankegang_func(perm, player, 1, true)
    end,
    { mod_id .. ":AnKe" },
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.COMMON,
    "3333p"
)

-- 双暗杠
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":ShuangAnGang",
    32,
    1,
    20,
    function(perm, player)
        return ankegang_func(perm, player, 2, true)
    end,
    { mod_id .. ":AnKe", mod_id .. ":AnGang", mod_id .. ":ShuangAnKe", "ShuangGang" },
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.RARE,
    "3333p6666s"
)

-- 三暗杠
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":SanAnGang",
    128,
    1,
    88,
    function(perm, player)
        return ankegang_func(perm, player, 3, true)
    end,
    { mod_id .. ":AnKe", mod_id .. ":AnGang", mod_id .. ":ShuangAnKe", "ShuangGang", mod_id .. ":ShuangAnGang",
        mod_id .. ":SanAnKe", "SanGang" },
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.LEGENDARY,
    "3333p2222s6666s"
)

-- 四暗杠
CS.Aotenjo.CustomYakuBuilder.RegisterCustomYaku(
    mod_id .. ":SiAnGang",
    688,
    1,
    488,
    function(perm, player)
        return ankegang_func(perm, player, 4, true)
    end,
    { mod_id .. ":AnKe", mod_id .. ":AnGang", mod_id .. ":ShuangAnKe", "ShuangGang", mod_id .. ":ShuangAnGang",
        mod_id .. ":SanAnKe", "SanGang", mod_id .. ":SanAnGang", mod_id .. ":SiAnKe", "SiGang" },
    yaku_applicable_systems,
    { 3 },
    CS.Aotenjo.Rarity.ANCIENT,
    "1111m3333p2222s6666s"
)
