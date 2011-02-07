
local pT,pT_i = require("prudentTable")
local pT_i = pT.pT_i

pp = function(t)
	local s = ""
	s = "%"..pT.len(t).."%"..pT.mapLen(t).."%"..pT.tableLen(t).." {"
	for i,v in pT.arrayPairs(t) do
		if i ~= 1 then s = s ..", " end
		if type(v)~="number" then 
			if v == nil then v = tostring(v)
			else v = "\""..tostring(v).."\"" end
		end
		s = s .. i.. ":" .. v ..""
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
t = pT.pTableT(t,3)
pp(t)

t = pT.pTableT({a="a", b="b", 1,2,3,nil,c="c"}, 4)
print("t:",t.a,t.b,t.c,#t,pT.len(t))
pp(t)

t2 = pT.pack("one","two","three")
pp(t2)
t2 = pT.pack(nil,"two",nil)
pp(t2)
pT.pTableT(t2,7)
pp(t2)
print("pT.isIndex(t,0)",pT.isIndex(t,0))
print("pT.isIndex(t,1)",pT.isIndex(t,1))
print("pT.isIndex(t,10)",pT.isIndex(t,10))
print("pT.isIndex(t,1.4)",pT.isIndex(t,1.4))
print("pT.isIndex(t,\"3\")",pT.isIndex(t,"3"))
for i,v in pT.rarrayPairs(t2) do print(i,v) end

print("insert")
pp(t2)
pT.insert(t2,"eight")
pp(t2)
pT.insert(t2,8,"seven")
pp(t2)
pT.insertL(t2,nil,"eight",nil,"ten")
pp(t2)
pT.insert(t2)
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

print("#{1,2,3,nil,5,nil,nil,8}",#{1,2,3,nil,5,nil,nil,8})
print("#{1,2,3,nil,nil,6,7,8}",#{1,2,3,nil,nil,6,7,8})
print("#{1,2,3,nil,nil,nil,nil,8}",#{nil,nil,nil,4,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,8,nil,nil,nil,nil,nil,nil,nil,10})
print("#{1,2,3,nil,5,nil,nil,8,nil}",#{1,2,3,nil,5,nil,nil,8,nil})


print("table.insert")
local ti = {1,2,3,nil,5,nil,nil,8,nil}
print(#ti,ti[1],ti[2],ti[3],ti[4],ti[5],ti[6],ti[7],ti[8],ti[9],ti[10])
print(table.insert(ti,2,"a"))
print(#ti,ti[1],ti[2],ti[3],ti[4],ti[5],ti[6],ti[7],ti[8],ti[9],ti[10])

print("insert")
pp(t2)
pT.insertL(t2,1,"one")
pp(t2)
pT.insertL(t2,1,"before one")
pp(t2)
pT.insertL(t2,1,"-2-one", "-3-one")
pp(t2)
pT.insertL(t2,pT.len(t2),"before last")
pp(t2)
pT.insertL(t2,3,"-2 one", "-3 one")
pp(t2)
print(pcall(pT.insertL, t2,-3,"-2 one", "-3 one"))

print("unpack",pT.unpack(pT.pack(1,2),1,2))
local t3 = pT.pack(1,2,3)

print("keys")
print(pT.tableKeysL(t3))
print(pT.mapKeysL(t3))
t3.n=nil
print(pT.mapKeysL(t3))

local s = "{"
for k,v in pairs(table) do
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

print("pT.pTableT")
pp(pT.pTableT({a="a", b="b", 1,2,3,nil}, 4))

print("setn/getn")
t22 = {1,2,3,4}
print(#t22,table.getn(t22))
-- table.setn(t22,10)
t22[#t22+1]=5
print(#t22,table.getn(t22))
t22[3]=nil
print(#t22,table.getn(t22))
t22[4]=nil
print(#t22,table.getn(t22))

print("#madness")
t1 = { 'foo', nil, 'bar' }
print(#t1)
--3
t2 = {}
t2[1] = 'foo'
t2[2] = nil
t2[3] = 'bar'
print(#t2)
--1
a = {1,2,3,nil,nil,6}
b = {}
b[1] = 1
b[2] = 2
b[3] = 3
b[6] = 6
print (#a,#b)
--6       3

print("mapPairs")
m1 = pT.pTableT({1,2,3,a="A",b="B",4},4)
pp(m1)
for k,v in pT.mapPairs(m1) do print("k,v",k,v) end


print("pT.arrayPairsSkipNil")
local t33 = pT.pack("a","b",nil,"d",nil)
for i,v in pT.arrayPairs(t33) do print(i,v) end 
for i,v in pT.rarrayPairs(t33) do print(i,v) end 
for i,v in pT.arrayPairsSkipNil(t33) do print(i,v) end 
for i,v in pT.listPairs("a","b",nil,"d",nil) do print(i,v) end 
for i,v in pT.listPairsSkipNil("a","b",nil,"d",nil) do print(i,v) end 

t33.jaja=t10; t33.nee=pT.pack();t33.nee.janee=pT.pack();t33.nee.janee1=t33;t33[pT.pack()]=1

print("pT.deepCopy(t, trefs)")
for k,v in pairs(t33) do print(k,v) end
local t44 = pT.deepCopy(t33)
for k,v in pairs(t44) do print(k,v) end

print("pT.deepCompare")
print("t33==t44",pT.deepCompare(t33,t44))
local d1 = {};d1["z"]=d1; d1[1]=d1;d1[2]=2
local d2 = {};d2["z"]=d2; d2[1]=d2;d2[2]=2
print("dC:",pT.deepCompare({2,{["a"]=4,d1}},{2,{["a"]=4,d2}}))
print("dC:",pT.deepCompare(d1,d2))
for k,v in pairs(d1) do print("kv:",k,v) end
print("dC1:",pT.deepCompare({},{}))

print("pT.shallowCompare")
s1 = {}
s10={1};s20={1};
s10.ref=s10;s10[s10]="ja";s10[s10]=s10
s20.ref=s20;s20[s20]="ja";s20[s20]=s20
print("sC:",pT.shallowCompare({1,s1},{1,s1}))
print("sC:",pT.shallowCompare(s10,s20))

print("pT.arrayCopy")
ac1=pT.pack(1,2,3,4,5,6,nil,8,nil)
print(ac1)
ac1["a"]="A";pT.insert(ac1,ac1)
pp(ac1)
ac2=pT.arrayCopy(ac1)
print(ac2)
pp(ac2)


print("pT_i.assignGlobalsLocalsFunctionMap")
print("\npT_i.assignGlobalsLocalsFunctionMap(pT)")
local g,l,lt = pT_i.assignGlobalsLocalsFunctionMap(pT, "pT.")
print(g,"\n")
print(l,"\n")
print(lt,"\n")
print("\npT_i.assignGlobalsLocalsFunctionMap(pT_i)")
local g,l,lt = pT_i.assignGlobalsLocalsFunctionMap(pT_i, "pT_i.")
print(g,"\n")
print(l,"\n")
print(lt,"\n")

print("Einde")

