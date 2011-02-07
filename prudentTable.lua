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

-- make sure we keep the globals accessible thru "orig_*" aliases
local orig_aget, orig_agetLL, orig_agetLT, orig_agetRL, orig_agetRT, orig_apairs, orig_arrayCopy, orig_arrayLengthKey, orig_arrayPairs, orig_arrayPairsSkipNil, orig_arrayValuesS, orig_aset, orig_asetL, orig_asetT, orig_deepCompare, orig_deepCopy, orig_getLen, orig_insert, orig_insertL, orig_insertT, orig_isIndex, orig_isLuaTableLenOK, orig_isMapKey, orig_isPTable, orig_len, orig_lenT, orig_listPairs, orig_listPairsSkipNil, orig_mapKeysL, orig_mapKeysT, orig_mapLen, orig_mapNext, orig_mapPairs, orig_mapValuesL, orig_mapValuesS, orig_mapValuesT, orig_nonNilLen, orig_pT_i, orig_pTableL, orig_pTableT, orig_pack, orig_packT, orig_rarrayPairs, orig_remove, orig_removeNils, orig_removeRL, orig_removeRT, orig_shallowCompare, orig_shallowCopy, orig_tableKeysL, orig_tableKeysT, orig_tableLen, orig_unpack, orig_unregPTable = aget, agetLL, agetLT, agetRL, agetRT, apairs, arrayCopy, arrayLengthKey, arrayPairs, arrayPairsSkipNil, arrayValuesS, aset, asetL, asetT, deepCompare, deepCopy, getLen, insert, insertL, insertT, isIndex, isLuaTableLenOK, isMapKey, isPTable, len, lenT, listPairs, listPairsSkipNil, mapKeysL, mapKeysT, mapLen, mapNext, mapPairs, mapValuesL, mapValuesS, mapValuesT, nonNilLen, pT_i, pTableL, pTableT, pack, packT, rarrayPairs, remove, removeNils, removeRL, removeRT, shallowCompare, shallowCopy, tableKeysL, tableKeysT, tableLen, unpack, unregPTable	

-- localize all the fnames
local aget, agetLL, agetLT, agetRL, agetRT, apairs, arrayCopy, arrayLengthKey, arrayPairs, arrayPairsSkipNil, arrayValuesS, aset, asetL, asetT, deepCompare, deepCopy, getLen, insert, insertL, insertT, isIndex, isLuaTableLenOK, isMapKey, isPTable, len, lenT, listPairs, listPairsSkipNil, mapKeysL, mapKeysT, mapLen, mapNext, mapPairs, mapValuesL, mapValuesS, mapValuesT, nonNilLen, pT_i, pTableL, pTableT, pack, packT, rarrayPairs, remove, removeNils, removeRL, removeRT, shallowCompare, shallowCopy, tableKeysL, tableKeysT, tableLen, unpack, unregPTable	

-- make sure we keep the globals accessible thru "orig_*" aliases
local orig_agetRT_i, orig_aget_i, orig_arrayPairsSkipNil_iter, orig_arrayPairs_iter, orig_asetT_i, orig_aset_i, orig_assignGlobalsLocalsFunctionMap, orig_deepCompare_helper, orig_deepCopy_helper, orig_isGE0Int, orig_isGT0Int, orig_isIndexPlus1, orig_listPairsSkipNil_iter, orig_listPairs_iter, orig_rarrayPairs_iter, orig_setLen = agetRT_i, aget_i, arrayPairsSkipNil_iter, arrayPairs_iter, asetT_i, aset_i, assignGlobalsLocalsFunctionMap, deepCompare_helper, deepCopy_helper, isGE0Int, isGT0Int, isIndexPlus1, listPairsSkipNil_iter, listPairs_iter, rarrayPairs_iter, setLen	

-- localize all the fnames
local agetRT_i, aget_i, arrayPairsSkipNil_iter, arrayPairs_iter, asetT_i, aset_i, assignGlobalsLocalsFunctionMap, deepCompare_helper, deepCopy_helper, isGE0Int, isGT0Int, isIndexPlus1, listPairsSkipNil_iter, listPairs_iter, rarrayPairs_iter, setLen	

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

-- local convenience function to test whether k is integer and >0
function pT_i.isGT0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k > 0  
end

-- local convenience function to test whether k is integer and >=0
function pT_i.isGE0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k >= 0  
end

--- Returns whether the key k is a valid index for the array-component of pTable t.
--@param t pTable
--@param k possible array index value
--@return boolean - true indicates k is integer and 1 <= k <= pT.len(t)
function pT.isIndex(t,k)
	return isGT0Int(k) and k <= len(t)
end

-- Returns whether the key k is a valid index for the array-component of table t including len(t) + 1, which is used by insert() to append to the array.
--@param t table instance
--@param k a possible array index value including len(t)+1
--@return boolean - true indicates k is integer and 1 <= k <= len(t)+1
function pT_i.isIndexPlus1(t,k)
	return isGT0Int(k) and k <= len(t) + 1
end

--- Returns whether t is registered as a pTable.
--@param t possible pTable
--@return boolean - true indicates t has been registered as a pTable
function pT.isPTable(t) 
	return type(t)=="table" and tableLenT[t] ~= nil 
end

--- Returns the non-nil length/size of the array component of a standard Lua table
-- Simply loops from index 1 until the first nil-valued element.
-- Note that this function does not set any length/size for t, but merely scans.
--@param lt table
--@return size of non-nil array (integer >= 0)
function pT.nonNilLen(lt)
	assert(type(t) == "table")
	local n = 1
	while lt[n] ~= nil do n=n+1 end
	return n - 1
end

--- Returns whether the Lua table lt's length may be ambiguous by comparing lt's non-nil array size (nonNilLen(t)) with #lt. 
-- This could help determine whether the #t is the length to use for an unknown table.
--@param lt "standard" lua-table
--@return Boolean: true if lt's non-nil length equals #lt
function pT.isLuaTableLenOK(lt)
	return nonNilLen(lt) == #lt
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
--@returns total number of array-elements of all pTables.
function pT.lenT(...)
	local ntin = 0
	for i,ti in listPairsSkipNil(...) do
		assert(isPTable(ti))
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

-- Set the length/size of the array component of table t and registers t as a pTable.
-- Thru setLen(), a Lua-table t is "registered" as a pTable.
-- If size is increased, then existing map entries become part of the array.
-- If size is decreased, then some array components become map entries.
-- If resetValues==true then all new array/map elements get reset to nil.
-- This reset is to avoid any inconsistencies caused by unexpected new map/array elements.
-- Note, however, that no element values are reset during the very first registration - implicit resetValues=false for first registration.
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

--- Registers an existing standard Lua table lt as a pTable while explicitly providing its length/size n.
-- Length/size for table lt has to be passed explicitly as no assumptions about #lt are implicitly trusted/used. (you could use #lt for the argument n value... if you know what you're doing)
--@param lt An standard lua-table - default is {}
--@param n Integer >= 0 - indicates the size of the array-component (default is 0)
--@return pTable lt (unmodified but registered with size n)
function pT.pTableT(lt,n)
	n = (type(lt)=="number" and lt) or n or 0
	lt = (type(lt)=="table" and lt) or {}
	return setLen(lt, n, false)
end

--- Unregisters an existing pTable t such that the pTable-functions won't work with this table anymore. 
-- When other functions will change this table's size, thru unregPTable() you can prevent accidental use of the pTable functions with the wrong size. It will force the need to re-register the table with the proper size.
--@param t pTable
--@return t (unmodified but unregistered)
function pT.unregPTable(t)
	tableLenT[t] = nil
	return t
end

-------------------------------------------------------------------------------
-- aget, agetLT, agetLL, agetRT, agetRL

--- Returns the array-element value at index i of pTable t.
--@param t pTable
--@param i index (1 <= i <= len(t))
--@return value at t[i]
function pT.aget(t,i)
	assert(isPTable(t), "aget: Table t is not a registered pTable")
	assert(isIndex(t,i), "aget: Index i not within 1 <= i <= len(t)")
	return aget_i(t,i)
end

-- Internal function without assertions - returns the element value at index i of pTable t.
--@param t pTable
--@param i index (1 <= i <= len(t))
--@return value at t[i]
function pT_i.aget_i(t,i)
	return t[i]
end

--- For a list of indices i,...,j, of the array-component of pTable t, return the associated values in the array-component of a pTable.
--@param t pTable
--@param ... list of one or more indices for pTable t's array-component
--@return pTable where the array-component holds the values associated with the given list of indices
function pT.agetLT(t,...)
	assert(isPTable(t), "agetLT: Table t is not a registered pTable")
	local n = select("#", ...)
	assert(n > 0, "agetLT: minimum of at least one index")
	tmp = pTable(n)
	for i,index in listPair(...) do
		assert(isIndex(t,index))
		aset_i(tmp,i,aget_i(t,index))
	end
	return tmp
end

--- For a list of indices i,...,j, of the array-component of pTable t, return the associated values as a list.
--@param t pTable
--@param ... list of one or more indices for pTable t's array-component
--@return list of values associated with the given list of indices
function pT.agetLL(t,...)
	local tmp = agetLT(t,...)
	return unpack(tmp)
end

--- For the range of array-index b till e of pTable t, returns an array of element values as a new pTable.
-- Range must not extend array boundaries.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1.
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t).
--@return new pTable with requested values in the array-components.
function pT.agetRT(t,b,e)
	assert(isPTable(t), "Table is not a registered pTable")
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b<=e)
	return agetRT_i(t,b,e)
end

-- For the range of array-index b till e of pTable t, returns an array of element values as a new pTable without type and array bound checks.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1.
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t).
--@return new pTable with requested values in the array-components.
function pT_i.agetRT_i(t,b,e)
	local n = e-b+1
	if n==1 then return pack(aget_i(t,b)) end
	local tmp = setLen(pack(), n)
	for j = 1,n do aset_i(tmp, j, aget_i(t,b+j-1)) end
	return tmp
end

--- For the range of array-index b till e of pTable t, returns the list of element values.
-- Range must not extend array boundaries.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t)
--@return list of zero, one or more values (including possible nils)
function pT.agetRL(t,b,e)
	local tmp = agetRT(t,b,e)
	-- Note that this is the "original" unpack and not the pT.unpack!!
	return orig_unpack(tmp,1,e-b+1)
--	return unpack(tmp,1,e-b+1)
end

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

--- Copies the array elements of pTables t1...tn into the array-component of pTable t starting at index i.
-- t's array-size must be able to accomodate the new elements as it does not grow automatically.
--@param t pTable (target)
--@param i target start-index
--@param ... list of zero, one or more pTable's (source) - may include nils, which are ignored.
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
	for i,ti in listPairs(...) do
		if ti ~= nil then
			for j,vj in arrayPairs(ti) do
				aset_i(t,i,vj)
				i = i + 1
			end
		end
	end
	return t
end

--- Copies a list of values into the array-component of pTable t starting at index i
-- Array-size must be able to accomodate the list as it does not grow automatically.
--@param t pTable
--@param i target start-index
--@param ... list of zero, one or more values
--@return modified pTable t
function pT.asetL(t,i,...)
	return asetT(t,i,pack(...))
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
	if i < len(t) then t = asetT_i(t,i+1,agetRT(t,i,lt)) end -- move 1 up
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
		t = asetT_i(t,i+nts, agetRT(t,i,oldLen)) -- move up
	end
	t = asetT_i(t,i,...)           -- insert
	return t
end

--- Inserts a list of values at index i of pTable t - Array-size is increased to accomodate the list of values.
-- Existing elements are moved-up - no values are overwritten.
-- (nil-friendly)
--@param t pTable
--@param i Starting index for insertion - nil implies i=len(t)+1 (i.e. append)
--@param ... list of zero, one or more values
--@return modified pTable t
function pT.insertL(t,i,...)
	assert(isPTable(t), "Table is not a registered pTable")
	local t1 = setLen({...}, select('#', ...), false)
	return insertT(t,i,t1)
end

-------------------------------------------------------------------------------
-- remove, removeRT, removeRL, 

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
	if i ~= lt then asetT_i(t, i, agetRT(t, i+1, lt)) end
	setLen(t,lt-1)
	return v
end

--- Removes the range of array-elements from index b till e from pTable t, and returns those removed elements in a new pTable - t's array size is decreased accordingly.
-- (nil-friendly)
--@param t pTable (changed inplace)
--@param b Starting index for removal (default is b=1).
--@param e Last index for removal (default is e=len(t)).
--@return New pTable with removed element value(s) in the array component. 
function pT.removeRT(t,b,e)
	assert(isPTable(t), "Table is not a registered pTable")
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b<=e)
	local lt = len(t)
	local n = e-b+1
	local rvs = agetRT(t,b,e)  -- table with removed values
	if i+n-1 < lt then
		asetT(t,b, agetRT(t,b+n,lt-b-n+1))
	end
	setLen(t, lt-n)
	return rvs
end

--- Removes the range of array-elements from index b till e from pTable t, and returns those removed elements as a list - t's array size is decreased accordingly.
-- (nil-friendly)
--@param t pTable (changed inplace).
--@param b Starting index for removal (default is b=1).
--@param e Last index for removal (default is e=len(t)).
--@return List of removed element value(s).
function pT.removeRL(t,b,e)
	--assert(isPTable(t), "Table is not a registered pTable")
	return unpack(removeAsTable(t,b,e))
end

-------------------------------------------------------------------------------
-- pack and unpack replacements that are pTable-aware
-- pack, unpack 

--- pTable constructor (table.pack() replacement), which copies the list arguments into the 
-- array-component of the newly created pTable.
-- Registers the "correct" argument list size for the array-length.
-- (nil-friendly)
--@param ... List of elements to add to the array-component of the newly created pTable
--@return New pTable
function pT.pack(...)
	return setLen({...}, select('#', ...), false)
end
pT.pTableL = pT.pack

--- For the range of array-index b till e of pTable t, returns an list of element values - "pTable-aware" table.unpack() replacement.
-- Note that pT.unpack does NOT use any "t.n" that may be used to indicates the array-length.
--@param t pTable
--@param b start of range to copy - defaults to 1
--@param e end of range to copy - defaults to pT.len(t)
--@return list of values representing t[b:e] - may include nils
function pT.unpack(t,b,e)
	assert(isPTable(t), "Table is not a registered pTable")
	if len(t)==0 then return end -- return "nothing"
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b <= e , "pT.unpack: range arguments not proper array-indices, or begin > end")
	return agetRL(t,b,e) 
end

--- pTable constructor, which copies all the elements of the argument-list of pTable's 
-- into the array-component of a newly created pTable - essentially copies and concatenates the pTable-arrays into a new pTable.
-- Note that all map-entries of the source-pTable's are ignored.
-- (nil-friendly)
--@param ... List of pTables - may include nils, which are ignored.
--@return Newly created pTable instance
function pT.packT(...)
	local nts = lenT(...)
	local t = setLen({},nts)
	return asetT_i(t,...)
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
function pT.tableKeysT(t)
	local tmp = pack()
	for k,v in pairs(t) do insert(tmp,k) end
	return tmp
end

--- Returns a list of all the "lua-defined" keys in table t.
--@param t lua-table or pTable.
--@return list of t's keys .
function pT.tableKeysL(t)
	return unpack(tableKeysT(t))
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
function pT.mapKeysT(t)
	local tmp = pack()
	for k,v in pairs(t) do 
		if not isIndex(t,k) then insert(tmp,k) end
	end
	return tmp
end

--- Returns a list of all the keys of the map-component of pTable t without the array-indices.
--@param t pTable.
--@return list of t's map-keys.
function pT.mapKeysL(t)
	return unpack(mapKeysT(t))
end

--- Returns a pTable with a list of all the values of the map-component of pTable t without the array-indices.
--@param t pTable.
--@return new pTable t's map-values collected in the array-component.
function pT.mapValuesT(t)
	local tmp = pack()
	for k,v in pairs(t) do 
		if not isIndex(t,k) then insert(tmp,v) end
	end
	return tmp
end

--- Returns a list of all the values of the map-component of pTable t without the array-indices.
--@param t pTable.
--@return list of t's map-keys.
function pT.mapValuesL(t)
	return unpack(mapValuesT(t))
end

--- Returns a pTable with a map-set of all the array-values of pTable t.
--@param t pTable.
--@return new pTable with a map-set of t's array-values.
function pT.arrayValuesS(t)
	local tmp = pack()
	for i,v in arrayPairsSkipNil(t) do tmp[v] = true end
	return tmp
end

--- Returns a pTable with a map-set of all the map-values of pTable t.
--@param t pTable.
--@return new pTable with a map-set of t's map-values.
function pT.mapValuesS(t)
	local tmp = pack()
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
		if v==nil then remove(t,i) end 
	end
	return t
end

-------------------------------------------------------------------------------
-- shallowCopy, shallowCompare, deepCopy and deepCompare 
-------------------------------------------------------------------------------

--- Returns a shallow copy of the array-component of pTable t - circular/self reference aware - copy will share metatable with source t - no map entries are copied.
--@param t pTable.
--@param cpMT boolean to indicate whether metatable should be shared - default is false (no MT-sharing).
--@return new pTable with shallow copy of array-component of t
function pT.arrayCopy(t, cpMT)
	assert(isPTable(t))
	local res = pTableT(len(t))  -- result, i.e. the copied table
	-- have to share the metatable before the element-copy because the index/newindex 
	-- could have been modified (maybe proxy-table) - scary stuff...
	if(cpMT==true)then res = setmetatable(res,getmetatable(t)) end
	-- register the result-table as a pTable if source-table is one
	for i,v in arrayPairsSkipNil(t) do
		if(type(v) == "table" and v==t)then res[i] = res
		else res[i] = v end
	end
	return res
end

--- Returns a shallow copy of object t - pTable-aware - circular/self reference aware - copy will share metatable with source t.
--@param t any kind of object.
--@param cpMT boolean to indicate whether metatable should be shared - default is false (no MT-sharing).
--@return new shallow-copied object
function pT.shallowCopy(t, cpMT)
	if type(t) ~= "table" then return t end
	local res = {}  -- result, i.e. the copied table
	-- have to share the metatable before the element-copy because the index/newindex 
	-- could have been modified (maybe proxy-table) - scary stuff...
	if(cpMT==true)then res = setmetatable(res,getmetatable(t)) end
	-- register the result-table as a pTable if source-table is one
	if isPTable(t) then pTableT(res,len(t)) end
	for k,v in pairs(t) do
		local kr,vr
		if(type(k) == "table" and k==t)then kr = res
		else kr = k end
		if(type(v) ~= "table" and v==t)then vr = res
		else vr = v end
		res[kr] = vr -- final element assignment for result-table
	end
	return res
end

--- Returns result from a shallow-compare of object t1 and t2 - compare by ref for table elements - one-level deep - circular/self reference detection.
--@param t1 any kind of object.
--@param t2 any kind of object to shallow-compare with t1.
--@return boolean result of shallow-comparison.
function pT.shallowCompare(t1, t2)
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
	local vt2 = t2[t2]
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

--- Returns a deep copy of object t - iterates "down" the tree if t is a table - pTable-aware - multiple&circular/self reference aware - copy will share metatable with source.
--@param t any kind of object.
--@param cpMT boolean to indicate whether metatable should be shared - default is false (no MT-sharing).
--@return new deep-copied object
function pT.deepCopy(t, cpMT)
	local trefs = pack()
	return deepCopy_helper(t, trefs, cpMT)
end

function pT_i.deepCopy_helper(t, trefs, cpMT)
	-- non-tables are simply returned - by ref or by value depending on type 
	if type(t) ~= "table" then return t end
	-- maintain the table references with thier associated copied-table-refs
	local res  -- result, i.e. the deep-copied table
	if trefs[t] then
		-- already copied this table before, so only copy the new-reference
		res = trefs[t] 
	else
		-- true copy is needed
		res = {}
		trefs[t] = res
		-- have to share the metatable before the element-copy because the index/newindex 
		-- could have been modified (maybe proxy-table) - scary stuff...
		if(cpMT==true)then res = setmetatable(res,getmetatable(t)) end
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
	local trefs = pack()
	return deepCompare_helper(t1, t2, trefs)
end

function pT_i.deepCompare_helper(t1, t2, trefs)
	if(type(t1)~=type(t2))then return false end
	if(type(t1)~="table")then return t1==t2 end
	-- we have only tables to compare
	-- see if we can go home early
	if(t1==t2)then return true end
	-- make sure that we notice circular or before seen comparisons
	trefs[t1] = trefs[t1] or pack()
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
-- utility functions to manage declarations of names in namespace 

--- Given a function-map (table) and a prefix (prefix.fname map), return 3 strings that hold a global assignment (orig_fname = fname), a local assignment (local fname), and a function-map to local assignement (fname = prefix.fname).
-- is useful to generate the correct assignment statements to keep the namespace clean
function pT_i.assignGlobalsLocalsFunctionMap(t, pre)
	local function komma(i) if(i>1)then return ", " else return "" end end
	local globals, locals, localfmap, gleft, gright, lleft, lright, ltleft, ltright
	local fnames = pTableL()
	-- collect all string-keys
	for k,v in pairs(t) do if(type(k)=="string")then insert(fnames,nil,k) end end
	table.sort(fnames)  -- we "know" that there are no nils in fnames
	gleft = "local "; gright=" = "; lleft ="local "; lright = "" ;ltleft=""; ltright=" = "
	for i,fn in arrayPairs(fnames)do
		gleft = gleft .. komma(i) .. "orig_" .. fn
		gright = gright .. komma(i) .. fn
		lleft = lleft .. komma(i) .. fn
		ltleft = ltleft .. komma(i) .. fn
		ltright = ltright .. komma(i) .. pre .. fn
	end
	
	globals = gleft .. gright
	locals = lleft .. lright
	localfmap = ltleft .. ltright
	return globals,locals,localfmap
end

-------------------------------------------------------------------------------
-- local to function-map declarations

-- map function-map names to locals
aget, agetLL, agetLT, agetRL, agetRT, apairs, arrayCopy, arrayLengthKey, arrayPairs, arrayPairsSkipNil, arrayValuesS, aset, asetL, asetT, deepCompare, deepCopy, getLen, insert, insertL, insertT, isIndex, isLuaTableLenOK, isMapKey, isPTable, len, lenT, listPairs, listPairsSkipNil, mapKeysL, mapKeysT, mapLen, mapNext, mapPairs, mapValuesL, mapValuesS, mapValuesT, nonNilLen, pT_i, pTableL, pTableT, pack, packT, rarrayPairs, remove, removeNils, removeRL, removeRT, shallowCompare, shallowCopy, tableKeysL, tableKeysT, tableLen, unpack, unregPTable = pT.aget, pT.agetLL, pT.agetLT, pT.agetRL, pT.agetRT, pT.apairs, pT.arrayCopy, pT.arrayLengthKey, pT.arrayPairs, pT.arrayPairsSkipNil, pT.arrayValuesS, pT.aset, pT.asetL, pT.asetT, pT.deepCompare, pT.deepCopy, pT.getLen, pT.insert, pT.insertL, pT.insertT, pT.isIndex, pT.isLuaTableLenOK, pT.isMapKey, pT.isPTable, pT.len, pT.lenT, pT.listPairs, pT.listPairsSkipNil, pT.mapKeysL, pT.mapKeysT, pT.mapLen, pT.mapNext, pT.mapPairs, pT.mapValuesL, pT.mapValuesS, pT.mapValuesT, pT.nonNilLen, pT.pT_i, pT.pTableL, pT.pTableT, pT.pack, pT.packT, pT.rarrayPairs, pT.remove, pT.removeNils, pT.removeRL, pT.removeRT, pT.shallowCompare, pT.shallowCopy, pT.tableKeysL, pT.tableKeysT, pT.tableLen, pT.unpack, pT.unregPTable

-- map function-map names to locals
agetRT_i, aget_i, arrayPairsSkipNil_iter, arrayPairs_iter, asetT_i, aset_i, assignGlobalsLocalsFunctionMap, deepCompare_helper, deepCopy_helper, isGE0Int, isGT0Int, isIndexPlus1, listPairsSkipNil_iter, listPairs_iter, rarrayPairs_iter, setLen = pT_i.agetRT_i, pT_i.aget_i, pT_i.arrayPairsSkipNil_iter, pT_i.arrayPairs_iter, pT_i.asetT_i, pT_i.aset_i, pT_i.assignGlobalsLocalsFunctionMap, pT_i.deepCompare_helper, pT_i.deepCopy_helper, pT_i.isGE0Int, pT_i.isGT0Int, pT_i.isIndexPlus1, pT_i.listPairsSkipNil_iter, pT_i.listPairs_iter, pT_i.rarrayPairs_iter, pT_i.setLen	

-------------------------------------------------------------------------------
-- finally... return the main function-map

return pT
