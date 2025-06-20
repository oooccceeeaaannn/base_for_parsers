function undo()
	local result = 0
	HACK_INFINITY = 0
	logevents = false
	
	if (#undobuffer > 1) then
		result = 1
		local currentundo = undobuffer[2]
		
		-- MF_alert("Undoing: " .. tostring(#undobuffer))
		
		do_mod_hook("undoed")
		
		last_key = currentundo.key or 0
		Fixedseed = currentundo.fixedseed or 100
		
		if (currentundo ~= nil) then
			for i,line in ipairs(currentundo) do
				local style = line[1]
				
				if (style == "update") then
					local uid = line[9]
					
					if (paradox[uid] == nil) then
						local unitid = getunitid(line[9])
						
						local unit = mmf.newObject(unitid)
						
						local oldx,oldy = unit.values[XPOS],unit.values[YPOS]
						local x,y,dir = line[3],line[4],line[5]
						unit.values[XPOS] = x
						unit.values[YPOS] = y
						unit.values[DIR] = dir
						unit.values[POSITIONING] = 0
						
						updateunitmap(unitid,oldx,oldy,x,y,unit.strings[UNITNAME])
						dynamic(unitid)
						dynamicat(oldx,oldy)
						
						if (spritedata.values[CAMTARGET] == uid) then
							MF_updatevision(dir)
						end
						
						local ox = math.abs(oldx-x)
						local oy = math.abs(oldy-y)
						
						if (ox + oy == 1) and (unit.values[TILING] == 2) then
							unit.values[VISUALDIR] = ((unit.values[VISUALDIR] - 1)+4) % 4
							unit.direction = unit.values[DIR] * 8 + unit.values[VISUALDIR]
						end
						
						if is_parser(unit) then
							updatecode = 1
						end
						
						local undowordunits = currentundo.wordunits
						local undowordrelatedunits = currentundo.wordrelatedunits
						
						if (#undowordunits > 0) then
							for a,b in pairs(undowordunits) do
								if (b == line[9]) then
									updatecode = 1
								end
							end
						end
						
						if (#undowordrelatedunits > 0) then
							for a,b in pairs(undowordrelatedunits) do
								if (b == line[9]) then
									updatecode = 1
								end
							end
						end
					else
						particles("hot",line[3],line[4],1,{1, 1})
					end
				elseif (style == "remove") then
					local uid = line[6]
					local baseuid = line[7] or -1
					
					if (paradox[uid] == nil) and (paradox[baseuid] == nil) then
						local x,y,dir,levelfile,levelname,vislevel,complete,visstyle,maplevel,colour,clearcolour,followed,back_init,ogname,signtext = line[3],line[4],line[5],line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]
						local name = line[2]
						
						local unitname = ""
						local unitid = 0
						
						--MF_alert("Trying to create " .. name .. ", " .. tostring(unitreference[name]))
						unitname = unitreference[name]
						if (name == "level") and (unitreference[name] ~= "level") then
							unitname = "level"
							unitreference["level"] = "level"
							MF_alert("ALERT! Unitreference for level was wrong!")
						end
						
						unitid = MF_emptycreate(unitname,x,y)
						
						local unit = mmf.newObject(unitid)
						unit.values[ONLINE] = 1
						unit.values[XPOS] = x
						unit.values[YPOS] = y
						unit.values[DIR] = dir
						unit.values[ID] = line[6]
						unit.flags[9] = true
						
						unit.strings[U_LEVELFILE] = levelfile
						unit.strings[U_LEVELNAME] = levelname
						unit.flags[MAPLEVEL] = maplevel
						unit.values[VISUALLEVEL] = vislevel
						unit.values[VISUALSTYLE] = visstyle
						unit.values[COMPLETED] = complete
						
						unit.strings[COLOUR] = colour
						unit.strings[CLEARCOLOUR] = clearcolour
						unit.strings[UNITSIGNTEXT] = signtext or ""
						
						if (unit.className == "level") then
							MF_setcolourfromstring(unitid,colour)
						end
						
						addunit(unitid,true)
						addunitmap(unitid,x,y,unit.strings[UNITNAME])
						dynamic(unitid)
						
						unit.followed = followed
						unit.back_init = back_init
						unit.originalname = ogname
						
						if is_parser(unit) then
							updatecode = 1
						end
						
						if (spritedata.values[VISION] == 1) then
							unit.x = -24
							unit.y = -24
						end
						
						local undowordunits = currentundo.wordunits
						local undowordrelatedunits = currentundo.wordrelatedunits
						
						if (#undowordunits > 0) then
							for a,b in ipairs(undowordunits) do
								if (b == line[6]) then
									updatecode = 1
								end
							end
						end
						
						if (#undowordrelatedunits > 0) then
							for a,b in ipairs(undowordrelatedunits) do
								if (b == line[6]) then
									updatecode = 1
								end
							end
						end
					else
						particles("hot",line[3],line[4],1,{1, 1})
					end
				elseif (style == "create") then
					local uid = line[3]
					local baseid = line[4]
					local source = line[5]
					
					if (paradox[uid] == nil) then
						local unitid = getunitid(line[3])
						
						local unit = mmf.newObject(unitid)
						local unitname = unit.strings[UNITNAME]
						local x,y = unit.values[XPOS],unit.values[YPOS]
						local unittype = unit.strings[UNITTYPE]
						
                        if is_parser(unit) then
							updatecode = 1
						end

						unit = {}
						delunit(unitid)
						MF_remove(unitid)
						dynamicat(x,y)
						
						local undowordunits = currentundo.wordunits
						local undowordrelatedunits = currentundo.wordrelatedunits
						
						if (#undowordunits > 0) then
							for a,b in ipairs(undowordunits) do
								if (b == line[3]) then
									updatecode = 1
								end
							end
						end
						
						if (#undowordrelatedunits > 0) then
							for a,b in ipairs(undowordrelatedunits) do
								if (b == line[3]) then
									updatecode = 1
								end
							end
						end
					end
				elseif (style == "backset") then
					local uid = line[3]
					
					if (paradox[uid] == nil) then
						local unitid = getunitid(line[3])
						local unit = mmf.newObject(unitid)
						
						unit.back_init = line[4]
					end
				elseif (style == "done") then
					local unitid = line[7]
					--print(unitid)
					local unit = mmf.newObject(unitid)
					
					unit.values[FLOAT] = line[8]
					unit.angle = 0
					unit.values[POSITIONING] = 0
					unit.values[A] = 0
					unit.values[VISUALLEVEL] = 0
					unit.flags[DEAD] = false
					
					--print(unit.className .. ", " .. tostring(unitid) .. ", " .. tostring(line[3]) .. ", " .. unit.strings[UNITNAME])
					
					addunit(unitid,true)
					unit.originalname = line[9]
					
					if (unit.values[TILING] == 1) then
						dynamic(unitid)
					end
				elseif (style == "float") then
					local uid = line[3]
					
					if (paradox[uid] == nil) then
						local unitid = getunitid(line[3])
						
						-- K�kk� ratkaisu!
						if (unitid ~= nil) and (unitid ~= 0) then
							local unit = mmf.newObject(unitid)
							unit.values[FLOAT] = tonumber(line[4])
						end
					end
				elseif (style == "levelupdate") then
					MF_setroomoffset(line[2],line[3])
					mapdir = line[6]
				elseif (style == "maprotation") then
					maprotation = line[2]
					MF_levelrotation(maprotation)
				elseif (style == "mapdir") then
					mapdir = line[2]
				elseif (style == "mapcursor") then
					mapcursor_set(line[3],line[4],line[5],line[10])
					
					local undowordunits = currentundo.wordunits
					local undowordrelatedunits = currentundo.wordrelatedunits
					
					local unitid = getunitid(line[10])
					if (unitid ~= nil) and (unitid ~= 0) then
						local unit = mmf.newObject(unitid)
						
						if is_parser(unit) then
							updatecode = 1
						end
					end
					
					if (#undowordunits > 0) then
						for a,b in pairs(undowordunits) do
							if (b == line[10]) then
								updatecode = 1
							end
						end
					end
					
					if (#undowordrelatedunits > 0) then
						for a,b in pairs(undowordrelatedunits) do
							if (b == line[10]) then
								updatecode = 1
							end
						end
					end
				elseif (style == "colour") then
					local unitid = getunitid(line[2])
					MF_setcolour(unitid,line[3],line[4])
					local unit = mmf.newObject(unitid)
					unit.values[A] = line[5]
				elseif (style == "broken") then
					local unitid = getunitid(line[3])
					local unit = mmf.newObject(unitid)
					--MF_alert(unit.strings[UNITNAME])
					unit.broken = 1 - line[2]
				elseif (style == "bonus") then
					local style = 1 - line[2]
					MF_bonus(style)
				elseif (style == "followed") then
					local unitid = getunitid(line[2])
					local unit = mmf.newObject(unitid)
					
					unit.followed = line[3]
				elseif (style == "startvision") then
					local target = line[2]
					
					if (line[2] ~= 0) and (line[2] ~= 0.5) then
						target = getunitid(line[2])
					end
					
					visionmode(0,target,true)
				elseif (style == "stopvision") then
					local target = line[2]
					
					if (line[2] ~= 0) and (line[2] ~= 0.5) then
						target = getunitid(line[2])
					end
					
					visionmode(1,target,true,{line[3],line[4],line[5]})
				elseif (style == "visiontarget") then
					local unitid = getunitid(line[2])
					
					if (spritedata.values[VISION] == 1) and (unitid ~= 0) then
						local unit = mmf.newObject(unitid)
						MF_updatevision(unit.values[DIR])
						MF_updatevisionpos(unit.values[XPOS],unit.values[YPOS])
						spritedata.values[CAMTARGET] = line[2]
					end
				elseif (style == "holder") then
					local unitid = getunitid(line[2])
					local unit = mmf.newObject(unitid)
					
					unit.holder = line[3]
				end
			end
		end
		
		local nextundo = undobuffer[1]
		nextundo.wordunits = {}
		nextundo.wordrelatedunits = {}
		nextundo.visiontargets = {}
		nextundo.fixedseed = Fixedseed
		
		for i,v in ipairs(currentundo.wordunits) do
			table.insert(nextundo.wordunits, v)
		end
		for i,v in ipairs(currentundo.wordrelatedunits) do
			table.insert(nextundo.wordrelatedunits, v)
		end
		
		if (#currentundo.visiontargets > 0) then
			visiontargets = {}
			for i,v in ipairs(currentundo.visiontargets) do
				table.insert(nextundo.visiontargets, v)
				
				local fix = MF_getfixed(v)
				if (fix ~= nil) then
					table.insert(visiontargets, fix)
				end
			end
		end
		
		table.remove(undobuffer, 2)
	end
	
	--MF_alert("Current fixed seed: " .. tostring(Fixedseed))
	
	do_mod_hook("undoed_after")
	logevents = true
	
	return result
end