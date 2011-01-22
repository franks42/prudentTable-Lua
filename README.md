prudentTable.lua
================

local pT = require("prudentTable")  -- this is assumed for all code-snippets in this doc.

prudentTable is a Lua-module that attempts to facilitate consistent and save processing of array-related operations with Lua-tables.

With some effort, this module allows you to maintain an array-component of a Lua-table as if it is an prudentTable-array. It requires some discipline and care to keep the consistency, but it is definitely feasible. The one important rule for this is to stay away from the "#" as far as you can and not to use any of the standard library functions that may use it (like ipairs, insert, remove, etc.). This module will provide alternatives for all those suspect library functions.

This module also defines an "atArray" datatype, that essentially encapsulates a Lua-table such that only save operations are allowed and the internal consistency can be enforced. This is a good alternative for the less adventurous among us (...like me).

prudentTable Usage Conventions
-------------------------

Do's:

*  All tables returned by any of the prudentTable functions has been properly registered (even the empty-tables).
*  Use pT.pack(...) as your generic array-table constructor
*  "Normally" you will see no or little need to explicitly register a table size, because all the prudentTable functions that need to, will do it for you.
*  If you have to set the length for table t, because the size is unknown or different from the registered one, use pT.setLen(t,n)
*  Use pT.aGet(t,i) instead of t[i] if you care about array-boundary checking when you want to get an array-component's value by index
*  Use pT.aSet(t,i,v) instead of t[i]=v if you care about array-boundary checking when you want to set an array-component's value by index. Note that if t[i]=v is assigned to an element outside of the range 1 <= i <= pT.len(t), then your array is **NOT** automatically resized (hint: use pT.aAdd() for adding to the end of an array).

Don't's:

*  **Never ever** use #t, but instead use pT.len(t)
*  **Never ever** use t[#t+1]=obj to add, but instead use pT.aAdd(t,obj)
*  Do not use {}, but instead use the table constructer "pT.pack()"such that the resulting (empty-) table is properly registered with size 0.
*  Do not use the Lua-standard functions ipairs, table.insert, table.remove - use the prudentTable provided alternatives: pT.arrayPairs, pT.rarrayPairs, pT.aInsert, pT.aRemove

prudentTable-array definition
-----------------------------

There are many different definitions of "array", so we try to be precise with prudentTable's definition to avoid any confusion: An prudentTable-array is a data-structure that contains one or more data elements which are individually accessed thru a positive integer index ranging from 1 till N, where N also indicates the number of elements in the array. From now on, when we just say array in this document, we refer to prudentTable-array.

Note that prudentTable-arrays have no holes and that nils are allowed. (To be honest, I've never understood what an array with holes is...but whatever that may be, it is different from an prudentTable-array).

### pT.len(t) and pT.setLen(t,n) and pT.isAIndex(t,k)
In Lua, we represent this prudentTable-array with an ordinary Lua-table t, and we use the function pT.len(t) to get the length of the array, i.e. its number of elements. We use pT.setLen(t,n) to set the length of array t. In other words, the length of an array is always explicitly set, with the exception of some constructors where there is no ambiguity about the number of elements that should be allocated.
We also have the test-fuction pT.isAIndex(t,k), which tells us whether a key k is an index of the array-component of t.

To be or not to be (...nil)... what is the Q?
---------------------------------------------

Lua has this great, peculiar, multipurpose datatype and value called "nil". A value of nil kind of indicates that there is no value at all, or that it is undefined, or doesn't exist, or that it is unassigned, or a little bit of all combined. In most cases, the exact semantics doesn't matter too much, but in some cases you want to pin it down more. 

For arrays... at least for prudentTable-arrays, a value of nil for an array-element only implies that its value is unassigned, because a meaning of "does not exist", doesn't make sense for an array-element. Once an array t is defined by the indices 1 till n, then each of t[i] where 1 <= i <= n does exist - that is how it is defined - no doubt about it. The only possible meaning for nil in t[i]=nil is that the value for t[i] equals nil, meaning element does exist but has-no-value/is-unassigned.

Note that this semantics of a nil-value for prudentTable-arrays implies:

*  the array-length is completely unaffected by any nil-values the array-elements might have because it is independently defined of its content.

*  that iterations over the array should not care about any element's nil-value, and certainly shouldn't stop or jump or get nervous because of it.

*  that "insert" or "remove" operations should work consistently and independently of the values of the array-elements (we'll get back to insert/remove...)

*  that a nil value becomes nothing more than a default value for an array-element that hasn't been assigned (we'll get back to default values...)

*  that a nil value can be assigned to an array element to indicate that its value is undefined, which is no different from assigning it any other "allowed" value for that particular array (we'll get back to pre-conditions/invariants for element values...)

### pT.arrayPairs(t)
The iterator arrayPairs(t) always iterates over all the elements with index 1 till pT.len(t) independent of the elements' values.

	for i,v in pT.arrayPairs(t) do print i,v end
	=>  1,"one"
	    2,nil
	    ...
	
So instead of using the standard ipairs() implementation, one should use arrayPairs() if you want your life to be more predictable.

Clear separation between array- and map-components of a Lua-table
-----------------------------------------------------------------

The "Lua-table" is an incredibly versatile data-structure and its hash-table-like interface is molded to present the user with multiple personalities: an array-component and a map-component. The problem is that sometimes those personalities seem to fuze when it's unclear what table elements are truly part of the array-component and which are pure map entries. The associated confusion can lead to a somewhat schizophrenic table-view. 

The prudentTable-array is the array component of a Lua-table t and is defined by all positive integer keys smaller-equal to pT.len(t). The namespace for all the possible keys for the map-component of t are all possible keys except those used by the array-component. 
As a consequence, when we change the size of the array from say 10 to 15, then we take away 5 possible keys from the map-component and move those to the array-keys. When we decrease the array length, the opposite it true: we remove array-keys and add them to the map-key-namespace.

This clear distinction is important to explain the different "sizes", or number of iterations between the table, its array-component and its map-component. Because of the somewhat ambiguous use of nil, we will try to avoid any confusion by clear separation.

### pT.mapLen(t) and pT.mapPairs(t)
We define a pT.mapLen(t) to be the number of k-v-pairs that are-defined/do-exist, and that are not part of the array-component. Note there is no setMapLen() as the map-length is determined by the counting of existing entries.
In addition, we define an associated iterator mapPairs(t) to iterate only over those existing pairs that are not part of the array-component.

    t = pT.table(1,2,nil,nil,nil,nil,7,8,nil,nil)
    t["one"] = "uno"; t["two"]="dos";t["three"]="tres"
    pT.len(t) => 10
    pT.mapLen => 3
    n=0; for k,v in pairs(t) do n=n+1 end; => n=7

In other words, the number of defined entries in table t is not equal to the number of array-entries plus the number of map-entries, but all is still good...

References
----------
The following links show where some of the ideas came from. Thanks to the respective authors for their willingness to share.

* David Manura, "array of keys in table", ("http://snippets.luacode.org/?p=snippets/array_of_keys_in_table_77")
* Steve Donovan, "Iterating over the hash part of a table", ("http://snippets.luacode.org/?p=snippets/Iterating_over_the_hash_part_of_a_table_6") 
* Steve Donovan, "Insert Values from one table into another" ("http://snippets.luacode.org/?p=snippets/tInsert_Values_from_one_table_into_another_25")
* David Manura, "Storing Nils In Tables", ("http://lua-users.org/wiki/StoringNilsInTables")


