local function removeif(t, f)
    local i, r = 1, table.remove
    while i <= #t do
        if f(t[i]) then
            r(t, i)
        else
            i = i + 1
        end
    end
end

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local export = {}
export.removeif = removeif
export.distance = distance
return export
