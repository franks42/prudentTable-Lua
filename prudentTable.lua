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

-- main table to return, which will hold all the exported functions
local pT = {}

-- weak table for representing the size/length/count of array-tables.
-- n = tableLenT[t] or nil
local tableLenT = setmetatable({}, {__mode = 'k'})

-- array-length URI definition for persistent import/export of tables
pT.arrayLengthKey = "uri:http://www.luna.org/ns/arrayLength"
local arrayLengthKey = pT.arrayLengthKey

-------------------------------------------------------------------------------

-- local convenience function to test whether k is integer and >0
local function isGT0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k > 0  
end

-- local convenience function to test whether k is integer and >=0
local function isGE0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k >= 0  
end


--- Returns whether the key k is a valid index for the array-component of table t
--@param t table instance
--@param k a possible array index value
--@return boolean - true indicates k is integer and 1 <= k <= len(t)
function pT.isIndex(t,k)
	return isGT0Int(k) and k <= pT.len(t)
end
local isIndex = pT.isIndex


--- Returns whether the t has registered as a prudentTable.
-- (only tests whether len(t) has ever been set - no guarantees about "integrity")
--@param t Lua table
--@return boolean - true indicates t has registered as a prudentTable
function pT.isPrudentTable(t) 
	return type(t)=="table" and tableLenT[t] ~= nil 
end
local isPrudentTable = pT.isPrudentTable


--- Returns the non-nil length/size of the array component of a standard Lua table
-- Simply loops from index 1 until the first nil-valued element.
-- Note that this function does not set any length/size for t, but merely scans.
--@param t table
--@return size of non-nil array (integer >= 0)
function pT.nonNilLen(t)
	assert(type(t) == "table")
	local n = 1
	while t[n] ~= nil do n=n+1 end
	return n - 1
end
local nonNilLen = pT.nonNilLen


--- Returns whether the Lua table lt's length may be ambiguous by comparing lt's non-nil array size (nonNilLen(t)) with #lt. 
-- This could be a determination whether the #t is the length to use for an unknown table.
--@param lt A "standard" lua-table
--@return Boolean: true if non-nil length equals #
function pT.isLuaTableLenOK(lt)
	return nonNilLen(lt) == #lt
end
local isLuaTableLenOK = pT.isLuaTableLenOK


--- Returns the registered length/size of the array component of prudentTable t
--@param t prudentTable
--@return Integer >= 0 indicating the size/length of t's array-component
function pT.len(t)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	return tableLenT[t]
end
pT.getLen = pT.len  -- alias for naming consistency
local len = pT.len
local getLen = pT.getLen


--- Set the length/size of the array component of table t and registers t as a prudentTable.
-- Thru pT.setLen(), a Lua-table t is "registered" as a prudentTable.
-- If size is increased, then existing map entries become part of the array.
-- If size is decreased, then some array components become map entries.
-- If resetValues==true then all new array/map elements get reset to nil.
-- This reset is to avoid any inconsistencies caused by unexpected new map/array elements.
--@usage local t = pT.setLen({a="a", b="b", 1,2,3,nil}, 4, false)
--@usage t = pT.setLen(t,5) ; pT.set(t,5,"five")
--@param t An standard lua-table or prudentTable
--@param n Integer >= 0
--@param resetValues boolean (default true) - resets new array or map elements to nil.
--@return prudentTable t (possibly modified - depending on n and resetValues)
function pT.setLen(t, n, resetValues)
	assert(type(t)=="table")
	assert(isGE0Int(n))
	resetValues = resetValues==nil or resetValues  -- defaults to true
	local oldn = 0
	if isPrudentTable(t) then oldn = pT.len(t) end
	if resetValues and oldn~=n then
		local b,e
		if oldn < n then b,e=oldn+1,n else b,e=n+1,oldn end
		for i = b,e do t[i]=nil end   -- nil-out all new or old array elements
	end
	tableLenT[t] = n  -- register the table size and make t a prudentTable
	return t
end
local setLen = pT.setLen


--- Returns n element values as a new prudentTable, starting at index i of prudentTable t.
-- Range must not extend array boundaries.
--@param t prudentTable
--@param i start of range (>=1)
--@param n  number of element-values to return - i+n-1 <= len(t) - n default to 1 - n may be 0
--@return new prudentTable with requested values in the array-component (including possible nils)
function pT.getTable(t,i,n)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	assert(isIndex(t,i))
	local tmp = pT.pack()
	n = n or 1
	if n==0 then return tmp end
	assert(isIndex(t,i+n-1))
	setLen(tmp,n,false)
	for j = 1,n do tmp[j] = t[i+j-1] end
	return tmp
end
local getTable = pT.getTable


--- Returns n element values as a list, starting at index i of prudentTable t.
-- Range must not extend array boundaries.
--@param t prudentTable
--@param i start of range (>=1)
--@param n  number of element-values to return - i+n-1 <= len(t) - n default to 1 - n may be 0
--@return list of zero, one or more values (including possible nils)
function pT.get(t,i,n)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	local tmp = getTable(t,i,n)
	-- Note that this is the "original" unpack and not the pT.unpack!!
	return unpack(tmp,1,n)
end
local get = pT.get


--- Returns a (shallow) copy of prudentTable t.
--@param t prudentTable
--@return a new prudentTable - shallow copy of t
function pT.copy(t)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	local tmp = pT.pack()
	for k,v in pairs(t) do tmp[k] = t[v] end
	setLen(tmp, len(t), false)
	return tmp
end
local copy = pT.copy


--- Copies the array elements of prudentTable t1 into the array-component of prudentTable t starting at index i
-- Array-size must be able to accomodate the list as it does not grow automatically.
--@param t prudentTable (target)
--@param i target start-index
--@param t1 prudentTable (source)
--@returns modified prudentTable t
function pT.setTable(t,i,t1)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	assert(isIndex(t,i))
	local lt1 = len(t1)
	if lt1 == 0 then return t end
	local lt = len(t)
	assert( (i + lt1 - 1) <= lt)
	for j = 0, lt1-1 do t[i+j] = t1[j+1] end
	return t
end
local setTable = pT.setTable


--- Copies a list of values into the array-component of prudentTable t starting at index i
-- Array-size must be able to accomodate the list as it does not grow automatically.
--@param t prudentTable
--@param i target start-index
--@param ... list of zero, one or more values
--@return modified prudentTable t
function pT.set(t,i,...)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	return setTable(t,i,pT.pack(...))
end
local set = pT.set


--- Extends and adds the array elements of prudentTable t1 at the end of the array-component 
-- of prudentTable t.
-- Array-size is increased to accomodate the list of values. 
-- (nil-friendly)
--@param t prudentTable (target)
--@param t1 prudentTable (source)
--@return modified prudentTable t
function pT.addTable(t,t1)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	-- Resize t to accomodate t1 and delegate to setTable()
	local lt1 = len(t1)
	if lt1 == 0 then return t end
	local lt = len(t)
	setLen(t, lt+lt1)
	t = setTable(t,lt+1,t1)
	return t
end
local addTable = pT.addTable


--- Extends and adds a list of values at the end of the array-component 
-- of prudentTable t.
-- Array-size is increased to accomodate the list of values. (nils are added)
--@param t prudentTable
--@param ... list of zero, one or more values
--@return modified prudentTable t
function pT.add(t,...)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	local t1 = setLen({...}, select('#', ...), false)
	return addTable(t,t1)
end
local add = pT.add


--- Extends and inserts the array-elements of prudentTable t1 at index i of prudentTable t.
-- Array-size is increased to accomodate the list of values.
-- Existing elements are moved-up - no values are overwritten.
-- (nil-friendly)
--@param t prudentTable (target)
--@param i Starting index for insertion
--@param t1 prudentTable (source)
--@returns modified prudentTable t
function pT.insertTable(t,i,t1)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	-- accommodate inserting into empty, zero-size array
	if(len(t) == 0 and i == 1) then return addTable(t,t1) end
	assert(isIndex(t,i))
	local n = len(t1)
	if n==0 then return t end
	local oldLen = len(t)
	setLen(t, oldLen+n)     -- extend size
	t = setTable(t,i+n,getTable(t,i,n)) -- move up
	t = setTable(t,i,t1)           -- insert
	return t
end
local insertTable = pT.insertTable


--- Extends and inserts a list of values at index i of prudentTable t.
-- Array-size is increased to accomodate the list of values.
-- Existing elements are moved-up - no values are overwritten.
-- (nil-friendly)
--@param t prudentTable
--@param i Starting index for insertion
--@param ... list of zero, one or more values
--@return modified prudentTable t
function pT.insert(t,i,...)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	local t1 = setLen({...}, select('#', ...), false)
	return insertTable(t,i,t1)
end
local insert = pT.insert


--- Removes n elements from prudentTable t starting with index i, 
-- returns those removed element values as a new prudentTable, 
-- and decreases t's array size accordingly. 
-- (nil-friendly)
--@param t prudentTable (changed inplace)
--@param i Starting index for removal.
--@param n Number of elements to remove. (default is 1, may be 0)
--@return New prudentTable with removed element value(s) in the array component. 
function pT.removeTable(t,i,n)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	assert(isIndex(t,i))
	n = n or 1
	if n==0 then return pT.pack() end
	assert(isIndex(t,i+n-1))
	local lt = len(t)
	local rvs = getTable(t,i,n)  -- table with removed values
	if i+n-1 < lt then
		setTable(t,i, getTable(t,i+n,lt-i-n+1))
	end
	setLen(t, lt-n)
	return rvs
end
local removeTable = pT.removeTable


--- Removes n elements from prudentTable t starting with index i, 
-- returns those removed element values as a list, 
-- and decreases t's array size accordingly. 
-- (nil-friendly)
--@param t prudentTable (changed inplace)
--@param i Starting index for removal.
--@param n Number of elements to remove. (default is 1, may be 0)
--@return List of removed element value(s)
function pT.remove(t,i,n)
	--assert(isPrudentTable(t), "Table is not a registered prudentTable")
	return pT.unpack(removeTable(t,i,n))
end
local remove = pT.remove


-------------------------------------------------------------------------------
-- pack and unpack replacements that are prudentTable-aware
-- pack, unpack 
-------------------------------------------------------------------------------

--- prudentTable constructor (table.pack() replacement), which copies the list arguments into the 
-- array-component of the newly created prudentTable.
-- Registers the "correct" argument list size for the array-length.
-- (nil-friendly)
-- Uses the "convention" of adding an entry: n = select('#', ...).
-- (however, the latter is NOT used by any prudentTable-function - just trying to play nice...)
--@param ... List of elements to add to the array-component of the newly created table
--@return Newly created prudentTable instance
function pT.pack(...)
	return setLen({n = select('#', ...), ...}, select('#', ...), false)
end

--- Unpacks and returns the array-component of prudentTable t as a list of values (table.unpack() replacement).
-- pT.unpack does NOT use any "t.n" that may be used to indicates the array-length.
--@param t prudentTable
--@param b start of range to copy - defaults to 1
--@param e end of range to copy - defaults to pT.len(t)
--@return list of values representing t[b:e] - may include nils
function pT.unpack(t,b,e)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	if len(t)==0 then return end -- return "nothing"
	e = e or len(t)
	b = b or 1
	assert(isIndex(t,b) and isIndex(t,e) and b <= e , "pT.unpack: range arguments not proper array-indices, or begin > end")
	return get(t,b,e-b+1) 
end


-------------------------------------------------------------------------------
-- Basic "iterator" specific functions
-- arrayPairs, rarrayPairs, mapPairs, tablePairs, listPairs 
-------------------------------------------------------------------------------

--- Local helper function for "arrayPairs()"
local function arrayPairs_iter(t, i)
	i = i + 1
	if i <= (len(t) or 0) then
		return i, get(t,i)
	end
end

--- Local helper function for "rarrayPairs()"
local function rarrayPairs_iter(t, i)
	i = i - 1
	if i >= 1 then
		return i, get(t,i)
	end
end

--- ipairs-replacement that handles nil values for an prudentTable's array-component
-- and iterates from t[1] till t[len(t)]
function pT.arrayPairs(t, i)
	return arrayPairs_iter, t, 0
end
local arrayPairs = pT.arrayPairs

--- reverse ipairs-replacement that handles nil values for an prudentTable's 
-- array-component and iterates down from t[len(t)] till t[1].
function pT.rarrayPairs(t, i)
	return rarrayPairs_iter, t, len(t)+1
end
local rarrayPairs = pT.rarrayPairs


--- Pairs-like iterator that excludes any k that are array indices - 
-- Only iterates over the map-component of the prudentTable.
function pT.mapNext(t, k)
	local d = data[t]
	if not d then return end
	k = next(d, k)
	while k do
		if not isIndex(k) then break end
		k = next(d, k)
	end
	return k
end
local mapNext = pT.mapNext

--- Pairs-like iterator that excludes any k that are array indices - 
-- only iterates over the map-component of the prudentTable.
function pT.mapPairs(t, i)
	return mapNext, t, nil
end
local mapPairs = pT.mapPairs


local function listPairs_iter(a, i)
  if i < a.n then return i+1,a[i+1] end
end

--- Iterator for varargs (friendly to nils).
--@usage function f(...) for i,a in apairs(...) do print(i, a) end end
--@param ... vararg list (may include nils)
function pT.listPairs(...)
  return listPairs_iter, {n=select('#', ...), ...}, 0
end
local listPairs = pT.listPairs
pT.apairs = pT.listPairs  -- alias to accommodate common convention (a = args)
local apairs = pT.apairs


--- Returns whether a key k exists in table t.
-- A key k exists when:
-- * it has a normal map entry where a non-nil value is returned for t[k]
-- * it has been registered as a "permanent key"  - may have nil value
-- * key is valid array index: k is integer and 0 < k <= len(t)
--@param t table
--@param k key (not-nil)
--@return Boolean indicating whether k is an existing key for table t
function pT.keyExists(t, k)
	assert(type(t)=="table")
	assert(k~=nil)
	return t[k]~=nil or isIndex(t,k)
end
local keyExists = pT.keyExists


--- Returns a table with a list of all the "lua-defined" keys in table t
function pT.tableKeysTable(t)
	local tmp = pT.pack()
	for k,v in pairs(t) do add(tmp,k) end
	return tmp
end
local tableKeysTable = pT.tableKeysTable

--- Returns a list of all the "lua-defined" keys in table t
function pT.tableKeys(t)
	return pT.unpack(tableKeysTable(t))
end
local tableKeys = pT.tableKeys


--- Returns a table with a list of all the keys of the map-component of table t
function pT.mapKeysTable(t)
	local tmp = pT.pack()
	for k,v in pairs(t) do 
		if not isIndex(t,k) then add(tmp,k) end
	end
	return tmp
end
local mapKeysTable = pT.mapKeysTable

--- Returns a list of all the keys of the map-component of table t
function pT.mapKeys(t)
	return pT.unpack(mapKeysTable(t))
end
local mapKeys = pT.mapKeys


-------------------------------------------------------------------------------

--- Removes all the elements with nil-values from the array-component of prudentTable t.
--@param t prudentTable
--@return (possibly modified) prudentTable t
function pT.removeNils(t)
	assert(isPrudentTable(t), "Table is not a registered prudentTable")
	for i,v in rarrayPairs(t) do 
		if v==nil then remove(t,i) end 
	end
	return t
end
local removeNils = pT.removeNils

-------------------------------------------------------------------------------
-- Basic "list" specific functions
-- insert, append, first, rest, last, list, concat, 
-------------------------------------------------------------------------------


return pT
