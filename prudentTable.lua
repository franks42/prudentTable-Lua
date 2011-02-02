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

local get_i, getRT_i, set_i, setT_i



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


--- Returns whether the key k is a valid index for the array-component of table t including len(t) + 1, which is used by insert() to append to the array.
--@param t table instance
--@param k a possible array index value including len(t)+1
--@return boolean - true indicates k is integer and 1 <= k <= len(t)+1
function pT.isIndexPlus1(t,k)
	return isGT0Int(k) and k <= pT.len(t) + 1
end
local isIndexPlus1 = pT.isIndexPlus1


--- Returns whether the t has registered as a pTable.
-- (only tests whether len(t) has ever been set - no guarantees about "integrity")
--@param t Lua table
--@return boolean - true indicates t has registered as a pTable
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
-- This could be a determination whether the #t is the length to use for an unknown table.
--@param lt A "standard" lua-table
--@return Boolean: true if non-nil length equals #
function pT.isLuaTableLenOK(lt)
	return nonNilLen(lt) == #lt
end
local isLuaTableLenOK = pT.isLuaTableLenOK


--- Returns the registered length/size of the array component of pTable t
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
--@return Integer >= 0 indicating number of t's non-array-component
function pT.mapLen(t)
	assert(isPTable(t), "Table is not a registered pTable")
	local n = 0
	for k,v in pT.mapPairs(t) do n = n+1 end
	return n
end
local mapLen = pT.mapLen


--- Returns the number of real table entries in pTable t - does not include any nil-assigned array elements
--@param t pTable
--@return Integer >= 0 indicating number of truly allocated table entries
function pT.tableLen(t)
	assert(isPTable(t), "Table is not a registered pTable")
	local n = 0
	for k,v in pairs(t) do n = n+1 end
	return n
end
local tableLen = pT.tableLen


--- Set the length/size of the array component of table t and registers t as a pTable.
-- Thru pT.setLen(), a Lua-table t is "registered" as a pTable.
-- If size is increased, then existing map entries become part of the array.
-- If size is decreased, then some array components become map entries.
-- If resetValues==true then all new array/map elements get reset to nil.
-- This reset is to avoid any inconsistencies caused by unexpected new map/array elements.
-- Note, however, that no element values are reset during the very first registration - implicit resetValues=false for first registration.
--@usage local t = pT.setLen({a="a", b="b", 1,2,3,nil}, 4)
--@usage t = pT.setLen(t,5) ; pT.set(t,5,"five")
--@param t An standard lua-table or pTable
--@param n Integer >= 0
--@param resetValues boolean (default true) - resets new array or map elements to nil.
--@return pTable t (possibly modified - depending on n and resetValues - not modified on first registration)
function pT.setLen(t, n, resetValues)
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
local setLen = pT.setLen

--- Registers an existing standard Lua table lt as a pTable while providing the length/size n to use.
-- Length/size for table lt has to be passed explicitly as no assumptions about #lt are implicitly trusted/used. (you could use #lt for the argument n value... if you know what you're doing)
--@param lt An standard lua-table
--@param n Integer >= 0 - indicates the size of the array-component (default is 0)
--@return pTable lt (unmodified but registered with size n)
function pT.registerPTable(lt,n)
	return pT.setLen(lt, n, false)
end


--- Unregisters an existing pTable t such that the pTable-functions won't work with this table anymore. 
-- When other functions will change this table's size, thru unregisterPTable() you can prevent accidental use of the pTable functions with the wrong size. It will force the need to re-register the table with the proper size.
--@param t pTable
--@return t (unmodified but unregistered)
function pT.unregisterPTable(t)
	tableLenT[t] = nil
	return t
end


--- Returns the element value at index i of pTable t.
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


--- For the range of index b till e of pTable t, returns an array of element values as a new pTable.
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


-- For the range of index b till e of pTable t, returns an array of element values as a new pTable without type and array bound checks.
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


--- For the range of index b till e of pTable t, returns the list of element values.
-- Range must not extend array boundaries.
-- (nil friendly)
--@param t pTable
--@param b start of range - 1 <= b <= len(t) - defaults to 1
--@param e end of range - 1 <= e <= len(t) and e >= b - defaults to len(t)
--@return list of zero, one or more values (including possible nils)
function pT.getR(t,b,e)
	local tmp = getRT(t,b,e)
	-- Note that this is the "original" unpack and not the pT.unpack!!
	return unpack(tmp,1,e-b+1)
end
local getR = pT.getR


--- Set pTable t's element at index i to value v.
-- i should be a valid index for t.
--@param t pTable
--@param i element's index
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
--@param t pTable
--@param i target start-index
--@param ... list of zero, one or more values
--@return modified pTable t
function set_i(t,i,v)
	t[i] = v
	return t
end


--- Returns the total number of elements of the list of pTables.
--@param ... list of pTable's - may include nils, which are ignored.
--@returns total number of elements
function pT.lenT(...)
	local ntin = 0
	for i,ti in pT.listPairs(...) do
		if (ti ~= nil) then
			assert(isPTable(ti))
			ntin = ntin + pT.len(ti)
		end
	end
	return ntin
end
local lenT = pT.lenT


--- Copies the array elements of pTables t1...tn into the array-component of pTable t starting at index i.
-- t's array-size must be able to accomodate the new elements as it does not grow automatically.
--@param t pTable (target)
--@param i target start-index
--@param ... list of pTable's (source) - may include nils, which are ignored.
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
--@param t pTable (target)
--@param i target start-index
--@param ... list of pTable's (source) - may include nils, which are ignored.
--@returns modified pTable t
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
--@param ... list of pTable's (source) - may include nils, which are ignored.
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


--- Inserts a list of values at index i of pTable t.
-- Array-size is increased to accomodate the list of values.
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


--- Extends and inserts a single value at index i of pTable t.
-- Array-size is increased to accomodate the list of values.
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


--- Removes n elements from pTable t starting with index i, 
-- returns those removed element values as a new pTable, 
-- and decreases t's array size accordingly. 
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


--- Removes n elements from pTable t starting with index i, 
-- returns those removed element values as a list, 
-- and decreases t's array size accordingly. 
-- (nil-friendly)
--@param t pTable (changed inplace).
--@param b Starting index for removal (default is b=1).
--@param e Last index for removal (default is e=len(t)).
--@return List of removed element value(s).
function pT.removeR(t,b,e)
	--assert(isPTable(t), "Table is not a registered pTable")
	return pT.unpack(removeAsTable(t,b,e))
end
local removeR = pT.removeR


--- Removes element from pTable t at index i, 
-- returns the removed element's value, 
-- and decreases t's array size by one. 
-- (nil-friendly)
--@param t pTable (changed inplace)
--@param i Starting index for removal - default is last element.
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
-- Uses the "convention" of adding an entry: n = select('#', ...).
-- (however, the latter is NOT used by any pTable-function - just trying to play nice...)
--@param ... List of elements to add to the array-component of the newly created table
--@return Newly created pTable instance
function pT.pack(...)
--	return setLen({n = select('#', ...), ...}, select('#', ...), false)
	return setLen({...}, select('#', ...), false)
end


--- Unpacks and returns the array-component of pTable t as a list of values (table.unpack() replacement).
-- pT.unpack does NOT use any "t.n" that may be used to indicates the array-length.
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
	return getR(t,b,e) 
end


--- pTable constructor, which copies all the elements of the argument-list of pTable's 
-- into the array-component of a newly created pTable.
-- Note that all map-entries of the source-pTable's are ignored.
-- (nil-friendly)
--@param ... List of pTables - may include nils, which are ignored.
--@return Newly created pTable instance
function pT.packT(...)
	local nts = lenT(...)
	local t = pT.setLen({},nts)
--	t.n = nts  -- play nice
	return setT_i(t,...)
end
local packT = pT.packT

-------------------------------------------------------------------------------
-- Basic "iterator" specific functions
-- arrayPairs, rarrayPairs, mapPairs, tablePairs, listPairs 
-------------------------------------------------------------------------------

-- Local helper function for "arrayPairs()"
local function arrayPairs_iter(t, i)
	i = i + 1
	if i <= (len(t) or 0) then
		return i, get_i(t,i)
	end
end

--- ipairs-replacement for pTable's array-component that
-- iterates from t[1] till t[len(t)] and will return possible nil-values.
function pT.arrayPairs(t, i)
	return arrayPairs_iter, t, 0
end
local arrayPairs = pT.arrayPairs


-- Local helper function for "rarrayPairs()"
local function rarrayPairs_iter(t, i)
	i = i - 1
	if i >= 1 then
		return i, get_i(t,i)
	end
end

--- reverse ipairs-replacement that handles nil values for an pTable's 
-- array-component and iterates down from t[len(t)] till t[1].
function pT.rarrayPairs(t, i)
	return rarrayPairs_iter, t, len(t)+1
end
local rarrayPairs = pT.rarrayPairs


--- Pairs-like iterator that excludes any k that are array indices - 
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

--- Pairs-like iterator that excludes any k that are array indices - 
-- only iterates over the map-component of the pTable.
function pT.mapPairs(t)
	return mapNext, t, nil
end
local mapPairs = pT.mapPairs


-- Helper function for listPairs()
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
	for k,v in pairs(t) do insert(tmp,k) end
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
		if not isIndex(t,k) then insert(tmp,k) end
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
-- Basic "list" specific functions
-- insert, append, first, rest, last, list, concat, 
-------------------------------------------------------------------------------


return pT
