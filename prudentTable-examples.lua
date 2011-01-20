local pt = require("prudentTable")

pp = function(t)
	local s = ""
	s = "%"..pt.len(t).." {"
	for i,v in pt.arrayPairs(t) do
		if i ~= 1 then s = s .."," end
		s = s .. i.. ": \"" .. tostring(v).."\""
	end
	s = s .. " }"
	print(s)
end


print "Hello"

local t

t = {}
pp(t)

t = {"one","two","three"}
--print(#t)
pp(t)
pt.setLen(t,3)
pp(t)

t2 = pt.newTable("one","two","three")
pp(t2)
t2 = pt.newTable(nil,"two",nil)
pp(t2)
pt.setLen(t2,7)
pp(t2)
print("pt.isAIndex(t,0)",pt.isAIndex(t,0))
print("pt.isAIndex(t,1)",pt.isAIndex(t,1))
print("pt.isAIndex(t,10)",pt.isAIndex(t,10))
print("pt.isAIndex(t,1.4)",pt.isAIndex(t,1.4))
print("pt.isAIndex(t,\"3\")",pt.isAIndex(t,"3"))
for i,v in pt.rarrayPairs(t2) do print(i,v) end

print("aAdd")
pp(t2)
pt.aAdd(t2,"eight",nil,"ten")
pp(t2)
pt.aAdd(t2)
pp(t2)

print("aRemove")
pp(t2)
pt.aRemove(t2,10)
pp(t2)
pt.aRemove(t2,3,5)
pp(t2)
pt.aRemove(t2,1,pt.len(t2))
pp(t2)

print("aInsert")
pp(t2)
pt.aInsert(t2,1,"one")
pp(t2)
pt.aInsert(t2,1,"before one")
pp(t2)
pt.aInsert(t2,1,"-2-one", "-3-one")
pp(t2)
pt.aInsert(t2,pt.len(t2),"before last")
pp(t2)
pt.aInsert(t2,3,"-2 one", "-3 one")
pp(t2)
print(pcall(pt.aInsert, t2,-3,"-2 one", "-3 one"))

print("unpack",pt.unpack(pt.pack(1,2),1,2))

print("default")
local t3 = pt.pack(1,nil,3,nil,nil,6,nil)
print(pt.unpack(t3))
pp(t3)
pt.setArrayDefault(t3,0)
pp(t3)
print(pt.unpack(t3))
pt.setArrayDefault(t3,nil)
pp(t3)
print(pt.unpack(t3))

print("keys")
print(pt.tableKeys(t3))
print(pt.mapKeys(t3))
t3.n=nil
print(pt.mapKeys(t3))

print("End")

