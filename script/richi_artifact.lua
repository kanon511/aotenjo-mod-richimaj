local mod_id = require("constant").mod_id
local richi_artifact_id = mod_id .. ":richi_artifact"
local artifact_applicable_decks = { "bamboo_deck" }

local furo = require("furo_material")

local funcs = {}

local create_richi_artifact_draw_tile_event_func = function(artifact)
    if funcs[artifact:GetRegName() .. "_draw_tile"] == nil then
        funcs[artifact:GetRegName() .. "_draw_tile"] = function(e)
            local is_trigger = tonumber(artifact:GetDataOrDefault("is_trigger", 0))
            if e.player:GetHandDeckCopy().Count >= e.player:GetHandLimit() - 1 then
                if is_trigger < 0 then
                    artifact:SetData("is_trigger", is_trigger + 1)
                elseif is_trigger == 0 then
                    artifact:SetData("is_trigger", 1)
                end
            end
            if is_trigger == 1 then
                local wind_direction = tonumber(artifact:GetDataOrDefault("wind_direction", 0))
                if tonumber(artifact:GetDataOrDefault("wind_direction", 0)) ~= e.player:GetPlayerWind() - 1 then
                    e.player:AddTileToDiscarded(CS.Aotenjo.Tile(e.tile))
                    e.tile:SetMaterial(furo:Copy(), e.player, true)
                end
                wind_direction = (wind_direction + 1) % 4
                artifact:SetData("wind_direction", wind_direction)
            end
        end
    end
end

local create_richi_artifact_add_kong_event_func = function(artifact)
    if funcs[artifact:GetRegName() .. "_add_kong"] == nil then
        funcs[artifact:GetRegName() .. "_add_kong"] = function(e)
            artifact:SetData("wind_direction", e.player:GetPlayerWind() - 1)
        end
    end
end

local get_player_artifact_from_id = function(player, id)
    local artifacts = player:GetArtifacts()
    for i = 0, artifacts.Count - 1 do
        if artifacts:GetRegName() == id then
            return artifacts
        end
    end
    return nil
end

local get_player_richi_artifact = function(player)
    get_player_artifact_from_id(player, richi_artifact_id)
end

-- 立直麻将遗物 (richi_artifact)
CS.Aotenjo.LuaArtifactBuilder.Create(richi_artifact_id, CS.Aotenjo.Rarity.COMMON)
    :WithDeckIn(artifact_applicable_decks)
    :WithName(function(player, loc, artifact)
        return "立直棒"
        -- return loc(string.format("artifact_%s_name", richi_artifact_id)) error?
    end)
    :WithDescription(function(player, loc, artifact)
        local wind_direction = artifact:GetDataOrDefault("wind_direction", 0)
        local wind_direction_str = loc(string.format("%s:wind_direction_%s", mod_id, wind_direction))
        return string.format(loc(string.format("artifact_%s_description", richi_artifact_id)), wind_direction_str)
    end)
    :ResetArtifactState(function(player, artifact)
        artifact:SetData("is_trigger", -2) -- 初始效果选择时会摸一次手牌，触发两次判定
        artifact:SetData("is_discarded_tile", 0)
        artifact:SetData("wind_direction", 0)
    end)
    :PreGameInitialized(function(player, artifact)
        player:ObtainArtifact(artifact)
    end)
    :OnBlockEffect(function(player, perm, block, e, artifact)
        if block:IsAAAA() then
            artifact:SetData("wind_direction", player:GetPlayerWind() - 1)
            return
        end
        local tiles = block.tiles
        for i = 0, tiles.Length - 1 do
            if player:DetermineMaterialCompatibility(tiles[i], furo) then
                artifact:SetData("wind_direction", player:GetPlayerWind() % 4)
                return
            end
        end
    end)
    :OnRoundEndEffect(function(player, perm, effects, artifact)
        artifact:SetData("is_trigger", 0)
        artifact:SetData("wind_direction", 0)
        artifact:SetData("is_discarded_tile", 0)
        local all_tiles = player:GetAllTiles()
        for i = 0, all_tiles.Count - 1 do
            local tile = all_tiles[i]
            if player:DetermineMaterialCompatibility(tile, furo) then
                player:RemoveTileFromPool(tile)
                player:RemoveTileFromHand(tile)
                player:RemoveTileFromDiscarded(tile)
            end
        end
    end)
    :OnDiscardTileEffect(function(player, tile, e, arg1, arg2, artifact)
        artifact:SetData("is_discarded_tile", 1)
        local wind_direction = artifact:GetDataOrDefault("wind_direction", 0)
        e:Add(CS.Aotenjo.TextEffect(string.format("%s:wind_direction_%s", mod_id, wind_direction), artifact))
    end)
    :OnObtain(function(player, artifact)
        player:SetArtifactLimit(player:GetArtifactLimit() + 1)
    end)
    :OnRemoved(function(player, artifact)
        player:SetArtifactLimit(player:GetArtifactLimit() - 1)
    end)
    :OnSubscribeToPlayer(function(player, artifact)
        create_richi_artifact_draw_tile_event_func(artifact)
        player:PostDrawTileEvent('+', funcs[artifact:GetRegName() .. "_draw_tile"])
        create_richi_artifact_add_kong_event_func(artifact)
        player:PreKongTileEvent('+', funcs[artifact:GetRegName() .. "_add_kong"])
    end)
    :OnUnsubscribeToPlayer(function(player, artifact)
        create_richi_artifact_draw_tile_event_func(artifact)
        player:PostDrawTileEvent('-', funcs[artifact:GetRegName() .. "_draw_tile"])
        create_richi_artifact_add_kong_event_func(artifact)
        player:PreKongTileEvent('-', funcs[artifact:GetRegName() .. "_add_kong"])
    end)
    :BuildAndRegister()

return {
    get_player_richi_artifact
}
