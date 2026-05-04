if not bit32 then
    bit32 = {
        band = function(a, b) return bit.band(a, b) end,
        bor = function(a, b) return bit.bor(a, b) end,
        bxor = function(a, b) return bit.bxor(a, b) end,
        bnot = function(a) return bit.bnot(a) end,
        lshift = function(a, b) return bit.lshift(a, b) end,
        rshift = function(a, b) return bit.rshift(a, b) end,
        arshift = function(a, b) return bit.arshift(a, b) end,
    }
end
