local json = require("cadkjson")
local jpp = json.pp
local jppdb = json.ppdb

local pT = require("prudentTable")
local pT_i = pT.pT_i

local orig_aget,orig_agetR,orig_agetT,orig_apairs,orig_append,orig_appendT,orig_areset,orig_aresetR,orig_aresetT,orig_arrayCopy,orig_arrayLengthKey,orig_arrayPairs,orig_arrayPairsSkipNil,orig_arrayValuesS,orig_aset,orig_asetT,orig_compare,orig_concat,orig_copy,orig_deepCompare,orig_deepCopy,orig_exportPTable,orig_getLen,orig_hasNilValues,orig_importPTable,orig_insert,orig_insertT,orig_isIndex,orig_isMapKey,orig_isPTable,orig_len,orig_lenEqLuaLen,orig_lenT,orig_list,orig_listPairs,orig_listPairsSkipNil,orig_mapKeys,orig_mapLen,orig_mapNext,orig_mapPairs,orig_mapValues,orig_mapValuesS,orig_nonNilLen,orig_pT_i,orig_pTable,orig_pTableT,orig_pack,orig_rarrayPairs,orig_remove,orig_removeNils,orig_removeR,orig_sort,orig_tableKeys,orig_tableLen,orig_unpack,orig_unregPTable = aget,agetR,agetT,apairs,append,appendT,areset,aresetR,aresetT,arrayCopy,arrayLengthKey,arrayPairs,arrayPairsSkipNil,arrayValuesS,aset,asetT,compare,concat,copy,deepCompare,deepCopy,exportPTable,getLen,hasNilValues,importPTable,insert,insertT,isIndex,isMapKey,isPTable,len,lenEqLuaLen,lenT,list,listPairs,listPairsSkipNil,mapKeys,mapLen,mapNext,mapPairs,mapValues,mapValuesS,nonNilLen,pT_i,pTable,pTableT,pack,rarrayPairs,remove,removeNils,removeR,sort,tableKeys,tableLen,unpack,unregPTable	

local aget,agetR,agetT,apairs,append,appendT,areset,aresetR,aresetT,arrayCopy,arrayLengthKey,arrayPairs,arrayPairsSkipNil,arrayValuesS,aset,asetT,compare,concat,copy,deepCompare,deepCopy,exportPTable,getLen,hasNilValues,importPTable,insert,insertT,isIndex,isMapKey,isPTable,len,lenEqLuaLen,lenT,list,listPairs,listPairsSkipNil,mapKeys,mapLen,mapNext,mapPairs,mapValues,mapValuesS,nonNilLen,pT_i,pTable,pTableT,pack,rarrayPairs,remove,removeNils,removeR,sort,tableKeys,tableLen,unpack,unregPTable = pT.aget,pT.agetR,pT.agetT,pT.apairs,pT.append,pT.appendT,pT.areset,pT.aresetR,pT.aresetT,pT.arrayCopy,pT.arrayLengthKey,pT.arrayPairs,pT.arrayPairsSkipNil,pT.arrayValuesS,pT.aset,pT.asetT,pT.compare,pT.concat,pT.copy,pT.deepCompare,pT.deepCopy,pT.exportPTable,pT.getLen,pT.hasNilValues,pT.importPTable,pT.insert,pT.insertT,pT.isIndex,pT.isMapKey,pT.isPTable,pT.len,pT.lenEqLuaLen,pT.lenT,pT.list,pT.listPairs,pT.listPairsSkipNil,pT.mapKeys,pT.mapLen,pT.mapNext,pT.mapPairs,pT.mapValues,pT.mapValuesS,pT.nonNilLen,pT.pT_i,pT.pTable,pT.pTableT,pT.pack,pT.rarrayPairs,pT.remove,pT.removeNils,pT.removeR,pT.sort,pT.tableKeys,pT.tableLen,pT.unpack,pT.unregPTable	

local app = pT_i.arrayPP

print "Hello"

local t

t = pack()
app(t)

t = {"one","two","three"}
--print(#t)
--app(t)
t = pTableT(t,3)
app(t)

t = pTableT({a="a", b="b", 1,2,3,nil,c="c"}, 4)
print("t:",t.a,t.b,t.c,#t,len(t))
app(t)

t2 = pack("one","two","three")
app(t2)
t2 = pack(nil,"two",nil)
app(t2)
pTableT(t2,7)
app(t2)
print("isIndex(t,0)",isIndex(t,0))
print("isIndex(t,1)",isIndex(t,1))
print("isIndex(t,10)",isIndex(t,10))
print("isIndex(t,1.4)",isIndex(t,1.4))
print("isIndex(t,\"3\")",isIndex(t,"3"))
for i,v in rarrayPairs(t2) do print(i,v) end

print("insert")
app(t2)
insert(t2,"eight")
app(t2)
insert(t2,8,"seven")
app(t2)
insertT(t2,nil,pTable("eight",nil,"ten"))
app(t2)
insert(t2)
app(t2)

print("remove")
app(t2)
print("remove(t2,10)",remove(t2,10))
app(t2)
--print("remove(t2,3,5)",remove(t2,3,5))
app(pack(remove(t2,3,5)))
app(t2)
print("remove(t2,1,len(t2))",remove(t2,1,len(t2)))
app(t2)

print("#{1,2,3,nil,5,nil,nil,8}",#{1,2,3,nil,5,nil,nil,8})
print("#{1,2,3,nil,nil,6,7,8}",#{1,2,3,nil,nil,6,7,8})
print("#{1,2,3,nil,nil,nil,nil,8}",#{nil,nil,nil,4,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,8,nil,nil,nil,nil,nil,nil,nil,10})
print("#{1,2,3,nil,5,nil,nil,8,nil}",#{1,2,3,nil,5,nil,nil,8,nil})

print("table.maxn")
print(table.maxn({1,2,3,[6]=6,[6.5]=6.5}))

print("table.insert")
local ti = {1,2,3,nil,5,nil,nil,8,nil}
print(#ti,ti[1],ti[2],ti[3],ti[4],ti[5],ti[6],ti[7],ti[8],ti[9],ti[10])
print(table.insert(ti,2,"a"))
print(#ti,ti[1],ti[2],ti[3],ti[4],ti[5],ti[6],ti[7],ti[8],ti[9],ti[10])

print("insert")
app(t2)
insert(t2,1,"one")
app(t2)
insert(t2,1,"before one")
app(t2)
insertT(t2,1,pTable("-2-one", "-3-one"))
app(t2)
insert(t2,len(t2),"before last")
app(t2)
insertT(t2,3,pTable("-2 one", "-3 one"))
app(t2)
print(pcall(insertT, t2,-3,pTable("-2 one", "-3 one")))

print("list",list(pack(1,2),1,2))
print("unpack",orig_unpack({1,2},1,2))
local t3 = pack(1,2,3)

print("keys")
app(t3)
print(list(tableKeys(t3)))
print(list(mapKeys(t3)))
t3.n=3
jpp(t3)
print(list(mapKeys(t3)))

print("table",concat(mapKeys(table),","))
local s = "{"
for k,v in pairs(table) do
	s = s ..","..k.."="..k
end
s = s.."}"
print(s)

function ttt(...)
	for i,a in apairs(...) do 
		print(i,a)
	end
end
ttt(10,nil,30,nil)

function ll(...)  return select("#",...) end
print("unpack({})",orig_unpack({}),"yo")
print("unpack({})",ll(orig_unpack({})),"yo")
print("unpack({})",select("#",list(pack())),"yo")

local t10 = pack(nil,1,nil,2,3,nil,4,nil)
print("removeNils")
app(t10)
app(removeNils(t10))

print("pTableT")
app(pTableT({a="a", b="b", 1,2,3,nil}, 4))

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
m1 = pTableT({1,2,3,a="A",b="B",4},4)
app(m1)
for k,v in mapPairs(m1) do print("k,v",k,v) end


print("arrayPairsSkipNil")
local t33 = pack("a","b",nil,"d",nil)
for i,v in arrayPairs(t33) do print(i,v) end 
for i,v in rarrayPairs(t33) do print(i,v) end 
for i,v in arrayPairsSkipNil(t33) do print(i,v) end 
for i,v in listPairs("a","b",nil,"d",nil) do print(i,v) end 
for i,v in listPairsSkipNil("a","b",nil,"d",nil) do print(i,v) end 

t33.jaja=t10; t33.nee=pack();t33.nee.janee=pack();t33.nee.janee1=t33;t33[pack()]=1

print("deepCopy(t, trefs)")
for k,v in pairs(t33) do print(k,v) end
local t44 = deepCopy(t33)
for k,v in pairs(t44) do print(k,v) end

print("deepCompare")
print("t33==t44",deepCompare(t33,t44))
local d1 = {};d1["z"]=d1; d1[1]=d1;d1[2]=2
local d2 = {};d2["z"]=d2; d2[1]=d2;d2[2]=2
print("dC:",deepCompare({2,{["a"]=4,d1}},{2,{["a"]=4,d2}}))
print("dC:",deepCompare(d1,d2))
for k,v in pairs(d1) do print("kv:",k,v) end
print("dC1:",deepCompare({},{}))

print("compare")
s1 = {}
s10={1};s20={1};
s10.ref=s10;s10[s10]="ja";s10[s10]=s10
s20.ref=s20;s20[s20]="ja";s20[s20]=s20
print("sC:",compare({1,s1},{1,s1}))
print("sC:",compare(s10,s20))

print("arrayCopy")
ac1=pack(1,2,3,4,5,6,nil,8,nil)
print(ac1)
ac1["a"]="A";insert(ac1,ac1)
app(ac1)
ac2=arrayCopy(ac1)
print(ac2)
app(ac2)


print("pT_i.assignGlobalsLocalsFunctionMap")
print("\npT_i.assignGlobalsLocalsFunctionMap(pT)")
local g,l,m,lm = pT_i.assignGlobalsLocalsFunctionMap(pT, "pT.")
print(g,"\n")
print(l,"\n")
print(m,"\n")
print(lm,"\n")
print("\npT_i.assignGlobalsLocalsFunctionMap(pT_i)")
local g,l,m,lm = pT_i.assignGlobalsLocalsFunctionMap(pT_i, "pT_i.")
print(g,"\n")
print(l,"\n")
print(m,"\n")
print(lm,"\n")

print("agetT")
local ta = pTable(1,2,3,4,nil,nil)
app(agetT(ta,pTable(5,2,3),pTable(5,2,3,6)))
app(pTable(nil,1,nil))


print("hasNilValues")
local hnv = pTable(1,2,nil)
jpp(hasNilValues(hnv))
jpp(hasNilValues(aset(hnv,3,3)))

print("table.concat")
print (table.concat(pTable(1,2,3,"ja","nee",nil), ", "))
print (table.concat(removeNils(pTable(1,2,nil,"ja","nee",nil)), ", ", 1, 4))
print (table.concat(pTable(1,2,nil,"ja","nee",nil), ", ", 1, 2))
--print (concat(pTable(1,2,nil,"ja","nee",nil), ", ", 2, 4))

print("table.sort")
--local ts = pTable(5,2,nil,4,1,nil)
local ts = pTable(5,2,4,1)
jpp("table.sort:",ts)
table.sort(ts)
jpp("table.sort:",ts)
ts = pTableT({5,2,4,1,0},4)
print(len(ts))
jpp("table.sort:",ts)
sort(ts)
jpp("table.sort:",ts)
--[[
local ts = removeNils(pTable(5,2,nil,4,1,nil))
jpp("table.sort:",ts)
table.sort(ts)
jpp("table.sort:",ts)
jpp (sort(pTable(5,2,nil,4,1,3,nil)))
--]]

print("table.insert")
local ti = {1,2,nil,nil,5,nil,7}
table.insert(ti,8)
jpp(ti)

print("table.remove")
local tr = {1,nil,nil, 4,nil,6}
trv = table.remove(tr,6)
jpp(trv,tr)

print("table.maxn")
t = {1,2,3,[3.1]="that's your maxn!!!"}
print(table.maxn(t), t[table.maxn(t)])


print("Einde")

