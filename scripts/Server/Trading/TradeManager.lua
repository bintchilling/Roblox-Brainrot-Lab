local TradeManager = {}

-- activeTrades[tradeId] = {
--   players = {player1, player2},
--   offers = { [UserId] = { [UnitName] = count } },
--   confirmed = { [UserId] = false },
-- }
local activeTrades = {}
local playerTradeId = {} -- [UserId] = tradeId, so a player can only be in one trade at a time

local nextTradeId = 1

function TradeManager.CreateTrade(playerA, playerB)
    if playerTradeId[playerA.UserId] or playerTradeId[playerB.UserId] then
        return nil -- one of them is already in a trade
    end

    local id = nextTradeId
    nextTradeId += 1

    activeTrades[id] = {
        players = { playerA, playerB },
        offers = { [playerA.UserId] = {}, [playerB.UserId] = {} },
        confirmed = { [playerA.UserId] = false, [playerB.UserId] = false },
    }
    playerTradeId[playerA.UserId] = id
    playerTradeId[playerB.UserId] = id

    return id
end

function TradeManager.GetTradeForPlayer(player)
    local id = playerTradeId[player.UserId]
    if not id then return nil, nil end
    return activeTrades[id], id
end

function TradeManager.UpdateOffer(player, unitName, delta, ownedCheckFn)
    local trade = TradeManager.GetTradeForPlayer(player)
    if not trade then return false end

    local offer = trade.offers[player.UserId]
    local newCount = (offer[unitName] or 0) + delta
    if newCount < 0 then return false end

    -- never let someone offer more copies than they actually own
    if not ownedCheckFn(unitName, newCount) then return false end

    if newCount == 0 then
        offer[unitName] = nil
    else
        offer[unitName] = newCount
    end

    -- any change to either side resets BOTH confirmations — this is the
    -- anti-scam rule: you can't sneak a change in after someone confirms
    for _, p in ipairs(trade.players) do
        trade.confirmed[p.UserId] = false
    end

    return true
end

function TradeManager.Confirm(player)
    local trade = TradeManager.GetTradeForPlayer(player)
    if not trade then return false end
    trade.confirmed[player.UserId] = true
    return true
end

function TradeManager.BothConfirmed(trade)
    for _, p in ipairs(trade.players) do
        if not trade.confirmed[p.UserId] then
            return false
        end
    end
    return true
end

function TradeManager.EndTrade(player)
    local id = playerTradeId[player.UserId]
    if not id then return end
    local trade = activeTrades[id]
    if trade then
        for _, p in ipairs(trade.players) do
            playerTradeId[p.UserId] = nil
        end
    end
    activeTrades[id] = nil
end

return TradeManager
