
local physics = require("physics")
physics.start()
GlobalPhysicsEngineRunning = true
physics.setScale( 60 )
physics.setGravity( 0, 0 )
--system.activate( "multitouch" )
--physics.setDrawMode("debug")
--physics.setDrawMode("hybrid")

display.setStatusBar( display.HiddenStatusBar )

--
local json = require("cadkjson")
local pp = json.pp
local ppdb = json.ppdb

--require("test")
require("prudentTable-examples")

--local pL = require("prudentList")


