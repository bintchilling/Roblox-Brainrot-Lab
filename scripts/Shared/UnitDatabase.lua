local UnitDatabase = {}

UnitDatabase.Order = {
    "Test Brainrot", "Boombo Zizzle", "Chungo Wumpo", "Blorbo Snax",
    "Frigo Camelo", "Skrunkle Bap",
}

UnitDatabase.Units = {
    ["Test Brainrot"] = { Rarity = "Common",    BaseIncome = 1,   BaseCost = 0 },
    ["Boombo Zizzle"] = { Rarity = "Common",    BaseIncome = 1,   BaseCost = 50 },
    ["Chungo Wumpo"]  = { Rarity = "Uncommon",  BaseIncome = 5,   BaseCost = 250 },
    ["Blorbo Snax"]   = { Rarity = "Rare",      BaseIncome = 20,  BaseCost = 1000 },
    ["Frigo Camelo"]  = { Rarity = "Epic",      BaseIncome = 80,  BaseCost = 5000 },
    ["Skrunkle Bap"]  = { Rarity = "Legendary", BaseIncome = 300, BaseCost = 25000 },
}

-- What rarity + how many duplicates are needed to fuse UP to the next rarity
UnitDatabase.FusionRecipes = {
    ["Common"]   = { ResultRarity = "Uncommon",  RequiredCount = 3 },
    ["Uncommon"] = { ResultRarity = "Rare",      RequiredCount = 3 },
    ["Rare"]     = { ResultRarity = "Epic",      RequiredCount = 3 },
    ["Epic"]     = { ResultRarity = "Legendary", RequiredCount = 3 },
}

return UnitDatabase
