-------------------------------------------------------------------------------
--[[  prudentTable.lua - A module for the less-adventurous among us lua-coders
--
-- Copyright (c) Frank Siebenlist. All rights reserved.
-- The use and distribution terms for this software are covered by the
-- Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php).
-- By using this software in any fashion, you are agreeing to be bound by
-- the terms of this license.
-- You must not remove this notice, or any other, from this software.
--
--]]
-------------------------------------------------------------------------------
local json = require("cadkjson")
jpp = json.pp
jppdb = json.ppdb


--- Prudent Table routines.
-- @class module
-- @name pTable
-- make sure we keep the globals accessible thru "orig_*" aliases
local orig_aget,orig_agetR,orig_agetT,orig_apairs,orig_append,orig_appendT,orig_areset,orig_aresetR,orig_aresetT,orig_arrayCopy,orig_arrayLengthKey,orig_arrayPairs,orig_arrayPairsSkipNil,orig_arrayValuesS,orig_aset,orig_asetT,orig_compare,orig_concat,orig_copy,orig_deepCompare,orig_deepCopy,orig_exportPTable,orig_getLen,orig_hasNilValues,orig_importPTable,orig_insert,orig_insertT,orig_isIndex,orig_isMapKey,orig_isPTable,orig_len,orig_lenEqLuaLen,orig_lenT,orig_list,orig_listPairs,orig_listPairsSkipNil,orig_mapKeys,orig_mapLen,orig_mapNext,orig_mapPairs,orig_mapValues,orig_mapValuesS,orig_nonNilLen,orig_pT_i,orig_pTable,orig_pTableT,orig_pack,orig_rarrayPairs,orig_remove,orig_removeNils,orig_removeR,orig_sort,orig_tableKeys,orig_tableLen,orig_unpack,orig_unregPTable = aget,agetR,agetT,apairs,append,appendT,areset,aresetR,aresetT,arrayCopy,arrayLengthKey,arrayPairs,arrayPairsSkipNil,arrayValuesS,aset,asetT,compare,concat,copy,deepCompare,deepCopy,exportPTable,getLen,hasNilValues,importPTable,insert,insertT,isIndex,isMapKey,isPTable,len,lenEqLuaLen,lenT,list,listPairs,listPairsSkipNil,mapKeys,mapLen,mapNext,mapPairs,mapValues,mapValuesS,nonNilLen,pT_i,pTable,pTableT,pack,rarrayPairs,remove,removeNils,removeR,sort,tableKeys,tableLen,unpack,unregPTable	

-- localize all the fnames
local aget,agetR,agetT,apairs,append,appendT,areset,aresetR,aresetT,arrayCopy,arrayLengthKey,arrayPairs,arrayPairsSkipNil,arrayValuesS,aset,asetT,compare,concat,copy,deepCompare,deepCopy,exportPTable,getLen,hasNilValues,importPTable,insert,insertT,isIndex,isMapKey,isPTable,len,lenEqLuaLen,lenT,list,listPairs,listPairsSkipNil,mapKeys,mapLen,mapNext,mapPairs,mapValues,mapValuesS,nonNilLen,pT_i,pTable,pTableT,pack,rarrayPairs,remove,removeNils,removeR,sort,tableKeys,tableLen,unpack,unregPTable	

-- make sure we keep the globals accessible thru "orig_*" aliases
local orig_agetR_i,orig_aget_i,orig_aresetR_i,orig_arrayPP,orig_arrayPairsSkipNil_iter,orig_arrayPairs_iter,orig_asetT_i,orig_aset_i,orig_assignGlobalsLocalsFunctionMap,orig_deepCompare_helper,orig_deepCopy_helper,orig_isGE0Int,orig_isGT0Int,orig_isIndexPlus1,orig_listPairsSkipNil_iter,orig_listPairs_iter,orig_rarrayPairs_iter,orig_setLen = agetR_i,aget_i,aresetR_i,arrayPP,arrayPairsSkipNil_iter,arrayPairs_iter,asetT_i,aset_i,assignGlobalsLocalsFunctionMap,deepCompare_helper,deepCopy_helper,isGE0Int,isGT0Int,isIndexPlus1,listPairsSkipNil_iter,listPairs_iter,rarrayPairs_iter,setLen	

-- localize all the fnames
local agetR_i,aget_i,aresetR_i,arrayPP,arrayPairsSkipNil_iter,arrayPairs_iter,asetT_i,aset_i,assignGlobalsLocalsFunctionMap,deepCompare_helper,deepCopy_helper,isGE0Int,isGT0Int,isIndexPlus1,listPairsSkipNil_iter,listPairs_iter,rarrayPairs_iter,setLen	

local pT, pT_i

-------------------------------------------------------------------------------

-- main function table to return, which will hold all the exported functions
pT = {}

-- internal function table to return - available to other modules that trade safety for performance 
pT_i = {}
pT.pT_i = pT_i

-- weak table for representing the size/length/count of array-tables.
-- n = tableLenT[t] or nil
tableLenT = setmetatable({}, {__mode = 'k'})

-- array-length URI definition for persistent import/export of tables
pT.arrayLengthKey = "uri:http://www.luna.org/ns/arrayLength"

-------------------------------------------------------------------------------
-- Basic query pTable query-functions
-- pT.isPTable, pT.len, pT.isIndex

--- Returns whether t is registered as a pTable.
--@param t possible pTable
--@return boolean - true indicates t has been registered as a pTable
function pT.isPTable(t) 
	return type(t)=="table" and tableLenT[t] ~= nil 
end

--- Returns length/size of the array component of pTable t.
--@param t pTable
--@return Integer >= 0 indicating the size/length of t's array-component
function pT.len(t)
	assert(isPTable(t), "Table is not a registered pTable")
	return tableLenT[t]
end
pT.getLen = pT.len  -- alias for naming consistency

--- Returns the sum of the array-lengths of a list of pTables: len(t1)+...+len(tn).
--@param ... list of zero, one or more pTables - may include nils, which are ignored.
--@returns sum of the number of array-elements of all pTables.
function pT.lenT(...)
	local ntin = 0
	for i,ti in listPairsSkipNil(...) do
		assert(isPTable(ti),"pT.lenT: argument must be pTable or nil")
		ntin = ntin + len(ti)
	end
	return ntin
end

--- Returns the number of map entries in pTable t that are not part of the array-component.
--@param t pTable
--@return Integer >= 0 indicating number of t's non-array components
function pT.mapLen(t)
	assert(isPTable(t), "Table is not a registered pTable")
	local n = 0
	for k,v in mapPairs(t) do n = n+1 end
	return n
end

--- Returns the number of real table entries of t - does not include any nil-assigned array elements.
-- Simply loops with pairs() over all table entries and counts.
--@param t pTable
--@return Integer >= 0 indicating number of truly allocated table entries
function pT.tableLen(t)
	local n = 0
	for k,v in pairs(t) do n = n+1 end
	return n
end

--- Returns whether the key k is a valid index for the array-component of pTable t.
--@param t pTable
--@param k possible array index value
--@return boolean - true indicates k is integer and 1 <= k <= pT.len(t)
function pT.isIndex(t,k)
	return isGT0Int(k) and k <= len(t)
end

-------------------------------------------------------------------------------
-- setLen(): internal function to set the array-component length of a pTable
-- Used by any function that will change the array-size, like insert() and remove().

--- Set the length/size of the array component of table t and registers t as a pTable.
-- Thru setLen(), a Lua-table t is "registered" as a pTable.
-- If size is increased, then existing map entries become part of the array.
-- If size is decreased, then some array components become map entries.
-- If resetValues==true (default) then all new array/map elements get reset to nil.
-- This reset is to avoid any inconsistencies caused by unexpected new map/array elements.
-- Note, however, that no element values are reset by default during the very first registration - implicit resetValues=false for first registration.
--@param t An standard lua-table or pTable
--@param n Integer >= 0
--@param resetValues boolean (default true) - resets new array or map elements to nil.
--@return pTable t (possibly modified - depending on n and resetValues - not modified on first registration)
function pT_i.setLen(t, n, resetValues)
	assert(type(t)=="table")
	n = n or 0
	assert(isGE0Int(n))
	resetValues = resetValues==nil or resetValues  -- defaults to true
	local oldn = 0
	if isPTable(t) then oldn = len(t) end
	if isPTable(t) and resetValues and oldn~=n then
		local b,e
		if oldn < n then b,e=oldn+1,n else b,e=n+1,oldn end
		for i = b,e do t[i]=nil end   -- nil-out all new or old array elements
	end
	tableLenT[t] = n  -- register the table size and make t a pTable
	return t
end

-------------------------------------------------------------------------------
-- array-get functions that incorporate array-bound checking
-- aget, agetLL, agetR

--- Returns the array-element value at index i of pTable t.
--@param t pTable
--@param i index (1 <= i <= len(t))
--@return value at t[i]
function pT.aget(t,i)
	assert(isPTable(t), "aget: Table t is not a registered pTable")
	assert(isIndex(t,i), "aget: Index i not within 1 <= i <= len(t)")
	return aget_i(t,i)
end

--- Internal function without assertions - returns the element value at index i of pTable t.
--@param t pTable
--@param i index (1 <= i <= len(t))
--@return value at t[i]
function pT_i.aget_i(t,i)
	return t[i]
end

--- For all the array-element values of the list of pTables, return a new pTable with the values of the associated array-components of pTable t. Indices do not have to be in any order but have to be valid indices for t. Any nils in arg-list for pTables are ignored, but arg-list pTables can not have nil-values for array-elements values.
--@param t pTable
--@param ... list pTables which array-element values indicate indices for t - nils are ignored.
--@return new pTable where the array-component holds the values associated with the given list of indices.
function pT.agetT(t,...)
	assert(isPTable(t), "agetT: Table t is not a registered pTable")
	local n = lenT(...)
	local res = pTableT(n)
	local ires = 1
	for il, tl in listPairsSkipNil(...) do
		for it,vt in arrayPairs(tl) do
			assert(isIndex(t,vt),"pT.agetT: array-element values must be valid array-index for t")
			aset_i(res,ires,aget_i(t,vt))
			ires = ires + 1
		end
	end
	return res
end

--- For the range of array-index b till e of pTable t, returns an array of element values as a new pTable.
-- Range must not extend array boundaries.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1.
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t).
--@return new pTable with requested values in the array-components.
function pT.agetR(t,b,e)
	assert(isPTable(t), "Table is not a registered pTable")
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b<=e)
	return agetR_i(t,b,e)
end

-- For the range of array-index b till e of pTable t, returns an array of element values as a new pTable without type and array bound checks.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1.
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t).
--@return new pTable with requested values in the array-components.
function pT_i.agetR_i(t,b,e)
	local n = e-b+1
	if n==1 then return pTable(aget_i(t,b)) end
	local tmp = pTableT(n)
	for j = 1,n do aset_i(tmp, j, aget_i(t,b+j-1)) end
	return tmp
end

--- For the range of array-index b till e of pTable t, returns an list of element values - "pTable-aware" table.unpack() replacement.
-- Note that pT.unpack does NOT use any "t.n" that may be used to indicates the array-length.
--@param t pTable
--@param b start of range to copy - defaults to 1
--@param e end of range to copy - defaults to pT.len(t)
--@return list of values representing t[b:e] - may include nils
function pT.unpack(t,b,e) 
	if(len(t) == 0)then return end
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b<=e,"pT.unpack: isIndex(t,b) and isIndex(t,e) and b<=e")
	return orig_unpack(t,b,e) 
end

--- For the range of array-index b till e of pTable t, returns an list of element values - (alias of pT.unpack())
--@param t pTable
--@param b start of range to copy - defaults to 1
--@param e end of range to copy - defaults to pT.len(t)
--@return list of values representing t[b:e] - may include nils
function pT.list(t,b,e) return unpack(t,b,e) end

-------------------------------------------------------------------------------
-- aset, asetT, asetL

--- Set pTable t's element at index i to value v.
-- i should be a valid index for t.
--@param t pTable
--@param i index: 1 <= i <= len(t)
--@param v new value (may be nil)
--@return modified pTable t
function pT.aset(t,i,v)
	assert(isPTable(t), "Table is not a registered pTable")
	assert(isIndex(t,i), "Index i not within 1 <= i <= len(t)")
	return aset_i(t,i,v)
end

-- Internal function - sets the value of element i of ptable t to value v.
-- Array-size must be able to accomodate the list as it does not grow automatically.
function pT_i.aset_i(t,i,v)
	t[i] = v
	return t
end

--- Copies the array element values of pTables t1...tn into the array-component of pTable t starting at index i.
-- t's array-size must be able to accomodate all the new element values as it does not grow automatically.
--@param t pTable (target)
--@param i target start-index
--@param ... list of zero, one or more pTable's (source) - nils are ignored.
--@returns modified pTable t
function pT.asetT(t,i,...)
	assert(isPTable(t), "Table t is not a registered pTable")
	assert(isIndex(t,i), "Index i not within 1 <= i <= len(t)")
	local ntin = lenT(...)
	if ntin == 0 then return t end	
	local lt = len(t)
	assert((i + ntin - 1) <= lt, "asetT: Size of pTable t's array cannot accomodate elements")
	return asetT_i(t,i,...)
end

-- Copies the array elements of pTables t1...tn into the array-component of pTable t starting at index i without any type or bound-checks.
function pT_i.asetT_i(t,i,...)
	for k,tk in listPairs(...) do
		if tk ~= nil then
			for j,vj in arrayPairs(tk) do
				aset_i(t,i,vj)
				i = i + 1
			end
		end
	end
	return t
end

-------------------------------------------------------------------------------
-- areset, aresetR, aresetT

--- Reset the value of array-element i of pTable t to nil. 
--@param t pTable
--@param i index
--@return modified pTable t
function pT.areset(t,i) return aset(t,i,nil) end

--- Reset the range (b:e) of the array-component of pTable t to nil. Range must 
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t)
--@return modified pTable t
function pT.aresetR(t,b,e)
	assert(isPTable(t), "Table is not a registered pTable")
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b<=e)
	return pT_i.aresetR_i(t,b,e)
end

--- Reset the range (b:e) of the array-component of pTable t to nil. Range must 
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t)
--@return modified pTable t
function pT_i.aresetR_i(t,b,e)
	for i = b,e do aset_i(t,i) end
	return t
end

--- For all the array-element values of the list of pTables, reset the array-elements of t which index equals those values. Indices do not have to be in any order but have to be valid indices for t. Any nils in arg-list for pTables are ignored, but arg-list pTables can not have nil-values for array-elements values.
--@param t pTable
--@param ... list of zero, one or more pTables where the array-element values indicate indices for pTable t's array-component.
--@return modified pTable t.
function pT.aresetT(t,...)
	assert(isPTable(t), "pT.aresetT: Table t is not a registered pTable")
	for il, tl in listPairsSkipNil(...) do
		for it,vt in arrayPairs(tl) do
			assert(isIndex(t,vt),"pT.agetT: array-element values must be valid array-index for t")
			areset(t,vt)
		end
	end
	return t
end

-------------------------------------------------------------------------------
-- insert, insertT, insertL

--- Extends and inserts a single value at index i of pTable t - Array-size is increased by one to accomodate the new entry.
-- Existing elements are moved-up - no values are overwritten.
-- i can be len(t)+1, which implies appending to array.
-- (nil-friendly)
--@usage insert(t,1,"a")
--@usage insert(t,"z") -- appends "z" to end of array
--@usage insert(t,len(t)+1,nil) -- explicitly append a nil value to t
--@usage insert(t,nil,nil) insert(t); insert(t,nil) -- explicitly append a nil value to t
--@param t pTable
--@param iOrV Starting index for insertion or value- nil or no index implies i=len(t)+1 (i.e. append)
--@param ... one value or nothing
--@return modified pTable t
function pT.insert(t,iOrV,...)
	assert(isPTable(t), "Table is not a registered pTable")
	local lt = len(t)
	local i,v
	if select("#",...) > 0 then
		i = iOrV
		v = select(1,...)
	else
		i = lt+1
		v = iOrV
	end
	i = i or lt+1
	assert(isIndexPlus1(t,i))
	setLen(t, lt+1)
	if i < len(t) then t = asetT_i(t,i+1,agetR_i(t,i,lt)) end -- move 1 up
	aset_i(t,i,v)
	return t
end

--- Inserts the array-elements of a list of pTable's at index i of pTable t.
-- Array-size of t is increased to accomodate the list of values.
-- Existing elements are moved-up - no values are overwritten.
-- (nil-friendly)
--@param t pTable (target)
--@param i Starting index for insertion - nil implies i=len(t)+1 (i.e. append)
--@param ... list of zero, one or more pTables (source) - may include nils, which are ignored.
--@returns modified pTable t
function pT.insertT(t,i,...)
	assert(isPTable(t), "Table t is not a registered pTable")
	-- accommodate inserting into empty, zero-size array
	i = i or len(t)+1
	assert(isIndexPlus1(t,i))
	nts = lenT(...)
	if nts==0 then return t end
	local oldLen = len(t)
	setLen(t, oldLen+nts)     -- extend size
	if(i < oldLen + 1) then 
		t = asetT_i(t,i+nts, agetR_i(t,i,oldLen)) -- move up
	end
	t = asetT_i(t,i,...)           -- insert
	return t
end

--- Append value v to pTable t - array-size is increased.
function pT.append(t,v) return insert(t,v) end
--- Append the array-elements of a list of pTables to pTable t - array-size is increased.
function pT.appendT(t,...) return insertT(t,nil,...) end

-------------------------------------------------------------------------------
-- remove, removeR, removeRL, 

--- Removes array-element from pTable t at index i, 
-- and returns the removed element's value - 
-- t's array size is decreased by one. 
-- (nil-friendly)
--@param t pTable (changed inplace)
--@param i index of element to remove - default is last element.
--@return Removed element value.
function pT.remove(t,i)
	assert(isPTable(t), "Table is not a registered pTable")
	local lt = len(t)
	i = i or lt
	assert(isIndex(t,i))
	local v = aget_i(t,i)
	if i ~= lt then asetT_i(t, i, agetR_i(t, i+1, lt)) end
	setLen(t,lt-1)
	return v
end

--- Removes the range of array-elements from index b till e from pTable t, and returns those removed elements in a new pTable - t's array size is decreased accordingly.
-- (nil-friendly)
--@param t pTable (changed inplace)
--@param b Starting index for removal (default is b=1).
--@param e Last index for removal (default is e=len(t)).
--@return New pTable with removed element value(s) in the array component. 
function pT.removeR(t,b,e)
	assert(isPTable(t), "Table is not a registered pTable")
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b<=e)
	local lt = len(t)
	local n = e-b+1
	local rvs = agetR_i(t,b,e)  -- table with removed values
	if i+n-1 < lt then
		asetT(t,b, agetR_i(t,b+n,lt-b-n+1))
	end
	setLen(t, lt-n)
	return rvs
end

-------------------------------------------------------------------------------
-- Constructors, register/unregister pTables, import/export
-- pack and unpack replacements that are pTable-aware
-- pTable, pTableT, pack, unpack, unregPTable

--- pTable constructor that copies the list arguments into the 
-- array-component of a newly created pTable (identical to pT.pack()).
-- Registers the list size for the array-length.
-- (nil-friendly)
--@param ... List of elements to add to the array-component of the newly created pTable
--@return New pTable
function pT.pTable(...)
	return setLen({...}, select('#', ...), false)
end

--- pTable constructor that registers an existing standard Lua table lt as a pTable while explicitly passing its length/size n.
-- Length/size for table lt has to be passed explicitly as no assumptions about #lt are implicitly trusted/used. (you could use #lt for the argument n value... if you know what you're doing)
--@usage t = pT.pTableT({1,2,nil,4,nil,nil}, 6)  => pTable with array-size 6
--@param lt An standard lua-table - default is {}
--@param n Integer >= 0 - indicates the size of the array-component (default is 0)
--@return pTable lt (unmodified but registered with size n)
function pT.pTableT(lt,n)
	n = (type(lt)=="number" and lt) or n or 0
	lt = (type(lt)=="table" and lt) or {}
	return setLen(lt, n, false)
end

--- pTable constructor (table.pack() replacement), which copies the list arguments into the 
-- array-component of a newly created pTable.
-- Registers the "correct" argument list size for the array-length.
-- (nil-friendly)
--@param ... List of elements to add to the array-component of the newly created pTable
--@return New pTable
function pT.pack(...) return pTable(...) end

--- Unregisters an existing pTable t such that the pTable-functions won't work with this table anymore. 
-- When other functions will change this table's size, thru unregPTable() you can prevent accidental use of the pTable functions with the wrong size. It will force the need to re-register the table with the proper size.
--@param t pTable
--@return t (unmodified but unregistered)
function pT.unregPTable(t)
	tableLenT[t] = nil
	return t
end

--- pTable import constructor, which takes a lua-table with a standardized key that indicates the array-size/length.
--@param lt An standard lua-table with 
--@return pTable lt (length-key has been removed)
function pT.importPTable(lt)
	assert(type(lt)=="table")
	local n = lt[pT.arrayLengthKey]
	assert(n~=nil and isGE0Int(n), "pT.importPTable: provided array-size thru " .. pT.arrayLengthKey .. " is not integer >= 0")
	lt = setLen(lt, n, false)
	lt[pT.arrayLengthKey] = nil  -- remove import length key as it may become out-of-sync
	return lt
end

--- pTable export function that adds a standardized length-key with the value of pT.len(t),  unregisters t as a pTable, and returns the resulting normal lua-table.
--@param pTable 
--@return Lua-table (pTable-unregistered with a length-key entry added)
function pT.exportPTable(t)
	assert(isPTable(t))
	t[pT.arrayLengthKey] = len(t)
	unregPTable(t)
	return lt
end

-------------------------------------------------------------------------------
-- Iterators to augment the pairs()      (...never, ever use Lua's ipairs()!!!)
-- arrayPairs, rarrayPairs, arrayPairsSkipNil, mapPairs, 
-- tablePairs, listPairs/apairs, pT.listPairsSkipNil
-------------------------------------------------------------------------------

-- Local helper function for "arrayPairs()"
function pT_i.arrayPairs_iter(t, i)
	i = i + 1
	if i <= (len(t) or 0) then
		return i, aget_i(t,i)
	end
end

--- ipairs-replacement for pTable t's array-component that
-- iterates up from t[1] till t[len(t)], and will return possible nil-values.
--@param t pTable
function pT.arrayPairs(t, i)
	return arrayPairs_iter, t, 0
end

-- Local helper function for "rarrayPairs()"
function pT_i.rarrayPairs_iter(t, i)
	i = i - 1
	if i >= 1 then
		return i, aget_i(t,i)
	end
end

--- reverse ipairs-replacement for pTable t's
-- array-component and iterates down from t[len(t)] till t[1], and will return possible nil-values - safe(r) element removal.
--@param t pTable
function pT.rarrayPairs(t, i)
	return rarrayPairs_iter, t, len(t)+1
end

-- Local helper function for "arrayPairsSkipNil()"
function pT_i.arrayPairsSkipNil_iter(t, i)
	i = i + 1
	while i <= (len(t) or 0) do
		local v = aget_i(t,i)
		if v ~= nil then return i, v end
		i = i + 1
	end
end

--- ipairs-replacement for pTable t's array-component that
-- iterates up from t[1] till t[len(t)], and will skip any nil-values.
function pT.arrayPairsSkipNil(t, i)
	return arrayPairsSkipNil_iter, t, 0
end

--- Next-like iterator that excludes any keys k of pTable t that are array indices - 
-- Only iterates over the map-component of the pTable.
function pT.mapNext(t, k)
	k = next(t, k)
	while k do
		if not isIndex(t,k) then break end
		k = next(t, k)
	end
	return k, t[k]
end

--- Pairs-like iterator that excludes any keys k of pTable t that are array indices - 
-- only iterates over the map-component of the pTable.
function pT.mapPairs(t)
	return mapNext, t, nil
end

-- Helper function for listPairs()
function pT_i.listPairs_iter(a, i)
	if i < a.n then return i+1,a[i+1] end
end

--- ipairs-like iterator for varargs (friendly to nils).
--@usage function f(...) for i,a in listPairs(...) do print(i, a) end end
--@param ... vararg list (may include nils)
function pT.listPairs(...)
	return listPairs_iter, {n=select('#', ...), ...}, 0
end
pT.apairs = pT.listPairs  -- alias to accommodate common convention (a = args)

-- Helper function for listPairsSkipNil()
function pT_i.listPairsSkipNil_iter(a, i)
	while i < a.n do
		local v = a[i+1]
		if v ~= nil then return i+1, v end
		i = i+1
	end
end

--- Iterator for varargs (friendly to nils).
--@usage function f(...) for i,a in apairs(...) do print(i, a) end end
--@param ... vararg list (may include nils)
function pT.listPairsSkipNil(...)
	return listPairsSkipNil_iter, {n=select('#', ...), ...}, 0
end

-------------------------------------------------------------------------------
-- Common collector & filter functions for tables
-- tableKeysT, tableKeysL, isMapKey, mapKeysT, mapKeysL, mapValuesT, 
-- mapValuesT, arrayValuesS
-------------------------------------------------------------------------------

--- Returns a pTable with a list of all the "lua-defined" keys in table t.
--@param t lua-table or pTable.
--@return new pTable t's keys collected in the array-component.
function pT.tableKeys(t)
	local tmp = pTable()
	for k,v in pairs(t) do insert(tmp,k) end
	return tmp
end

--- Returns whether k is a true map-key of pTable t.
--@param t lua-table or pTable.
--@return boolean - true if not isIndex(t,k) and t[k] ~= nil.
function pT.isMapKey(t,k)
	return k~=nil and not isIndex(t,k) and t[k] ~= nil
end

--- Returns a pTable with a list of all the keys of the map-component of pTable t without the array-indices.
--@param t pTable.
--@return new pTable t's map-keys collected in the array-component.
function pT.mapKeys(t)
	local tmp = pTable()
	for k,v in pairs(t) do 
		if not isIndex(t,k) then insert(tmp,k) end
	end
	return tmp
end

--- Returns a pTable with a list of all the values of the map-component of pTable t without the array-indices.
--@param t pTable.
--@return new pTable t's map-values collected in the array-component.
function pT.mapValues(t)
	local tmp = pTable()
	for k,v in pairs(t) do 
		if not isIndex(t,k) then insert(tmp,v) end
	end
	return tmp
end

--- Returns a pTable with a map-set of all the array-values of pTable t.
--@param t pTable.
--@return new pTable with a map-set of t's array-values.
function pT.arrayValuesS(t)
	local tmp = pTable()
	for i,v in arrayPairsSkipNil(t) do tmp[v] = true end
	return tmp
end

--- Returns a pTable with a map-set of all the map-values of pTable t.
--@param t pTable.
--@return new pTable with a map-set of t's map-values.
function pT.mapValuesS(t)
	local tmp = pTable()
	for k,v in pairs(t) do if not isIndex(t,k) then tmp[v] = true end end
	return tmp
end

-------------------------------------------------------------------------------

--- Removes all the elements with nil-values from the array-component of pTable t.
--@param t pTable
--@return (possibly modified) pTable t
function pT.removeNils(t)
	assert(isPTable(t), "Table is not a registered pTable")
	for i,v in rarrayPairs(t) do 
		if v==nil then 
			remove(t,i) 
		end 
	end
	return t
end

--- String-concatenates all elements of the array-component of t from b till e and inserting the seperator sep between the elements (table.concat replacement). Nil-values are not allowed in the specified range.
--@param t pTable
--@param sep seperator/delimiter string - default is "" (empty string).
--@param b start of range - 1 <= b <= len(t) - defaults to 1.
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t).
--@return string - result from concatenation
function pT.concat(t,sep,b,e)
	if(len(t)==0)then return "" end
	b = b or 1
	e = e or len(t)
	assert(isIndex(t,b) and isIndex(t,e) and b <= e, "pT.concat: range invalid - isIndex(t,b) and isIndex(t,e) and b <= e")
	return table.concat(t, sep, b, e)
end

--- Sorts the array-component of pTable t in-place - (uses table.sort() under-the-covers).
--@param t pTable
--@param comp comparison function (optional - default: "<").
--@return sorted/modified pTable t
function pT.sort(t,comp)
	if(lenEqLuaLen(t))then
		table.sort(t,comp)
	elseif(len(t) < #t)then   -- corner case where t[len(t)+1] ~= nil
		-- sort copy of t and then copy back into t
		local tmp = arrayCopy(t)
		assert(lenEqLuaLen(tmp)) -- you never know...
		table.sort(tmp, comp)
		asetT(t,1,tmp)
	else error("pT.sort: cannot use table.sort when len(t) > #t")
	end
	return t
end

-------------------------------------------------------------------------------
-- copy, compare, deepCopy and deepCompare 
-------------------------------------------------------------------------------

--- Returns a shallow copy of the array-component of pTable t - circular/self reference aware - copy will optionally share metatable with source t - no map entries are copied.
--@param t pTable.
--@param cpMT boolean to indicate whether metatable should be shared - default is false (no MT-sharing).
--@return new pTable with shallow copy of array-component of t
function pT.arrayCopy(t, cpMT)
	assert(isPTable(t))
	local res = pTableT(len(t))  -- result, i.e. the copied table
	-- have to share the metatable before the element-copy because the index/newindex 
	-- could have been modified (maybe proxy-table) - scary stuff...
	if(cpMT == true)then res = setmetatable(res,getmetatable(t)) end
	-- register the result-table as a pTable if source-table is one
	for i,v in arrayPairsSkipNil(t) do
		if(type(v) == "table" and v==t)then aset_i(res,i,res)
		else aset_i(res,i,v) end
	end
	return res
end

--- Returns a shallow copy of object t - pTable-aware - circular/self reference aware - copy will share metatable with source t.
--@param t any kind of object.
--@param cpMT boolean to indicate whether metatable should be shared - default is false (no MT-sharing).
--@return new shallow-copied object
function pT.copy(t, cpMT)
	if type(t) ~= "table" then return t end
	local res = {}  -- result, i.e. the copied table
	-- have to share the metatable before the element-copy because the index/newindex 
	-- could have been modified (maybe proxy-table) - scary stuff...
	if(cpMT == true)then res = setmetatable(res,getmetatable(t)) end
	-- register the result-table as a pTable if source-table is one
	if isPTable(t) then pTableT(res,len(t)) end
	for k,v in pairs(t) do
		local kr,vr
		if(type(k) == "table" and k==t)then kr = res
		else kr = k end
		if(type(v) ~= "table" and v==t)then vr = res
		else vr = v end
		res[kr] = vr  -- final element assignment for result-table
	end
	return res
end

--- Returns result from a shallow-compare of object t1 and t2 - compare by ref for table elements - one-level deep - circular/self reference detection.
--@param t1 any kind of object.
--@param t2 any kind of object to shallow-compare with t1.
--@return boolean result of shallow-comparison.
function pT.compare(t1, t2)
	if(type(t1)~=type(t2))then return false end
	if(type(t1)~="table")then return t1==t2 end
	-- we have only tables to compare
	if(t1==t2)then return true end
	-- pTable specific comparisons
	local pt1,pt2 = isPTable(t1), isPTable(t2)
	if(((pt1 and not pt2) or (not pt1 and pt2))  or
		(pt1 and pt2 and len(t1)~=len(t2)) or 
		(tableLen(t1) ~= tableLen(t2)))then return false end
	-- so, t1 and t2 are both tables with equal number of elements
	-- and they could both be pTables with equal array-length
	local vt2 = t2[t2]  -- self-reference if not-nil
	for k1,v1 in pairs(t1) do
		local v12 = t2[k1]
		if(v12~=nil)then
			-- check if associated values are equal or are both circular
			-- do not allow cross-ref between t1 and t2
			if((v1==t2 or v12==t1) or 
			   (not (v1==v12 or (v1==t1 and v12==t2))))then return false end
		else  -- still possible that both t1&t2 have circular-keys
			if(type(k1)~="table" or k1~=t1 or vt2==nil or vt2==t1 or v1==t2)then
				return false  -- key is no table and not circular k1: give up
			else
				if(not (v1==vt2 or (v1==t1 and vt2==t2)))then return false end
					-- fall thru loop for (convoluted) circular equality
			end
		end
	end  -- true for this k1 - back for next iteration
	-- all comparisons yielded true for t1&t2
	return true
end

--- Returns a deep copy of object o - iterates "down" the tree if o is a table - pTable-aware - multiple&circular/self reference aware - copy will share metatable with source.
--@param o any kind of object.
--@param cpMT boolean to indicate whether metatable should be shared - default is false (no MT-sharing).
--@return new deep-copied object
function pT.deepCopy(o, cpMT)
	local trefs = pTable() -- maintain self-references map
	return deepCopy_helper(o, trefs, cpMT)
end

function pT_i.deepCopy_helper(t, trefs, cpMT)
	-- non-tables are simply returned - by ref or by value depending on type 
	if type(t) ~= "table" then return t end
	-- maintain the table references with their associated copied-table-refs
	local res  -- result, i.e. the deep-copied table
	if trefs[t] then
		-- already copied this table before, so only copy the previous reference
		res = trefs[t] 
	else
		-- true copy is needed
		res = {}
		trefs[t] = res  -- record the mapping for self/circular-reference detection
		-- have to share the metatable before the element-copy because the index/newindex 
		-- could have been modified (maybe proxy-table) - scary stuff...
		if(cpMT==true)then res = setmetatable(res, getmetatable(t)) end
		-- register the result-table as a pTable if source-table is one
		if isPTable(t) then pTableT(res,len(t)) end
		for k,v in pairs(t) do
			local kr,vr
			-- recursively deepCopy both the key and value for the result-table
			kr = deepCopy_helper(k,trefs, cpMT)
			vr = deepCopy_helper(v,trefs, cpMT)
			res[kr] = vr -- final element assignment for result-table
		end
	end
	return res
end

--- Returns result from a deep-compare of object t1 and t2 - compare by value for table elements - iterates down the trees - circular/self and repeated reference detection.
--@param t1 any kind of object.
--@param t2 any kind of object to deep-compare with t1.
--@return boolean result of deep-comparison.
function pT.deepCompare(t1, t2)
	local trefs = pTable()
	return deepCompare_helper(t1, t2, trefs)
end

function pT_i.deepCompare_helper(t1, t2, trefs)
	if(type(t1)~=type(t2))then return false end
	if(type(t1)~="table")then return t1==t2 end
	-- we have only tables to compare
	-- see if we can go home early
	if(t1==t2)then return true end
	-- make sure that we notice circular or before seen comparisons
	trefs[t1] = trefs[t1] or pTable()
	if(trefs[t1][t2]==true)then return true  -- compared before
	else trefs[t1][t2]=true end  -- register this comparison
	-- pTable specific comparisons
	local pt1,pt2 = isPTable(t1), isPTable(t2)
	if(((pt1 and not pt2) or (not pt1 and pt2))  or
		(pt1 and pt2 and len(t1)~=len(t2)) or 
		(tableLen(t1) ~= tableLen(t2)))then return false end
	-- so, t1 and t2 are both tables with equal number of elements
	-- and they could both be pTables with equal array-length
	for k1,v1 in pairs(t1) do
		local v12 = t2[k1]
		if(v12~=nil)then
			-- if associated values are equal fall thru loop
			if(not deepCompare_helper(v1, v12, trefs))then return false end
		else
			if(type(k1)~="table")then
				return false  -- key is no table: give up
			else
				-- try deepCompare k1 with the keys from t2
				local kres = false  -- if kres remains false, then no positive compare found
				for k2,v2 in pairs(t2) do
					if(deepCompare_helper(k1,k2,trefs) and 
					   deepCompare_helper(v1,v2,trefs))then 
						kres = true
						break -- positive compare for k1 - break k2-loop
					end
				end
				-- if no positive hits on deep key-compare, give up
				if(not kres)then return false end
			end  -- still true for deep key-compare
		end  -- still true for either deep normal or key compare
	end  -- true for this k1 - back for next iteration
	-- all deep comparisons yielded true for t1&t2
	return true 
end

-------------------------------------------------------------------------------
-- General helper function to assess Lua-tables and associated predictability
-- nonNilLen, lenEqLuaLen, hasNilValues

--- Returns the non-nil length/size of the array component of a standard Lua table
-- Simply loops from index 1 until the first nil-valued element.
-- Note that this function does not set any length/size for t, but merely scans.
--@param lt table
--@return size of non-nil array (integer >= 0)
function pT.nonNilLen(lt)
	assert(type(t) == "table")
	local n = 1
	while(lt[n] ~= nil) do n=n+1 end
	return n - 1
end

--- Returns whether pTable's len(t) is equal to Lua's notion of array-size #t -
-- if so, then some Lua-functions may have predictable result.
--@param t pTable
--@return Boolean: len(t)==#t
function pT.lenEqLuaLen(t) return len(t) == #t end

--- Returns true when the array-component of pTable t includes any nil values.
--@param t pTable
--@return boolean indicating whether t includes array-elements with nil value.
function pT.hasNilValues(t)
	for i,v in arrayPairs(t) do if v==nil then return true end end
	return false
end

-------------------------------------------------------------------------------
-- general "internal" utility functions
-- pT_i.isGT0Int, pT_i.isGE0Int, pT_i.isIndexPlus1

--- local convenience function to test whether k is integer and >0
function pT_i.isGT0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k > 0  
end

--- local convenience function to test whether k is integer and >=0
function pT_i.isGE0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k >= 0  
end

--- Returns whether the key k is a valid index for the array-component of table t including len(t) + 1, which is used by insert() to append to the array.
--@param t table instance
--@param k a possible array index value including len(t)+1
--@return boolean - true indicates k is integer and 1 <= k <= len(t)+1
function pT_i.isIndexPlus1(t,k)
	return isGT0Int(k) and k <= len(t) + 1
end

-------------------------------------------------------------------------------
-- utility functions to manage declarations of names in namespace 

--- Given a function-map (table) and a prefix (prefix.fname map), return 3 strings that hold a global assignment (orig_fname = fname), a local assignment (local fname), and a function-map to local assignement (fname = prefix.fname).
-- is useful to generate the correct assignment statements to keep the namespace clean
function pT_i.assignGlobalsLocalsFunctionMap(t, pre)
	local function komma(i) if(i>1)then return ", " else return "" end end
	local gassign, ldeclare, massign, lmassign
	local fnames,onames, pnames = pTable(),pTable(),pTable()
	-- collect all string-keys
	for k,v in pairs(t) do if(type(k)=="string")then insert(fnames,k) end end
	table.sort(fnames)  -- we "know" that there are no nils in fnames
	for k,v in pairs(fnames) do insert(onames,"orig_" .. v); insert(pnames, pre .. v) end	
	local sfnames = concat(fnames,",")
	local sonames = concat(onames,",")
	local spnames = concat(pnames,",")
	gassign = "local " .. sonames .. " = " .. sfnames
	ldeclare = "local " .. sfnames
	massign = sfnames .. " = " .. spnames
	lmassign = "local " .. massign
	return gassign,ldeclare,massign,lmassign
end

--- Array-dump/pretty-print - debugging aid
--@usage arrayPP(pTable(nil,2,3,nil,5,nil)) => [ %:6, 2:2, 3:3, 5:5 ]
function pT_i.arrayPP(t)
	local function pv(v)
		if type(v)~="number" then 
			if v == nil then return tostring(v)
			else return "\""..tostring(v).."\"" end
		else return v end
	end
	local tmp = pTable("%:"..pT.len(t))
	for i,v in arrayPairsSkipNil(t) do append(tmp, i..":"..pv(v)) end
	print("[ " .. concat(tmp,", ") .. " ]")
end

-------------------------------------------------------------------------------
-- local to function-map declarations

-- map function-map names to locals
aget,agetR,agetT,apairs,append,appendT,areset,aresetR,aresetT,arrayCopy,arrayLengthKey,arrayPairs,arrayPairsSkipNil,arrayValuesS,aset,asetT,compare,concat,copy,deepCompare,deepCopy,exportPTable,getLen,hasNilValues,importPTable,insert,insertT,isIndex,isMapKey,isPTable,len,lenEqLuaLen,lenT,list,listPairs,listPairsSkipNil,mapKeys,mapLen,mapNext,mapPairs,mapValues,mapValuesS,nonNilLen,pT_i,pTable,pTableT,pack,rarrayPairs,remove,removeNils,removeR,sort,tableKeys,tableLen,unpack,unregPTable = pT.aget,pT.agetR,pT.agetT,pT.apairs,pT.append,pT.appendT,pT.areset,pT.aresetR,pT.aresetT,pT.arrayCopy,pT.arrayLengthKey,pT.arrayPairs,pT.arrayPairsSkipNil,pT.arrayValuesS,pT.aset,pT.asetT,pT.compare,pT.concat,pT.copy,pT.deepCompare,pT.deepCopy,pT.exportPTable,pT.getLen,pT.hasNilValues,pT.importPTable,pT.insert,pT.insertT,pT.isIndex,pT.isMapKey,pT.isPTable,pT.len,pT.lenEqLuaLen,pT.lenT,pT.list,pT.listPairs,pT.listPairsSkipNil,pT.mapKeys,pT.mapLen,pT.mapNext,pT.mapPairs,pT.mapValues,pT.mapValuesS,pT.nonNilLen,pT.pT_i,pT.pTable,pT.pTableT,pT.pack,pT.rarrayPairs,pT.remove,pT.removeNils,pT.removeR,pT.sort,pT.tableKeys,pT.tableLen,pT.unpack,pT.unregPTable	

-- map function-map names to locals
agetR_i,aget_i,aresetR_i,arrayPP,arrayPairsSkipNil_iter,arrayPairs_iter,asetT_i,aset_i,assignGlobalsLocalsFunctionMap,deepCompare_helper,deepCopy_helper,isGE0Int,isGT0Int,isIndexPlus1,listPairsSkipNil_iter,listPairs_iter,rarrayPairs_iter,setLen = pT_i.agetR_i,pT_i.aget_i,pT_i.aresetR_i,pT_i.arrayPP,pT_i.arrayPairsSkipNil_iter,pT_i.arrayPairs_iter,pT_i.asetT_i,pT_i.aset_i,pT_i.assignGlobalsLocalsFunctionMap,pT_i.deepCompare_helper,pT_i.deepCopy_helper,pT_i.isGE0Int,pT_i.isGT0Int,pT_i.isIndexPlus1,pT_i.listPairsSkipNil_iter,pT_i.listPairs_iter,pT_i.rarrayPairs_iter,pT_i.setLen	

-------------------------------------------------------------------------------
-- finally... return the main function-map

return pT
