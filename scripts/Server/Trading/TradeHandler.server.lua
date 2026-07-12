local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(script.Parent.Parent.Data.DataManager)
local TradeManager = require(script.Parent.TradeManager)

local RequestTrade = ReplicatedStorage.Remotes.RequestTrade
local RespondTrade = ReplicatedStorage.Remotes.RespondTrade
local UpdateTradeOffer = ReplicatedStorage.Remotes.UpdateTradeOffer
local ConfirmTrade = ReplicatedStorage.Remotes.ConfirmTrade
local CancelTrade = ReplicatedStorage.Remotes.CancelTrade
local TradeStateChanged = ReplicatedStorage.Remotes.TradeStateChanged
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated

local pendingRequests = {} -- [targetUserId] = requestingPlayer

local CONFIRM_LOCK_DELAY = 3 -- seconds, final "are you sure" window

local function broadcastState(trade)
    for _, p in ipairs(trade.players) do
        TradeStateChanged:FireClient(p, trade.offers, trade.confirmed)
    end
end

RequestTrade.OnServerEvent:Connect(function(player, targetPlayer)
    if typeof(targetPlayer) ~= "Instance" or not targetPlayer:IsA("Player") then return end
    if targetPlayer == player then return end
    pendingRequests[targetPlayer.UserId] = player
    RespondTrade:FireClient(targetPlayer, player, "Requested")
end)

RespondTrade.OnServerEvent:Connect(function(player, accepted)
    local requester = pendingRequests[player.UserId]
    if not requester or not requester.Parent then
        pendingRequests[player.UserId] = nil
        return
    end
    pendingRequests[player.UserId] = nil

    if not accepted then return end

    local tradeId = TradeManager.CreateTrade(requester, player)
    if not tradeId then return end -- someone already mid-trade elsewhere

    local trade = TradeManager.GetTradeForPlayer(player)
    broadcastState(trade)
end)

UpdateTradeOffer.OnServerEvent:Connect(function(player, unitName, delta)
    if type(unitName) ~= "string" or type(delta) ~= "number" then return end
    if delta ~= 1 and delta ~= -1 then return end -- only ever add/remove one at a time

    local data = DataManager.Get(player)
    if not data then return end

    local ok = TradeManager.UpdateOffer(player, unitName, delta, function(name, wouldBeCount)
        local owned = data.OwnedUnits[name] or 0
        return wouldBeCount <= owned
    end)

    if ok then
        local trade = TradeManager.GetTradeForPlayer(player)
        broadcastState(trade)
    end
end)

ConfirmTrade.OnServerEvent:Connect(function(player)
    local trade = TradeManager.GetTradeForPlayer(player)
    if not trade then return end

    TradeManager.Confirm(player)
    broadcastState(trade)

    if TradeManager.BothConfirmed(trade) then
        -- final lock-in delay so both players see the finished offer before it's final
        task.delay(CONFIRM_LOCK_DELAY, function()
            -- re-check nothing changed and both are still confirmed after the delay
            if not TradeManager.BothConfirmed(trade) then return end

            local playerA, playerB = trade.players[1], trade.players[2]
            local dataA, dataB = DataManager.Get(playerA), DataManager.Get(playerB)
            if not dataA or not dataB then
                TradeManager.EndTrade(playerA)
                return
            end

            -- re-validate ownership server-side one more time right before the swap
            for unitName, count in pairs(trade.offers[playerA.UserId]) do
                if (dataA.OwnedUnits[unitName] or 0) < count then
                    TradeManager.EndTrade(playerA)
                    return
                end
            end
            for unitName, count in pairs(trade.offers[playerB.UserId]) do
                if (dataB.OwnedUnits[unitName] or 0) < count then
                    TradeManager.EndTrade(playerA)
                    return
                end
            end

            -- atomic-feeling swap: remove everything first, then grant, in one go
            for unitName, count in pairs(trade.offers[playerA.UserId]) do
                dataA.OwnedUnits[unitName] -= count
                dataB.OwnedUnits[unitName] = (dataB.OwnedUnits[unitName] or 0) + count
            end
            for unitName, count in pairs(trade.offers[playerB.UserId]) do
                dataB.OwnedUnits[unitName] -= count
                dataA.OwnedUnits[unitName] = (dataA.OwnedUnits[unitName] or 0) + count
            end

            TradeStateChanged:FireClient(playerA, nil, nil, "Completed")
            TradeStateChanged:FireClient(playerB, nil, nil, "Completed")
            InventoryUpdated:FireClient(playerA, dataA.OwnedUnits, dataA.PlacedUnits)
            InventoryUpdated:FireClient(playerB, dataB.OwnedUnits, dataB.PlacedUnits)
            TradeManager.EndTrade(playerA)
        end)
    end
end)

CancelTrade.OnServerEvent:Connect(function(player)
    local trade = TradeManager.GetTradeForPlayer(player)
    if not trade then return end
    for _, p in ipairs(trade.players) do
        TradeStateChanged:FireClient(p, nil, nil, "Cancelled")
    end
    TradeManager.EndTrade(player)
end)

Players.PlayerRemoving:Connect(function(player)
    pendingRequests[player.UserId] = nil
    TradeManager.EndTrade(player)
end)
