local baronLava = { --Lava holes position WZ4
    Position(33644, 32299, 15),
    Position(33652, 32299, 15),
    Position(33644, 32307, 15),
    Position(33652, 32307, 15)
}
local countMachines = { --Pipes positions WZ5
    [1] = {
        Position(33672, 32331, 15),
        Position(33673, 32331, 15),
        Position(33674, 32331, 15),
        Position(33675, 32331, 15)
    },
    [2] = {
        Position(33676, 32339, 15),
        Position(33677, 32339, 15),
        Position(33678, 32339, 15),
        Position(33679, 32339, 15)
    },
    [3] = {
        Position(33680, 32330, 15),
        Position(33681, 32330, 15),
        Position(33682, 32330, 15),
        Position(33683, 32330, 15)
    },
    [4] = {
        Position(33684, 32339, 15),
        Position(33685, 32339, 15),
        Position(33686, 32339, 15),
        Position(33687, 32339, 15)
    },
    [5] = {
        Position(33688, 32332, 15),
        Position(33689, 32332, 15),
        Position(33690, 32332, 15),
        Position(33691, 32332, 15)
    }
}

local function countMachinesMechanic(center, x, y)
    local toPick = math.random(1, 5)
    local thing = countMachines[toPick]
    local boss = false

    local spectators = Game.getSpectators(center, false, true, x, x, y, y)

    if not thing or #spectators < 1 then
        return true
    end

    for i = 1, #thing do
        local item = Tile(thing[i]):getItemById(31724)
        if item then
            item:transform(31723)
        end
    end

    local blocked = nil
    addEvent(function()
        local fromPosition, toPosition = nil, nil
        if toPick % 2 == 0 then
            fromPosition, toPosition = Position(thing[1].x, thing[1].y - 1, thing[1].z), Position(thing[4].x, thing[4].y - 10, thing[4].z)
        else
            fromPosition, toPosition = Position(thing[1].x, thing[1].y + 1, thing[1].z), Position(thing[4].x, thing[4].y + 10, thing[4].z)
        end
        if fromPosition and toPosition then
            for x = fromPosition.x, toPosition.x do
                for y = fromPosition.y, toPosition.y, toPick % 2 == 0 and -1 or 1 do
                    local tile = Tile(Position(x, y, 15))
                    local mwCheck = Tile(Position(x, y, 15)):getItemById(1497)
                    if tile then
                        if mwCheck then
                            blocked = x
                        end
                        if x ~= blocked then
                            local posEffect = tile:getPosition()
                            if tile:isWalkable(false, false, false, true, false) then
                                posEffect:sendMagicEffect(CONST_ME_EXPLOSIONHIT)
                                local creature = tile:getTopCreature()
                                if creature then
                                    if creature:isPlayer() then
                                        doTargetCombatHealth(0, creature, COMBAT_FIREDAMAGE, -1500, -1500)
                                    elseif creature:isMonster() and creature:getName():lower() == 'the count of the core' then
                                        creature:addHealth(7000)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            for i = 1, #thing do
                local charged = Tile(thing[i]):getItemById(31723)
                if charged then
                    charged:transform(31724)
                end
            end
        end
    end, 8*1000)
    addEvent(countMachinesMechanic, 15 * 1000, center, x, y, bossName)
    return true
end

local lavaHoleUe = Combat()
lavaHoleUe:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITBYFIRE)
lavaHoleUe:setArea(createCombatArea(AREA_CIRCLE5X5))

function onTargetTile(cid, pos)
	local tile = Tile(pos)
    local creature = tile:getTopCreature()
	if tile then
		if creature then
            if creature:isPlayer() then
                doTargetCombatHealth(0, creature, COMBAT_FIREDAMAGE, -1500, -2000)
            end
		end
	end
    return true
end
setCombatCallback(lavaHoleUe, CALLBACK_PARAM_TARGETTILE, "onTargetTile")

local function wz4Lavas(center, x, y)
    local toPick = math.random(1, 4)
    local picked = baronLava[toPick]
    local spectators = Game.getSpectators(center, false, true, x, x, y, y)

    if not picked or #spectators < 1 then
        return true
    end

    local lavaHole = Tile(picked):getTopCreature()
    if lavaHole then
        doSetCreatureOutfit(lavaHole, {lookTypeEx = 389}, -1)
    end

    addEvent(function()
        if lavaHole then
            local var = {type = 1, number = lavaHole:getId()}
            lavaHoleUe:execute(lavaHole, var)
            doSetCreatureOutfit(lavaHole, {lookTypeEx = 388}, -1)
        end
    end, 8*1000)
    addEvent(wz4Lavas, 30 * 1000, center, x, y)
    return true
end 

local function summonMech(center, x, y, bossName, summon, count)
	local summons = 0
	local boss = false
	local spectator = Game.getSpectators(center, false, false, x, x, y, y)
	for _, creature in pairs(spectator) do
		if creature:isMonster() then
			if creature:getName():lower() == bossName then
				boss = true
			elseif creature:getName():lower() == summon then
				summons = summons + 1
			end
		end
	end
	if boss then
		if summons < count then
            local sumPos = Position(center.x + math.random(-3, 3), center.y + math.random(-3, 3), center.z)
            local tile = Tile(sumPos)
            if tile:isWalkable(false, false, false, true, false) then
                local toSummon = Game.createMonster(summon, sumPos)
                if toSummon then
                    toSummon:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONHIT)
                end
            end
		end
	    addEvent(summonMech, 10 * 1000, center, x, y, bossName, summon, count)
	end
    return true
end

local function initWarzone(bossPos, x, y, bossName, summonName, summonCount)
    local boss = Game.createMonster(bossName, bossPos, true, true)
    if not boss then
        return true
    end
    summonMech(bossPos, x, y, bossName, summonName, summonCount)
    return true
end

local config = {
    crystalsToOpen = 15, -- How many crystals to open tp
    timeToStart = 15, -- Time to close tp and spawn boss in seconds
    warzones = {
        [1] =  { --WZ 5
            spikePos = Position(33324, 32109, 15),
            stonePos = Position(33323, 32109, 15),
            center = Position(33681, 32335, 15), 
            enter = Position(33681, 32338, 15),
            kickPos = Position(33323, 32111, 15),
            bossName = "the count of the core",
            monsters = {"ember beast", 3},
            tpPos = Position(33681, 32340, 15),
            x = 10,
            y = 10,
            stor = Storage.DangerousDepths.wz5Room,
            callback = function(bossPos, x, y, bossName, summonName, summonCount)
                initWarzone(bossPos, x, y, bossName, summonName, summonCount)
                addEvent(countMachinesMechanic, 15 * 1000, bossPos, x, y)
            end
        },
        [2] =  { --WZ 4
            spikePos = Position(33460, 32267, 15),
            stonePos = Position(33459, 32267, 15),
            center = Position(33648, 32303, 15),
            enter = Position(33650, 32310, 15),
            kickPos = Position(33458, 32269, 15),
            bossName = "the baron from below",
            monsters = {"aggressive lava", 3},
            tpPos = Position(33650, 32312, 15),
            summons = {
                name = "Lava Hole",
                pos = {
                    Position(33644, 32299, 15),
                    Position(33652, 32299, 15),
                    Position(33644, 32307, 15),
                    Position(33652, 32307, 15)
                }
            },
            x = 10,
            y = 10,
            stor = Storage.DangerousDepths.wz4Room,
            callback = function(bossPos, x, y, bossName, summonName, summonCount)
                initWarzone(bossPos, x, y, bossName, summonName, summonCount)
                addEvent(wz4Lavas, 30 * 1000, bossPos, x, y)
            end
        },
        [3] =  { --WZ 6
            spikePos = Position(33275, 32316, 15),
            stonePos = Position(33274, 32316, 15),
            center = Position(33712, 32303, 15),
            enter = Position(33717, 32302, 15),
            kickPos = Position(33274, 32318, 15),
            bossName = "the duke of the depths",
            monsters = {"aggressive lava", 3},
            tpPos = Position(33719, 32302, 15),
            x = 10,
            y = 10,
            stor = Storage.DangerousDepths.wz6Room,
            callback = function(bossPos, x, y, bossName, summonName, summonCount)
                initWarzone(bossPos, x, y, bossName, summonName, summonCount)
            end
        }
    }
}

local function clearWz(centerRoom, x, y, exitPosition, storage)
    local specs, spec = Game.getSpectators(centerRoom, false, true, x, x, y, y)
    for i = 1, #specs do
        spec = specs[i]
        if spec:isPlayer() then
            if spec:getStorageValue(storage) <= os.time() then
                spec:teleportTo(exitPosition)
                exitPosition:sendMagicEffect(CONST_ME_TELEPORT)
                spec:say("Time out! You were teleported out by Gnomish emergency device.", TALKTYPE_MONSTER_SAY, false, spec)
            end
        end
    end
	return true
end

local function getWZ(pos)
    for i = 1, #config.warzones do
        if pos == config.warzones[i].stonePos then
            return i
        end
    end
    return true
end

local dangerousDepthCrystals = Action()
function dangerousDepthCrystals.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local thing = config.warzones[getWZ(toPosition)]

    if not target.itemid == 30745 or not thing then
        return true
    end

    local tp = Tile(thing.spikePos):getItemById(1387)
    local spectators = Game.getSpectators(thing.center, false, true, thing.x, thing.x, thing.y, thing.y)

    if tp or #spectators > 0 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "This crystal geode is shaking from a battle nearby.")
        return true
    end

    local charges = target:getCustomAttribute("charges")
    if not charges then
        target:setCustomAttribute("charges", 1)
        toPosition:sendMagicEffect(CONST_ME_HITAREA)
	    item:remove(1)
    else
        if (charges + 1 >= config.crystalsToOpen) then
            toPosition:sendMagicEffect(CONST_ME_HITAREA)
            clearEntrance(thing.center, thing.x, thing.y)
            local teleport = Tile(thing.tpPos):getItemById(25417)
            if teleport then
                teleport:setDestination(thing.kickPos)
                teleport:transform(1387)
            end
            target:setCustomAttribute("charges", 0)
            local stalagmites = Tile(thing.spikePos):getItemById(386)
			if stalagmites then
				stalagmites:remove()
                local teleport = Game.createItem(1387, 1, thing.spikePos)
                teleport:setActionId(57243)
                if thing.summons then
                    for i = 1, #thing.summons.pos do
                        local spawnSummon = Game.createMonster(thing.summons.name, thing.summons.pos[i], false, true)
                        if not spawnSummon then
                            return true
                        end
                    end
                end
                addEvent(function()
                    if teleport then
                        teleport:remove(1)
                        Game.createItem(386, 1, thing.spikePos)
                    end
                    thing.callback(thing.center, thing.x, thing.y, thing.bossName, thing.monsters[1], thing.monsters[2])
                    addEvent(clearWz, 30 * 60 * 1000 + config.timeToStart * 1000, thing.center, thing.x, thing.y, thing.kickPos, thing.stor)
                end, config.timeToStart * 1000)
            end
        else
            target:setCustomAttribute("charges", target:getCustomAttribute("charges") + 1)
            toPosition:sendMagicEffect(CONST_ME_HITAREA)
			item:remove(1)
        end
    end
    return true
end
dangerousDepthCrystals:id(31993)
dangerousDepthCrystals:register()