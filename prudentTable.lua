--[[
prudentTable.lua
--]]

local prudentTable = {}

-- weak table for representing proxied storage tables.
local data = setmetatable({}, {__mode = 'k'})

-- weak table for representing the size/length/count of array-tables.
-- n = tableLenT[t] or 0
local tableLenT = setmetatable({}, {__mode = 'k'})

-- weak table for representing the pre-condition and transform functions per prudentTable instance for setting of array values.
-- functions should have signature: setCond(v,i,t) => successOrFail, setValue
local arrayConstraintT = setmetatable({}, {__mode = 'k'})

prudentTable.arrayLengthKey = "uri:http://www.luna.org/ns/arrayLength"
local arrayLengthKey = prudentTable.arrayLengthKey

prudentTable.arrayDefaultValueKey = "uri:http://www.luna.org/ns/arrayDefaultValue"
local arrayDefaultValueKey = prudentTable.arrayDefaultValueKey

local function isGT0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k > 0  
end

local function isGE0Int(k)
	return	type(k)=="number" and k == math.floor(k) and k >= 0  
end

-------------------------------------------------------------------------------
--  Array Default Value
-------------------------------------------------------------------------------

--local weak-table to maintain the registered default array-values for tables
local arrayDefaultT = setmetatable({}, {__mode = 'k'})

--- A default array value dv is registered for the table t.
--@param t table
--@param dv Any value (default for default is nil - also used to "reset")
--@return unmodified table t
function prudentTable.setArrayDefault(t,dv)
	arrayDefaultT[t] = dv
	return t
end
local setArrayDefault = prudentTable.setArrayDefault

--- For table t, returns the registered default array value.
--@param t table
--@return Registered value (any type - nil is default)
function prudentTable.getArrayDefault(t)
	return arrayDefaultT[t]
end
local getArrayDefault = prudentTable.getArrayDefault

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Permanent Keys
-------------------------------------------------------------------------------

--local weak-table to maintain the registered permanent keys for tables
local permKeysT = setmetatable({}, {__mode = 'k'})

--- For table t, the list of keys are registered as permanent keys.
--@param t table
--@param ... one or more keys (anything but nil)
--@return unmodified table t
function prudentTable.setPermKey(t,...)
	assert(type(t)=="table")
	permKeysT[t] = permKeysT[t] or {}
	pKt = permKeysT[t]
	local tmp = {...}
	for i = 1, select("#",...) do
		local pk = tmp[i]
		if(not pk~=nil)then pKt[pk] = true end
	end
	return t
end
local setPermKey = prudentTable.setPermKey

--- For table t, key pk is unregistered as a permanent key.
--@param t table
--@param pk key (anything but nil)
--@return unmodified table t
function prudentTable.removePermKey(t,pk)
	permKeysT[t] = permKeysT[t] or {}
	local pkt = permKeysT[t]
	pkt[pk] = nil
	return t
end
local removePermKey = prudentTable.removePermKey

--- For table t, returns whether key k is registered as a permanent key.
--@param t table
--@param pk key (anything but nil)
--@return Boolean
function prudentTable.isPermKey(t,k)
	permKeysT[t] = permKeysT[t] or {}
	return permKeysT[t][k] == true or isAIndex(t,k)
end
local isPermKey = prudentTable.isPermKey

--- For table t, returns a list of all registered permanent keys
--@param t table
--@return List of keys
function prudentTable.permKeys(t)
	-- need some more functional-functions...
	-- return func.keys(permKeysT[t])
end


-------------------------------------------------------------------------------

--- Returns whether the key k is a valid index for the array-component of table t
--@param t table instance
--@param k a possible array index value
--@return boolean - true indicates k is integer and 1 <= k <= len(t)
function prudentTable.isAIndex(t,k)
	return isGT0Int(k) and k <= (tableLenT[t] or 0)
end
local isAIndex = prudentTable.isAIndex


--- Returns whether the t has been managed as a prudentTable.
-- (only tests whether len(t) has ever been set - no guarantees about "integrity")
--@param t Lua table
--@return boolean - true indicates t has been managed as a prudentTable
function prudentTable.isprudentTable(t) return len(t)~=nil end
local isprudentTable = prudentTable.isprudentTable


--- Returns the non-nil length/size of the array component of a standard Lua table
-- Simply loops from index 1 until the first nil-valued element
--@param aLuaTable "standard" table
--return size of non-nil array (integer >= 0)
function prudentTable.nonNilLen(aLuaTable)
	assert(type(aLuaTable) == "table")
	local n = 1
	while aLuaTable[n] ~= nil do n=n+1 end
	return n - 1
end
local nonNilLen = prudentTable.nonNilLen


--- Returns whether the Lua table lt's length may be ambiguous by comparing lt's non-nil array size with #lt
--param lt A "standard" table
--return Boolean: true if non-nil length equals #
function prudentTable.isTableLenOK(lt)
	return nonNilLen(lt) == #lt
end
local isTableLenOK = prudentTable.isTableLenOK


-------------------------------------------------------------------------------
-- "constraint/precondition" specific functions for array
-- 
-------------------------------------------------------------------------------

function prudentTable.setArrayConstraint(t,aPreCondFun)
	arrayConstraintT[t] = aPreCondFun
	local pcf = arrayConstraintT[t]
	local d = data[t]
	-- verify array to keep consistency
	for i,v in prudentTable.arrayPairs(t) do
		r,v = pcf(v,i,t)
		assert(r,"Precondition failure on index '"..i.."' and value '"..tostring(v).."'")
		d[i] = v
	end
	return t
end

-- should have a static testPreCond function to test the result of an entry before the actual entry


-------------------------------------------------------------------------------
-- Basic "array" specific functions
-- get, set, array, len, setLen 
-------------------------------------------------------------------------------

--- Returns the size of the array component of table t
--@param t An table instance - will throw exception if other type
--@return Integer >= 0 indicating the size of ATAble's array
function prudentTable.len(t)
	--assert(isprudentTable(t), "Argument is not an prudentTable instance")
	--local mt = getmetatable(t)
	--local len = mt.__len
	return tableLenT[t] or 0 -- should just work or barf
end
local len = prudentTable.len

--- Set the size of the array component of table t.
-- If size is increased, it may make existing map entries become part of the array.
-- I size is decreased, then some array components may become map entries
-- No entries or values are deleted or nil'ed
--@param t An table instance - will throw exception if other type
--@param n Integer >= 0
function prudentTable.setLen(t, n, pedantic)
	--assert(isprudentTable(t) and isGT0Int(n))
	assert(isGE0Int(n))
	if pedantic then
		local oldn = tableLenT[t]
		if n == oldn then return t end  -- nothing to do
		local b,e
		if oldn < n then b,e=oldn+1,n else b,e=n+1,oldn end
		for i = b,e do t[i]=nil end   -- nil-out all new or old array elements
	end
	tableLenT[t] = n
	return t
end
local setLen = prudentTable.setLen


function prudentTable.newTable(...)
	local t = {...}
	tableLenT[t] = select('#', ...)
	return t
end
local newTable = prudentTable.newTable


--- Returns n element values as a list, starting at index b of table t.
-- Range must not extend array boundaries.
-- May return default values if so registered for t.
--@param t a table instance
--@param b start of range (>=1)
--@param n  number of element-values to return - b+n-1 <= len(t) - n default to 1 - n may be 0
--@return one or more values (including possible nils)
function prudentTable.aGet(t,b,n)
	--assert(isprudentTable(t))
	assert(isAIndex(t,b))
	n = n or 1
	if n==0 then return end
	assert(isAIndex(t,b+n-1))
	d = getArrayDefault(t)
	if d then
		local tmp = {}
		for i = b,b+n-1 do
			tmp[i-b+1] = t[i] or d
		end
		return unpack(tmp,1,n)
	else
		return unpack(t,b,b+n-1)
	end
end
local aGet = prudentTable.aGet


--- Copies a list of values into the array-component of table t starting at index b
-- Array-size must be able to accomodate the list as it does not grow automatically.
--@param t an table instance
--@param b target start-index
--@param ... list of zero, one or more values
--@returns modified table t
function prudentTable.aSet(t,b,...)
	--assert(isprudentTable(t))
	assert(isAIndex(t,b))
	local tmp = {n = select('#', ...), ...}
	if tmp.n == 0 then return t end
	assert( (b + tmp.n - 1) <= len(t))
	for i = 0,tmp.n-1 do t[b+i] = tmp[i+1] end
	return t
end
local aSet = prudentTable.aSet


--- Extends and adds a list of values at the end of the array-component 
-- of table t.
-- Array-size is increased to accomodate the list of values. (nils are added)
--@param t a table instance
--@param ... list of zero, one or more values
--@return modified table t
function prudentTable.aAdd(t,...)
	local n = select('#', ...)
	if n == 0 then return t end
	local oldLen = len(t)
	setLen(t, oldLen+n)
	aSet(t,oldLen+1,...)
	return t
end
local aAdd = prudentTable.aAdd


--- Extends and inserts a list of values at index b of table t.
-- Array-size is increased to accomodate the list of values.
-- Existing elements are moved-up - no values are overwritten.
-- (nils are added)
--@param t a table instance
--@param b Starting index for insertion
--@param ... list of zero, one or more values
--@returns modified table t
function prudentTable.aInsert(t,b,...)
	-- accommodate inserting into empty, zero-size array
	if(len(t) == 0 and b == 1) then return aAdd(t,...) end
	assert(isAIndex(t,b))
	local n = select('#', ...)
	if n==0 then return t end
	local oldLen = len(t)
	setLen(t, oldLen+n)     -- extend size
	print("aInsert:", oldLen,len(t),b,n)
	aSet(t,b+n,aGet(t,b,n)) -- move up
	aSet(t,b,...)           -- insert
	return t
end
local aInsert = prudentTable.aInsert


--- Removes n elements from table t starting with index b, 
-- and decreases the array size accordingly. 
-- (does not treat elements with nil-value special)
--@param t an table instance
--@param b Starting index for removal.
--@param n Number of elements to remove. (default is 1, may be 0)
--@returns modified table t
function prudentTable.aRemove(t,b,n)
	assert(isAIndex(t,b))
	n = n or 1
	if n==0 then return t end
	assert(isAIndex(t,b+n-1))
	local oldLen = len(t)
	if b+n-1 < oldLen then
		aSet(t,b, aGet(t,b+n,oldLen-b-n))
	end
	setLen(t, oldLen-n)
	return t
end
local aRemove = prudentTable.aRemove


-------------------------------------------------------------------------------
-- pack and unpack replacements that are prudentTable-aware
-- pack, unpack 
-------------------------------------------------------------------------------

--- Replacement for the table constructor pack(), which takes a list of arguments 
-- and adds them as array-elements of a new array. This pack registers the array 
-- length and also uses the "convention" of adding an entry: n = select('#', ...).
-- (the latter is NOT used by prudentTable - just trying to play nice...)
--@param ... List of elements to add to the array-component of the newly created table
--@return Newly created table instance
function prudentTable.pack(...)
	local t = {n = select('#', ...), ...}
	setLen(t, t.n)
	return t 
end

--- Unpacks a table-array (from a previously packed-list) into a new list of values.
-- Note that unpack relies on proper predentTable.setLen() registration, 
-- either thru prudentTable.pack() or some other prudentTable-function.
-- It does NOT use any "t.n" that may be used to indicates the array-length.
-- May return default values if so registered for t.
--@param t table instance
--@param b start of range to copy - default to 1
--@param e end of range to copy - defaults to len(t)
--@return list of values representing t[b:e] - may include nils
function prudentTable.unpack(t,b,e)
	assert(type(t)=="table")
	e = e or len(t)
	if e==0 then return end
	b = b or 1
	return aGet(t,b,e-b+1) 
end


-------------------------------------------------------------------------------
-- Basic "iterator" specific functions
-- arrayPairs, mappairs, tablepairs 
-------------------------------------------------------------------------------

--- Local helper function for "arrayPairs()"
local function arrayPairs_iter(t, i)
	i = i + 1
	if i <= (tableLenT[t] or 0) then
		return i, aGet(t,i)
	end
end

--- Local helper function for "rarrayPairs()"
local function rarrayPairs_iter(t, i)
	i = i - 1
	if i >= 1 then
		return i, aGet(t,i)
	end
end

--- ipairs-replacement that handles nil values for an prudentTable's array-component
-- and iterates from t[1] till t[len(t)]
function prudentTable.arrayPairs(t, i)
	return arrayPairs_iter, t, 0
end

--- reverse ipairs-replacement that handles nil values for an prudentTable's 
-- array-component and iterates down from t[len(t)] till t[1].
function prudentTable.rarrayPairs(t, i)
	return rarrayPairs_iter, t, len(t)+1
end

--- Pairs-like iterator that excludes any k that are array indices - 
-- only iterates over the map-component of the prudentTable.
function prudentTable.atablenext(t, k)
	local d = data[t]
	if not d then return end
	k = next(d, k)
	return k
end
local atablenext = prudentTable.atablenext

--- Pairs-like iterator that includes all assigned keys - 
-- Ignores array entries with nil values.
function prudentTable.atablepairs(t, i)
	return atablenext, t, nil
end

--- Pairs-like iterator that excludes any k that are array indices - 
-- Only iterates over the map-component of the prudentTable.
function prudentTable.mapnext(t, k)
	local d = data[t]
	if not d then return end
	k = next(d, k)
	while k do
		if not isAIndex(k) then break end
		k = next(d, k)
	end
	return k
end
local mapnext = prudentTable.mapnext

--- Pairs-like iterator that excludes any k that are array indices - 
-- only iterates over the map-component of the prudentTable.
function prudentTable.mappairs(t, i)
	return mapnext, t, nil
end

-------------------------------------------------------------------------------
-- Basic "list" specific functions
-- insert, append, first, rest, last, list, concat, 
-------------------------------------------------------------------------------


--- Returns whether a key k exists in table t.
-- A key k exists when:
-- * it has a normal map entry where a non-nil value is returned for t[k]
-- * it has been registered as a "permanent key"  - may have nil value
-- * key is valid array index: k is integer and 0 < k <= len(t)
--@param t table
--@param k key (not-nil)
--@return Boolean indicating whether k is an existing key for table t
function prudentTable.keyExists(t, k)
	assert(type(t)=="table")
	assert(k~=nil)
	return t[k]~=nil or (permKeysT[t]~=nil and permKeysT[t][k]~=nil) or isAIndex(t,k)
end
local keyExists = prudentTable.keyExists

--- Returns a list of all the "lua-defined" keys in table t
function prudentTable.tableKeys(t)
	local tmp = prudentTable.pack()
	for k,v in pairs(t) do aAdd(tmp,k) end
	return prudentTable.unpack(tmp)
end

--- Returns a list of all the keys of the map-component of table t
function prudentTable.mapKeys(t)
	local tmp = prudentTable.pack()
	for k,v in pairs(t) do 
		if not isAIndex(t,k) then aAdd(tmp,k) end
	end
	pks = permKeysT[t]
	if pks then
		for k,v in pairs(pks) do
			if not t[k] then aAdd(tmp,k) end
		end
	end
	return prudentTable.unpack(tmp)
end

-------------------------------------------------------------------------------

return prudentTable
