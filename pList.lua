--[[

p = pack(...)
p()               --> ...
p("#")            --> select("#", ...)
p(i)              --> (select(i, ...))
p(i, j)           --> table.unpack({...}, i, j)
for i,v in p do   --> for i,v in apairs(...) do

range(i, j, ...)  --> unpack({...}, i, j)
remove(i, ...)    --> t={...} table.remove(t,i) return unpack(t,1,select("#",...)-1)
insert(v, i, ...) --> t={...} table.insert(t,i,v) return unpack(t,1,select("#",...)+1)
append(v, ...)    --> c=select("#",...)+1 return unpack({[c]=val,...},1,c)
concat(f1,f2,...) --> return all the values returned by functions 'f1,f2,...'

--]]

pT = require("prudentTable")

local pL = {}

function pL.list(...)
	local t = pT.pack(...)
	local function aList()
			return pT.unpack(t)
		end
	return aList
end
local list = pL.list

function pL.len(l) return select("#",l()) end

function pL.get(l,i) return (select(i,l())) end

print("pList")

l = list(1,2,3)
print(l())
print(pL.len(l))
print(pL.get(l,2))

return pL
