local pT = require("prudentTable")

pp = function(t)
	local s = ""
	s = "%"..pT.len(t).." {"
	for i,v in pT.arrayPairs(t) do
		if i ~= 1 then s = s .."," end
		s = s .. i.. ": \"" .. tostring(v).."\""
	end
	s = s .. " }"
	print(s)
end


print "Hello"

local t

t = pT.pack()
pp(t)

t = {"one","two","three"}
--print(#t)
--pp(t)
pT.setLen(t,3, false)
pp(t)

t = pT.setLen({a="a", b="b", 1,2,3,nil,c="c"}, 4, false)
print("t:",t.a,t.b,t.c,#t,pT.len(t))
pp(t)

t2 = pT.pack("one","two","three")
pp(t2)
t2 = pT.pack(nil,"two",nil)
pp(t2)
pT.setLen(t2,7)
pp(t2)
print("pT.isIndex(t,0)",pT.isIndex(t,0))
print("pT.isIndex(t,1)",pT.isIndex(t,1))
print("pT.isIndex(t,10)",pT.isIndex(t,10))
print("pT.isIndex(t,1.4)",pT.isIndex(t,1.4))
print("pT.isIndex(t,\"3\")",pT.isIndex(t,"3"))
for i,v in pT.rarrayPairs(t2) do print(i,v) end

print("add")
pp(t2)
pT.add(t2,"eight",nil,"ten")
pp(t2)
pT.add(t2)
pp(t2)

print("remove")
pp(t2)
print("remove(t2,10)",pT.remove(t2,10))
pp(t2)
--print("remove(t2,3,5)",pT.remove(t2,3,5))
pp(pT.pack(pT.remove(t2,3,5)))
pp(t2)
print("remove(t2,1,pT.len(t2))",pT.remove(t2,1,pT.len(t2)))
pp(t2)

print("insert")
pp(t2)
pT.insert(t2,1,"one")
pp(t2)
pT.insert(t2,1,"before one")
pp(t2)
pT.insert(t2,1,"-2-one", "-3-one")
pp(t2)
pT.insert(t2,pT.len(t2),"before last")
pp(t2)
pT.insert(t2,3,"-2 one", "-3 one")
pp(t2)
print(pcall(pT.insert, t2,-3,"-2 one", "-3 one"))

print("unpack",pT.unpack(pT.pack(1,2),1,2))
local t3 = pT.pack(1,2,3)

print("keys")
print(pT.tableKeys(t3))
print(pT.mapKeys(t3))
t3.n=nil
print(pT.mapKeys(t3))

local s = "{"
for k,v in pairs(pT) do
	s = s ..","..k.."="..k
end
s = s.."}"
print(s)

function ttt(...)
	for i,a in pT.apairs(...) do 
		print(i,a)
	end
end
ttt(10,nil,30,nil)

function ll(...)  return select("#",...) end
print("unpack({})",unpack({}),"yo")
print("unpack({})",ll(unpack({})),"yo")
print("unpack({})",select("#",pT.unpack(pT.pack())),"yo")

local t10 = pT.pack(nil,1,nil,2,3,nil,4,nil)
print("removeNils")
pp(t10)
pp(pT.removeNils(t10))


print("End")

