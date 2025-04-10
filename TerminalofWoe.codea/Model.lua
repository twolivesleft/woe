m = {}
local usedGoatNames = {}

-- Goat-style file names
local goatNames = {
    "Émile", "Thorne", "Lucien", "Bravik", "Odran", "Mathilde", "Caedmon", "Elsinore", "Basile", "Voss",
    "Leontine", "Frial", "Ysard", "Charn", "Orlaith", "Norwyn", "Velin", "Tressel", "Audric", "Sibyl",
    "Morven", "Halberd", "Eroda", "Languille", "Brume", "Solenne", "Varnum", "Marceau", "Alric", "Virelle",
    "Lomond", "Caelum", "Belrose", "Ulric", "Esmé", "Lowin", "Harrow", "Corbeau", "Duvall", "Faron",
    "Naelle", "Gethin", "Murne", "Sorrel", "Lior", "Halde", "Erelong", "Calixte", "Nerin", "Thalos",
    "Maurelle", "Olen", "Drever", "Sereph", "Ilsen", "Brannoch", "Quenelle", "Theon", "Clervaux", "Albin",
    "Jorim", "Vesna", "Ronel", "Morven", "Faelish", "Wymond", "Perron", "Caelum", "Alarice", "Grune",
    "Severin", "Fenric", "Evander", "Noé", "Dryden", "Malric", "Lovell", "Nimue", "Isarn", "Octavine",
    "Corvin", "Roscelin", "Eldric", "Frewyn", "Lysandre", "Elouan", "Jarnac", "Tybalt", "Roncel", "Vael",
    "Melric", "Orrin", "Navarre", "Ivelle", "Glaucus", "Sorne", "Alwen", "Elber", "Tristane", "Ruelle"
}

local function randomGoatName()
    local name
    repeat
        local index = math.random(1, #goatNames)
        name = goatNames[index]
    until not usedGoatNames[name]
    usedGoatNames[name] = true
    saveLocalData("usedGoatNames", json.encode(usedGoatNames))
    return name
end

function m.createOrLoadBuckets(count)
    local existingBuckets = readLocalData("bucketData")
    if existingBuckets then
        m.buckets = json.decode(existingBuckets)
    else
        m.buckets = {}
        for i = 1, count do
            m.buckets[i] = { name = string.format("%02d", i - 1), capacity = 100, content = 0 }
        end
        saveLocalData("bucketData", json.encode(m.buckets))
    end
end

function m.saveProgress()
    saveLocalData("bucketData", json.encode(m.buckets))
end

function m.mammaliansNurtured()
    return readLocalData("mammaliansNurtured", 0)
end

function m.nurtureMammalian()
    saveLocalData("mammaliansNurtured", m.mammaliansNurtured() + 1)
end

function m.totalProgress()
    local total = 0
    local totalCapacity = 0
    for i = 1, #m.buckets do
        total = total + m.buckets[i].content
        totalCapacity = totalCapacity + m.buckets[i].capacity
    end

    if totalCapacity == 0 then
        return 0
    end

    return total / totalCapacity
end

function m.isFileComplete()
    for i = 1, #m.buckets do
        if m.buckets[i].content < m.buckets[i].capacity then
            return false
        end
    end
    return true
end

function m.selectNextBucketIndex()
    -- Get the non-full buckets and return a random one 
    local nonFullBuckets = {}
    for i = 1, #m.buckets do
        if m.buckets[i].content < m.buckets[i].capacity then
            table.insert(nonFullBuckets, i)
        end
    end
    if #nonFullBuckets == 0 then
        return nil -- All buckets are full
    end
    local randomIndex = math.random(1, #nonFullBuckets)
    return nonFullBuckets[randomIndex]    
end

function m.currentFileName()
    local name = readLocalData("currentFileName")
    if not name then
        name = randomGoatName()
        saveLocalData("currentFileName", name)
    end
    return name
end

function m.completeFile()
    -- Mark file complete and clear persisted data
    saveLocalData("currentFileName", nil)
    saveLocalData("bucketData", nil)
end

return m
