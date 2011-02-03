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

local pT, tableLenT, isGT0Int, isGE0Int, isIndexPlus1, setLen, get_i, getRT_i, set_i, setT_i, arrayPairs_iter, rarrayPairs_iter, arrayPairsSkipNil_iter, rarrayPairsSkipNil_iter, listPairs_iter, listPairsSkipNil_iter, deepCompare_helper, deepCopy_helper



-------------------------------------------------------------------------------

-- main table to return, which will hold all the exported functions
pT = {}

-- weak table for representing the size/length/count of array-tables.
-- n = tableLenT[t] or nil
tableLenT = setmetatable({}, {__mode = 'k'})

-- array-length URI definition for persistent import/export of tables
pT.arrayLengthKey = "uri:http://www.luna.org/ns/arrayLength"
local arrayLengthKey = pT.arrayLengthKey

-------------------------------------------------------------------------------

-- local convenience function to test whether k is integer and >0
function isGT0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k > 0  
end

-- local convenience function to test whether k is integer and >=0
function isGE0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k >= 0  
end


--- Returns whether the key k is a valid index for the array-component of pTable t.
--@param t pTable
--@param k possible array index value
--@return boolean - true indicates k is integer and 1 <= k <= pT.len(t)
function pT.isIndex(t,k)
	return isGT0Int(k) and k <= pT.len(t)
end
local isIndex = pT.isIndex


-- Returns whether the key k is a valid index for the array-component of table t including len(t) + 1, which is used by insert() to append to the array.
--@param t table instance
--@param k a possible array index value including len(t)+1
--@return boolean - true indicates k is integer and 1 <= k <= len(t)+1
function isIndexPlus1(t,k)
	return isGT0Int(k) and k <= pT.len(t) + 1
end


--- Returns whether the t is registered as a pTable.
--@param t possible pTable
--@return boolean - true indicates t has been registered as a pTable
function pT.isPTable(t) 
	return type(t)=="table" and tableLenT[t] ~= nil 
end
local isPTable = pT.isPTable


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
local nonNilLen = pT.nonNilLen


--- Returns whether the Lua table lt's length may be ambiguous by comparing lt's non-nil array size (nonNilLen(t)) with #lt. 
-- This could help determine whether the #t is the length to use for an unknown table.
--@param lt "standard" lua-table
--@return Boolean: true if lt's non-nil length equals #lt
function pT.isLuaTableLenOK(lt)
	return nonNilLen(lt) == #lt
end
local isLuaTableLenOK = pT.isLuaTableLenOK


--- Returns length/size of the array component of pTable t.
--@param t pTable
--@return Integer >= 0 indicating the size/length of t's array-component
function pT.len(t)
	assert(isPTable(t), "Table is not a registered pTable")
	return tableLenT[t]
end
pT.getLen = pT.len  -- alias for naming consistency
local len = pT.len
local getLen = pT.getLen


--- Returns the number of map entries in pTable t that are not part of the array-component.
--@param t pTable
--@return Integer >= 0 indicating number of t's non-array components
function pT.mapLen(t)
	assert(isPTable(t), "Table is not a registered pTable")
	local n = 0
	for k,v in pT.mapPairs(t) do n = n+1 end
	return n
end
local mapLen = pT.mapLen


--- Returns the number of real table entries of t - does not include any nil-assigned array elements.
-- Simply loops with pairs() over all table entries and counts.
--@param t pTable
--@return Integer >= 0 indicating number of truly allocated table entries
function pT.tableLen(t)
	local n = 0
	for k,v in pairs(t) do n = n+1 end
	return n
end
local tableLen = pT.tableLen


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
function setLen(t, n, resetValues)
	assert(type(t)=="table")
	n = n or 0
	assert(isGE0Int(n))
	resetValues = resetValues==nil or resetValues  -- defaults to true
	local oldn = 0
	if isPTable(t) then oldn = pT.len(t) end
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
--@param lt An standard lua-table
--@param n Integer >= 0 - indicates the size of the array-component (default is 0)
--@return pTable lt (unmodified but registered with size n)
function pT.regPTable(lt,n)
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


--- Returns the array-element value at index i of pTable t.
--@param t pTable
--@param i index (1 <= i <= len(t))
--@return value at t[i]
function pT.get(t,i)
	assert(isPTable(t), "get: Table t is not a registered pTable")
	assert(isIndex(t,i), "get: Index i not within 1 <= i <= len(t)")
	return get_i(t,i)
end
local get = pT.get


-- Internal function without assertions - returns the element value at index i of pTable t.
--@param t pTable
--@param i index (1 <= i <= len(t))
--@return value at t[i]
function get_i(t,i)
	return t[i]
end


--- For the range of array-index b till e of pTable t, returns an array of element values as a new pTable.
-- Range must not extend array boundaries.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1.
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t).
--@return new pTable with requested values in the array-components.
function pT.getRT(t,b,e)
	assert(isPTable(t), "Table is not a registered pTable")
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b<=e)
	return getRT_i(t,b,e)
end
local getRT = pT.getRT


-- For the range of array-index b till e of pTable t, returns an array of element values as a new pTable without type and array bound checks.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1.
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t).
--@return new pTable with requested values in the array-components.
function getRT_i(t,b,e)
	local n = e-b+1
	if n==1 then return pT.pack(get_i(t,b)) end
	local tmp = setLen(pT.pack(), n)
	for j = 1,n do set_i(tmp, j, get_i(t,b+j-1)) end
	return tmp
end


--- For the range of array-index b till e of pTable t, returns the list of element values.
-- Range must not extend array boundaries.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t)
--@return list of zero, one or more values (including possible nils)
function pT.getRL(t,b,e)
	local tmp = getRT(t,b,e)
	-- Note that this is the "original" unpack and not the pT.unpack!!
	return unpack(tmp,1,e-b+1)
end
local getRL = pT.getRL


--- Set pTable t's element at index i to value v.
-- i should be a valid index for t.
--@param t pTable
--@param i index: 1 <= i <= len(t)
--@param v new value (may be nil)
--@return modified pTable t
function pT.set(t,i,v)
	assert(isPTable(t), "Table is not a registered pTable")
	assert(isIndex(t,i), "Index i not within 1 <= i <= len(t)")
	return set_i(t,i,v)
end
local set = pT.set


-- Internal function - sets the value of element i of ptable t to value v.
-- Array-size must be able to accomodate the list as it does not grow automatically.
function set_i(t,i,v)
	t[i] = v
	return t
end


--- Returns the sum of the array-lengths of a list of pTables: len(t1)+...+len(tn).
--@param ... list of zero, one or more pTables - may include nils, which are ignored.
--@returns total number of array-elements of all pTables.
function pT.lenT(...)
	local ntin = 0
	for i,ti in pT.listPairsSkipNil(...) do
		assert(isPTable(ti))
		ntin = ntin + pT.len(ti)
	end
	return ntin
end
local lenT = pT.lenT


--- Copies the array elements of pTables t1...tn into the array-component of pTable t starting at index i.
-- t's array-size must be able to accomodate the new elements as it does not grow automatically.
--@param t pTable (target)
--@param i target start-index
--@param ... list of zero, one or more pTable's (source) - may include nils, which are ignored.
--@returns modified pTable t
function pT.setT(t,i,...)
	assert(isPTable(t), "Table t is not a registered pTable")
	assert(isIndex(t,i), "Index i not within 1 <= i <= len(t)")
	local ntin = lenT(...)
	if ntin == 0 then return t end	
	local lt = len(t)
	assert((i + ntin - 1) <= lt, "setT: Size of pTable t's array cannot accomodate elements")
	return setT_i(t,i,...)
end
local setT = pT.setT


-- Copies the array elements of pTables t1...tn into the array-component of pTable t starting at index i without any type or bound-checks.
function setT_i(t,i,...)
	for i,ti in pT.listPairs(...) do
		if ti ~= nil then
			for j,vj in pT.arrayPairs(ti) do
				set_i(t,i,vj)
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
function pT.setL(t,i,...)
	return setT(t,i,pT.pack(...))
end
local setL = pT.setL


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
	nts = pT.lenT(...)
	if nts==0 then return t end
	local oldLen = len(t)
	setLen(t, oldLen+nts)     -- extend size
	if(i < oldLen + 1) then 
		t = setT_i(t,i+nts, getRT(t,i,oldLen)) -- move up
	end
	t = setT_i(t,i,...)           -- insert
	return t
end
local insertT = pT.insertT


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
local insertL = pT.insertL


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
	print("insert",i,len(t),lt)
	if i < len(t) then t = setT_i(t,i+1,getRT(t,i,lt)) end -- move 1 up
	set_i(t,i,v)
	return t
end
local insert = pT.insert


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
	local rvs = getRT(t,b,e)  -- table with removed values
	if i+n-1 < lt then
		setT(t,b, getRT(t,b+n,lt-b-n+1))
	end
	setLen(t, lt-n)
	return rvs
end
local removeRT = pT.removeRT


--- Removes the range of array-elements from index b till e from pTable t, and returns those removed elements as a list - t's array size is decreased accordingly.
-- (nil-friendly)
--@param t pTable (changed inplace).
--@param b Starting index for removal (default is b=1).
--@param e Last index for removal (default is e=len(t)).
--@return List of removed element value(s).
function pT.removeRL(t,b,e)
	--assert(isPTable(t), "Table is not a registered pTable")
	return pT.unpack(removeAsTable(t,b,e))
end
local removeRL = pT.removeRL


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
	local v = get_i(t,i)
	if i ~= lt then setT_i(t, i, getRT(t, i+1, lt)) end
	setLen(t,lt-1)
	return v
end
local remove = pT.remove


-------------------------------------------------------------------------------
-- pack and unpack replacements that are pTable-aware
-- pack, unpack 
-------------------------------------------------------------------------------

--- pTable constructor (table.pack() replacement), which copies the list arguments into the 
-- array-component of the newly created pTable.
-- Registers the "correct" argument list size for the array-length.
-- (nil-friendly)
--@param ... List of elements to add to the array-component of the newly created pTable
--@return New pTable
function pT.pack(...)
	return setLen({...}, select('#', ...), false)
end


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
	return getRL(t,b,e) 
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
--	t.n = nts  -- play nice
	return setT_i(t,...)
end
local packT = pT.packT


-------------------------------------------------------------------------------
-- Iterators to augment the pairs()
-- (note...never, ever use Lua's ipairs()!!!)
-- arrayPairs, rarrayPairs, mapPairs, tablePairs, listPairs 
-------------------------------------------------------------------------------

-- Local helper function for "arrayPairs()"
function arrayPairs_iter(t, i)
	i = i + 1
	if i <= (len(t) or 0) then
		return i, get_i(t,i)
	end
end

--- ipairs-replacement for pTable t's array-component that
-- iterates up from t[1] till t[len(t)], and will return possible nil-values.
--@param t pTable
function pT.arrayPairs(t, i)
	return arrayPairs_iter, t, 0
end
local arrayPairs = pT.arrayPairs


-- Local helper function for "rarrayPairs()"
function rarrayPairs_iter(t, i)
	i = i - 1
	if i >= 1 then
		return i, get_i(t,i)
	end
end

--- reverse ipairs-replacement for pTable t's
-- array-component and iterates down from t[len(t)] till t[1], and will return possible nil-values - safe(r) element removal.
--@param t pTable
function pT.rarrayPairs(t, i)
	return rarrayPairs_iter, t, len(t)+1
end
local rarrayPairs = pT.rarrayPairs


-- Local helper function for "arrayPairsSkipNil()"
function arrayPairsSkipNil_iter(t, i)
	i = i + 1
	while i <= (len(t) or 0) do
		local v = get_i(t,i)
		if v ~= nil then return i, v end
		i = i + 1
	end
end

--- ipairs-replacement for pTable t's array-component that
-- iterates up from t[1] till t[len(t)], and will skip any nil-values.
function pT.arrayPairsSkipNil(t, i)
	return arrayPairsSkipNil_iter, t, 0
end
local arrayPairsSkipNil = pT.arrayPairsSkipNil


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
local mapNext = pT.mapNext

--- Pairs-like iterator that excludes any keys k of pTable t that are array indices - 
-- only iterates over the map-component of the pTable.
function pT.mapPairs(t)
	return mapNext, t, nil
end
local mapPairs = pT.mapPairs


-- Helper function for listPairs()
function listPairs_iter(a, i)
	if i < a.n then return i+1,a[i+1] end
end

--- ipairs-like iterator for varargs (friendly to nils).
--@usage function f(...) for i,a in listPairs(...) do print(i, a) end end
--@param ... vararg list (may include nils)
function pT.listPairs(...)
	return listPairs_iter, {n=select('#', ...), ...}, 0
end
local listPairs = pT.listPairs
pT.apairs = pT.listPairs  -- alias to accommodate common convention (a = args)
local apairs = pT.apairs


-- Helper function for listPairsSkipNil()
function listPairsSkipNil_iter(a, i)
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
local listPairsSkipNil = pT.listPairsSkipNil


-------------------------------------------------------------------------------
-- Common collector & filter functions for tables
-- tableKeysT, mapKeysT, mapKeys
-------------------------------------------------------------------------------

--- Returns a pTable with a list of all the "lua-defined" keys in table t.
--@param t lua-table or pTable.
--@return new pTable t's keys collected in the array-component.
function pT.tableKeysT(t)
	local tmp = pT.pack()
	for k,v in pairs(t) do pT.insert(tmp,k) end
	return tmp
end
local tableKeysT = pT.tableKeysT

--- Returns a list of all the "lua-defined" keys in table t.
--@param t lua-table or pTable.
--@return list of t's keys .
function pT.tableKeys(t)
	return pT.unpack(tableKeysT(t))
end
local tableKeys = pT.tableKeys


--- Returns a pTable with a list of all the keys of the map-component of pTable t without the array-indices.
--@param t pTable.
--@return new pTable t's map-keys collected in the array-component.
function pT.mapKeysT(t)
	local tmp = pT.pack()
	for k,v in pairs(t) do 
		if not isIndex(t,k) then insert(tmp,k) end
	end
	return tmp
end
local mapKeysT = pT.mapKeysT

--- Returns a list of all the keys of the map-component of pTable t without the array-indices.
--@param t pTable.
--@return list of t's map-keys.
function pT.mapKeys(t)
	return pT.unpack(mapKeysT(t))
end
local mapKeys = pT.mapKeys


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
local removeNils = pT.removeNils


-------------------------------------------------------------------------------
-- deepCopy and deepCompare 
-------------------------------------------------------------------------------

--- Returns a deep copy of object t - iterates "down" the tree if t is a table - pTable-aware - multiple&circular reference aware - copy will share metatable with source.
--@param t any kind of object.
--@return new deep-copied object
function pT.deepCopy(t)
	local trefs = pT.pack()
	return deepCopy_helper(t, trefs)
end
local deepCopy = pT.deepCopy

function deepCopy_helper(t, trefs)
	-- non-tables are simply returned - by ref or by value depending on type 
	if type(t) ~= "table" then return t, trefs end
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
		setmetatable(res,getmetatable(t))
		-- register the result-table as a pTable if source-table is one
		if isPTable(t) then pT.regPTable(res,pT.len(t)) end
		for k,v in pairs(t) do
			local kr,vr
			-- recursively deepCopy both the key and value for the result-table
			kr, trefs = deepCopy_helper(k,trefs)
			vr, trefs = deepCopy_helper(v,trefs)
			res[kr] = vr -- final element assignment for result-table
		end
	end
	return res, trefs
end


--- Returns result from a deep-compare of object t1 and t2 - compare by value for table elements - iterates down the trees - circular and repeated reference detection.
--@param t1 any kind of object.
--@param t2 any kind of object to deep-compare with t1.
--@return boolean result of deep-comparison.
function pT.deepCompare(t1, t2)
	local trefs = pT.pack()
	return deepCompare_helper(t1, t2, trefs)
end
local deepCompare = pT.deepCompare

function deepCompare_helper(t1, t2, trefs)
	if(type(t1)~=type(t2))then return false, trefs end
	if(type(t1)~="table")then return t1==t2, trefs end
	-- we have only tables to compare
	-- make sure that we notice circular or before seen comparisons
	trefs = trefs or pT.pack()
	trefs[t1] = trefs[t1] or pT.pack()
	if(trefs[t1][t2]==true)then return true, trefs 
	else trefs[t1][t2]=true end
	-- pTable specific comparisons
	local pt1,pt2 = pT.isPTable(t1), pT.isPTable(t2)
	if((pt1 and not pt2) or (not pt1 and pt2))then return false, trefs end
	if(pt1 and pt2 and pT.len(t1)~=pT.len(t2))then return false, trefs end
	if(pT.tableLen(t1) ~= pT.tableLen(t2))then return false, trefs end
	-- so, t1 and t2 are both tables with equal number of elements
	-- and they could both be pTables with equal array-length
	for k1,v1 in pairs(t1) do
		local v12 = t2[k1]
		if(v12~=nil)then
			-- see if associated values are equal
			if(not deepCompare_helper(v1, v12, trefs))then return false, trefs end
		else
			if(type(k1)~="table")then
				return false, trefs  -- key is no table: give up
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
				if(not kres)then return false, trefs end
			end  -- still true for deep key-compare
		end  -- still true for either deep normal or key compare
	end  -- true for this k1 - back for next iteration
	-- all deep comparisons yielded true for t1&t2
	return true, trefs 
end


-------------------------------------------------------------------------------

return pT
