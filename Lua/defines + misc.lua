-- Use the in-game menu now.

table.insert(mod_hook_functions["level_start"], function()
	metatext_fixquirks = get_setting("fix_quirks") --[[Set this to FALSE to:
Make TEXT/META# IS TELE link text units of the same type together rather than all text units included.
(Removed as of v469) Make TEXT IS MORE allow text units to grow into other text units as long as they are not the same type.
Make TEXT/META# IS GROUP, NOUN HAS/MAKE/BECOME GROUP make NOUN HAS/MAKE/BECOME every text included.
Make TEXT/META# IS GROUP, NOUN NEAR GROUP force noun to be near every text included.]]

	metatext_overlaystyle = get_setting("overlay_style", true) --[[Has 3 options:
0 disables this feature.
1 enables overlay if the "meta level" (the amount of times "text_" appears in the name excluding
if the name ends with "text_") does not match the name of the object.
Anything else always enables the overlay.]]

	metatext_textisword = get_setting("text_word") --Makes TEXT IS WORD a default rule, and breaking it will make text not parse.

	metatext_istextnometa = get_setting("is_nometa") --[[Makes METATEXT IS TEXT not turn the text object into it's metatext
counterpart, instead making it not transform.
Not recommended to set to TRUE if you are not using the Meta/Unmeta addon.]]

	metatext_hasmaketextnometa = get_setting("hasmake_nometa") --[[Makes METATEXT HAS/MAKE TEXT not make the text object have/make
it's metatext counterpart. Since you can't make Has/Make Meta/Unmeta, this is really only useful for
consistency I guess.]]

	metatext_autogenerate = get_setting("auto_gen", true) --[[Tries to add more metatext to the object palette if it does not exist.
Can only add up to 35 additional objects. REQUIRES metaunmeta.lua.
Comes with the following options:
0 disables this feature.
1 tries to use the correct sprite, if it exists. Otherwise, it uses the default.
2 is like 1, but if the sprite doesn't exist, it won't generate.
Anything else always uses the default sprite. If you choose this, you're gonna want the overlay on.
Note that if the nonexistant text is available in the editor object list, that will be referenced instead.]]

	metatext_includenoun = get_setting("include_noun") --Includes nouns in NOT META#.

	metatext_egg = get_setting("easter_egg")       --Easter egg. Set to FALSE to disable.
end
)

-- New function, checks if rule relies on certain noun. Based off of hasfeature()
function checkiftextrule(rule1, rule2, rule3, unitid, findtextrule_, findtag_)
	local findtag = "text"
	local findtextrule = false
	if findtextrule_ ~= nil then
		findtextrule = findtextrule_
	end
	if findtag_ ~= nil then
		findtag = findtag_
	end
	if (featureindex[rule3] ~= nil) and (rule2 ~= nil) and (rule1 ~= nil) then
		for i, rules in ipairs(featureindex[rule3]) do
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]
			local foundtag = false
			for num, tag in pairs(tags) do
				if tag == findtag then
					foundtag = true
					break
				end
			end

			if (conds[1] ~= "never") and (foundtag == findtextrule) then
				if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == rule3) then
					if testcond(conds, unitid) then
						return findtextrule
					end
				end
			end
		end
	end
	return (not findtextrule)
end

-- Enables TEXT IS WORD behavior with letters if enabled
function formlettermap()
	letterunits_map = {}

	local lettermap = {}
	local letterunitlist = {}

	if (#letterunits > 0) then
		for i, unitid in ipairs(letterunits) do
			local unit = mmf.newObject(unitid)

			if (unit.values[TYPE] == 5) and (unit.flags[DEAD] == false) then
				local valid = true
				if metatext_textisword and (#wordunits > 0) then
					valid = false
					for c, d in ipairs(wordunits) do
						if (unitid == d[1]) and testcond(d[2], d[1]) then
							valid = true
							break
						end
					end
				end
				if valid then
					local x, y = unit.values[XPOS], unit.values[YPOS]
					local tileid = x + y * roomsizex

					local name = string.sub(unit.strings[UNITNAME], 6)

					if (lettermap[tileid] == nil) then
						lettermap[tileid] = {}
					end

					table.insert(lettermap[tileid], { name, unitid })
				end
			end
		end

		for tileid, v in pairs(lettermap) do
			local x = math.floor(tileid % roomsizex)
			local y = math.floor(tileid / roomsizex)

			local ux, uy = x, y - 1
			local lx, ly = x - 1, y
			local dx, dy = x, y + 1
			local rx, ry = x + 1, y

			local tidr = rx + ry * roomsizex
			local tidu = ux + uy * roomsizex
			local tidl = lx + ly * roomsizex
			local tidd = dx + dy * roomsizex

			local continuer = false
			local continued = false

			if (lettermap[tidr] ~= nil) then
				continuer = true
			end

			if (lettermap[tidd] ~= nil) then
				continued = true
			end

			if (#cobjects > 0) then
				for a, b in ipairs(v) do
					local n = b[1]
					if (cobjects[n] ~= nil) then
						continuer = true
						continued = true
						break
					end
				end
			end

			if (lettermap[tidl] == nil) and continuer then
				letterunitlist = formletterunits(x, y, lettermap, 1, letterunitlist)
			end

			if (lettermap[tidu] == nil) and continued then
				letterunitlist = formletterunits(x, y, lettermap, 2, letterunitlist)
			end
		end

		if (unitreference["text_play"] ~= nil) then
			letterunitlist = cullnotes(letterunitlist)
		end

		for i, v in ipairs(letterunitlist) do
			local x = v[3]
			local y = v[4]
			local w = v[6]
			local dir = v[5]

			local dr = dirs[dir]
			local ox, oy = dr[1], dr[2]

			--[[
      MF_debug(x,y,1)
      MF_alert("In database: " .. v[1] .. ", dir " .. tostring(v[5]))
      ]]
			--

			local tileid = x + y * roomsizex

			if (letterunits_map[tileid] == nil) then
				letterunits_map[tileid] = {}
			end

			table.insert(letterunits_map[tileid], { v[1], v[2], v[3], v[4], v[5], v[6], v[7] })

			if (w > 1) then
				local endtileid = (x + ox * (w - 1)) + (y + oy * (w - 1)) * roomsizex

				if (letterunits_map[endtileid] == nil) then
					letterunits_map[endtileid] = {}
				end

				table.insert(letterunits_map[endtileid], { v[1], v[2], v[3], v[4], v[5], v[6], v[7] })
			end
		end
	end
end

-- Try to add more metatext if it doesn't exist.
function tryautogenerate(want, have)

	if (objectpalette[want] ~= nil or unitreference[want] ~= nil) then return true end
	if is_str_special_prefix(want) then
		return false -- fix silly edgecase
	else
		if metatext_autogenerate ~= 0 then
		if editor_objlist_reference[want] ~= nil then
			local data = editor_objlist[editor_objlist_reference[want]]
			local root = data.sprite_in_root
			if root == nil then
				root = true
			end
			local colour = data.colour
			local active = data.colour_active
			local colourasstring = colour[1] .. "," .. colour[2]
			local activeasstring = "0,0"
			if active ~= nil then
				activeasstring = active[1] .. "," .. active[2]
			end
			local new =
			{
				want,
				data.sprite or data.name,
				colourasstring,
				data.tiling,
				data.type or 0,
				data.unittype,
				activeasstring,
				root,
				data.layer or 10,
				nil,
			}
			local target = "120"
			while target ~= "156" do
				local done = true
				for objname, data in pairs(objectpalette) do
					if data == "object" .. target then
						done = false
						target = tostring(tonumber(target) + 1)
						while string.len(target) < 3 do
							target = "0" .. target
						end
					end
				end
				if done then break end
			end
			if target == "156" then
				return false
			else
				savechange("object" .. target, new, nil, true)
				dochanges_full("object" .. target)
				objectpalette[want] = "object" .. target
				objectlist[want] = 1
				if root == true then
					fullunitlist[want] = "fixroot" .. (data.sprite or data.name)
				else
					fullunitlist[want] = "fix" .. (data.sprite or data.name)
				end
				return true
			end
		elseif have == nil then
			local test = want
			local count = 0
			if objectpalette["text_" .. test] == nil then
				while objectpalette[test] == nil do
					if is_str_special_prefixed(test) and not is_str_special_prefix(test) then
						test = get_ref(test)
						count = count + 1
					else
						local lowestlevel = "text_" .. test
						if lowestlevel == "text_" then
							lowestlevel = "text_text_"
						end
						local SAFETY = 0
						while (not getmat_text(lowestlevel)) and SAFETY <= 1000 do
							lowestlevel = "text_" .. lowestlevel
							SAFETY = SAFETY + 1
						end
						-- this shouldn't happen, but just in case
						if SAFETY >= 1000 then
							return false
						end
						have = lowestlevel
						break
					end
				end
				if have == nil then
					have = test
				end
			else
				have = "text_" .. test
			end
		end
		if not is_str_special_prefixed(have) then
			have = get_pref(want) .. have
		end
		print("Trying to generate " .. want .. " from " .. have .. ".")
		local realname = objectpalette[have]
		local root = getactualdata_objlist(realname, "sprite_in_root")
		local colour = getactualdata_objlist(realname, "colour")
		local active = getactualdata_objlist(realname, "active")
		if colour == nil then
			return false
		end
		local sprite = getactualdata_objlist(realname, "sprite", true) or getactualdata_objlist(realname, "name")
		local colourasstring = colour[1] .. "," .. colour[2]
		local activeasstring = "0,0"
		if active ~= nil then
			activeasstring = active[1] .. "," .. active[2]
		end
		local tiling = getactualdata_objlist(realname, "tiling")
		local type = getactualdata_objlist(realname, "unittype")
		local broadname = get_broaded_str(want)
		if parser_extra_data[broadname] ~= nil then
			if parser_extra_data[broadname].unittype ~= nil then
				type = parser_extra_data[broadname].unittype
			end
			if parser_extra_data[broadname].tiling ~= nil then
				tiling = parser_extra_data[broadname].tiling
			end
		end
		local new =
		{
			want,
			sprite,
			colourasstring,
			tiling,
			0,
			type,
			activeasstring,
			root,
			getactualdata_objlist(realname, "layer"),
			nil,
		}
		if metatext_autogenerate == 1 or metatext_autogenerate == 2 then
			local spritewanted = get_pref(want)
			local base = want
			for _,k in ipairs(special_prefixes) do
				base = string.gsub(base,k,"")
			end
			spritewanted = spritewanted..base
			if MF_findsprite(spritewanted .. "_0_1.png", false) or MF_findsprite(spritewanted .. "_0_1.png", true) then
				sprite = spritewanted
				new[2] = sprite
				root = MF_findsprite(spritewanted .. "_0_1.png", true)
				new[8] = root
			elseif metatext_autogenerate == 2 then
				return false
			end
		end
		local target = "120"
		while target ~= "156" do
			local done = true
			for objname, data in pairs(objectpalette) do
				if data == "object" .. target then
					done = false
					target = tostring(tonumber(target) + 1)
					while string.len(target) < 3 do
						target = "0" .. target
					end
				end
			end
			if done then break end
		end
		if target == "156" then
			return false
		else
			savechange("object" .. target, new, nil, true)
			dochanges_full("object" .. target)
			objectpalette[want] = "object" .. target
			objectlist[want] = 1
			if root == true then
				fullunitlist[want] = "fixroot" .. sprite
			else
				fullunitlist[want] = "fix" .. sprite
			end
			return true
		end
	end
		return false
	end
end

-- Allows metatext to be named in editor.
if old_editor_trynamechange == nil then
	old_editor_trynamechange = editor_trynamechange
end
function editor_trynamechange(object,newname_,fixed,objlistid,oldname_)
	local valid = true

	local newname = newname_ or "error"
	local oldname = oldname_ or "error"
	local checking = true

	if (newname:sub(1,1) == "$") then -- support for raw rename mod
		return old_editor_trynamechange(object,newname_,fixed,objlistid,oldname_)
	end

	newname = string.gsub(newname, "_", "UNDERDASH")
	newname = string.gsub(newname, "%W", "")
	newname = string.gsub(newname, "UNDERDASH", "_")

	while checking do
		checking = false

		for a,obj in pairs(editor_currobjlist) do
			if (obj.name == newname) then
				checking = true

				if (tonumber(string.sub(obj.name, -1)) ~= nil) then
					local num = tonumber(string.sub(obj.name, -1)) + 1

					newname = string.sub(newname, 1, string.len(newname)-1) .. tostring(num)
				else
					newname = newname .. "2"
				end
			end
		end
	end

	if (#newname == 0) or (newname == "level") or (newname == "text_crash") or (newname == "text_error") or (newname == "crash") or (newname == "error") or (newname == "text_never") or (newname == "never") or (newname == "text_") then
		valid = false
	end

	if (string.find(newname, "#") ~= nil) then
		valid = false
	end

	MF_alert("Trying to change name: " .. object .. ", " .. newname .. ", " .. tostring(valid))

	if valid then
		savechange(object,{newname},fixed)
		MF_updateobjlistname_hack(objlistid,newname)

		-- we're gonna change every layer
		local textlessName, metalevel = string.gsub(oldname, "text_", "")
		if string.sub(oldname, -5) == "text_" then
			metalevel = metalevel - 1
			textlessName = "text_"..textlessName
		end
		newname = string.gsub(newname, "text_", "", metalevel)
		
		for i,v in ipairs(editor_currobjlist) do
			--[[if (v.object == object) then -- idk what this does, I'm just gonna disable this
				v.name = newname
			end]]

			local nTextlessName, nMetalevel = string.gsub(v.name, "text_", "")
			if string.sub(v.name, -5) == "text_" then
				nMetalevel = nMetalevel - 1
				nTextlessName = "text_"..nTextlessName
			end

			if (nTextlessName == textlessName) then
				local tOldname = v.name
				v.name = string.rep("text_",nMetalevel) .. newname
				local vid = MF_create(v.object)
				savechange(v.object,{v.name},vid)
				MF_cleanremove(vid)

				MF_alert("Found " .. tOldname .. ", changing to " .. v.name)

				MF_updateobjlistname_byname(tOldname,v.name)
			end
		end
	end

	return valid
end

-- Fix issue with FEAR.
function getunitverbtargets(rule2)
	local group = {}
	local result = {}

	if (featureindex[rule2] ~= nil) then
		for i, v in ipairs(featureindex[rule2]) do
			local rule = v[1]
			local conds = v[2]

			local name = rule[1]

			local isnot = string.sub(rule[3], 1, 4)

			if (rule[2] == rule2) and (conds[1] ~= "never") and (findnoun(rule[1], nlist.brief) == false) and (isnot ~= "not ") and (not is_str_broad_noun(rule[1])) then
				if (group[name] == nil) then
					group[name] = {}
				end

				table.insert(group[name], { rule[3], conds })
			end
		end

		for name, v in pairs(group) do
			if (string.sub(name, 1, 4) ~= "not ") then
				if (name ~= "empty") then
					local fgroupmembers = unitlists[name] or {}
					local finalgroup = {}

					for a, b in ipairs(fgroupmembers) do
						local myverbs = {}

						for c, d in ipairs(v) do
							if testcond(d[2], b) then
								local unit = mmf.newObject(b)

								if (unit.flags[DEAD] == false) then
									table.insert(myverbs, d[1])
								end
							end
						end

						table.insert(finalgroup, { b, myverbs })
					end

					table.insert(result, { name, finalgroup })
				else
					local empties = findempty()
					local finalgroup = {}

					if (#empties > 0) then
						for a, b in ipairs(empties) do
							local x = math.floor(b % roomsizex)
							local y = math.floor(b / roomsizex)
							local myverbs = {}

							for c, d in ipairs(v) do
								if testcond(d[2], 2, x, y) then
									table.insert(myverbs, d[1])
								end
							end

							table.insert(finalgroup, { b, myverbs })
						end

						table.insert(result, { name, finalgroup })
					end
				end
			end
		end
	end

	return result
end

-- This fixes this really weird bug where the game tries to convert particles and text.
function doconvert(data,extrarule_)
	local style = data[2]
	local mats2 = data[3]
	
	local unitid = data[1]
	if unitid ~= 2 then
		local unit = mmf.newObject(unitid)
		if unit.strings[UNITNAME] == "" then
			return
		end
	end
	local unit = {}
	local x,y,dir,name,id,completed,float,ogname = 0,0,0,"",0,0,0,""
	local delthis = false
	local delthis_createall = false
	local delthis_createall_ = false
	
	if (unitid ~= 2) then
		unit = mmf.newObject(unitid)
		x,y,dir,name,id,completed,ogname = unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.strings[UNITNAME],unit.values[ID],unit.values[COMPLETED],unit.originalname
	end
	
	local cdata = {}
	cdata[1] = name
	
	if (style == "convert") then
		for a,mats2data in ipairs(mats2) do
			local mat2 = mats2data[1]
			local ingameid = mats2data[2]
			local baseingameid = mats2data[3]
			
			local unitname = ""
			
			if (mat2 == "revert") and (unitid ~= 2) and (ogname ~= nil) then
				local originalname = ogname
				
				if (string.len(originalname) > 0) then
					unitname = unitreference[originalname]
					mat2 = originalname
				else
					unitname = nil
				end
				
				if (source == "emptyconvert") then
					unitname = ""
					mat2 = "empty"
				end
				
				if (unitname == unit.className) then
					MF_alert("Trying to revert object to the same thing: " .. tostring(originalname))
					return
				end
			elseif (mat2 == "revert") and (unitid == 2) then
				MF_alert("Trying to revert empty")
				return
			end
			
			if (mat2 ~= "empty") and (mat2 ~= "error") and (mat2 ~= "revert") and (mat2 ~= "createall") then
				if (mats2data[1] ~= "revert") then
					unitname = unitreference[mat2]
				end
				
				if (mat2 == "level") then
					unitname = "level"
				end
				
				if (unitname == nil) then
					MF_alert("no className found for " .. mat2 .. "!")
					return
				end
				
				local newunitid = MF_emptycreate(unitname,x,y)
				local newunit = mmf.newObject(newunitid)
				
				newunit.values[ONLINE] = 1
				newunit.values[XPOS] = x
				newunit.values[YPOS] = y
				newunit.values[DIR] = dir
				newunit.values[POSITIONING] = 20
				
				newunit.values[VISUALLEVEL] = unit.values[VISUALLEVEL]
				newunit.values[VISUALSTYLE] = unit.values[VISUALSTYLE]
				newunit.values[COMPLETED] = completed
				
				newunit.strings[COLOUR] = unit.strings[COLOUR]
				newunit.strings[CLEARCOLOUR] = unit.strings[CLEARCOLOUR]
				
				if (unitname == "level") then
					newunit.values[COMPLETED] = math.max(completed, 1)
					newunit.flags[LEVEL_JUSTCONVERTED] = true
					
					if (string.len(unit.strings[LEVELFILE]) > 0) then
						newunit.values[COMPLETED] = math.max(completed, 2)
					end
					
					if (string.len(unit.strings[COLOUR]) == 0) or (string.len(unit.strings[CLEARCOLOUR]) == 0) then
						newunit.strings[COLOUR] = "1,2"
						newunit.strings[CLEARCOLOUR] = "1,3"
						MF_setcolour(newunitid,1,2)
					else
						local c = MF_parsestring(unit.strings[COLOUR])
						MF_setcolour(newunitid,c[1],c[2])
					end
					
					newunit.visible = true
				end
				
				newunit.values[ID] = ingameid
				
				newunit.strings[U_LEVELFILE] = unit.strings[U_LEVELFILE]
				newunit.strings[U_LEVELNAME] = unit.strings[U_LEVELNAME]
				newunit.flags[MAPLEVEL] = unit.flags[MAPLEVEL]
				
				newunit.values[EFFECT] = 1
				newunit.flags[9] = true
				newunit.flags[CONVERTED] = true
				
				cdata[2] = mat2
				
				addundo({"convert",cdata[1],cdata[2],ingameid,baseingameid,x,y,dir})
				addundo({"create",mat2,ingameid,baseingameid,"convert",x,y,dir})
				
				addunit(newunitid)
				addunitmap(newunitid,x,y,newunit.strings[UNITNAME])
				poscorrect(newunitid,generaldata2.values[ROOMROTATION],generaldata2.values[ZOOM],0)
				
				if (spritedata.values[VISION] == 0) or ((newunit.values[TILING] == 1) and (newunit.values[ZLAYER] <= 10) and (newunit.values[ZLAYER] >= 0)) then
					dynamic(newunitid)
				end
				
				newunit.new = false
				newunit.originalname = unit.originalname
				
				if is_parser(newunit) then
					updatecode = 1
				else
					local newname = newunit.strings[UNITNAME]
					local notnewname = "not " .. newunit.strings[UNITNAME]
					
					if (featureindex["word"] ~= nil) then
						for i,v in ipairs(featureindex["word"]) do
							local rule = v[1]
							local conds = v[2]
							
							if (rule[2] == "is") and (rule[3] == "word") then --TODO: check wordlikes
								if (rule[1] == newname) then
									updatecode = 1
									break
								elseif (unitid ~= 2) then
									if (rule[1] == unitname) then
										updatecode = 1
										break
									end
								end
								
								if (#conds > 0) then
									for a,b in ipairs(conds) do
										if (b[2] ~= nil) and (#b[2] > 0) then
											for c,d in ipairs(b[2]) do
												if (d == newname) or ((string.sub(d, 1, 4) == "not ") and (string.sub(d, 5) ~= newname)) then
													updatecode = 1
													break
												elseif (unitid ~= 2) then
													if (d == unitname) or ((string.sub(d, 1, 4) == "not ") and (string.sub(d, 5) ~= unitname)) then
														updatecode = 1
														break
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
				
				delthis = true
			elseif (mat2 == "error") then
				if (unitid ~= 2) then
					local unit = mmf.newObject(unitid)
					local x,y = unit.values[XPOS],unit.values[YPOS]
					local pmult,sound = checkeffecthistory("paradox")
					local c1,c2 = getcolour(unitid)
					MF_particles("unlock",x,y,20 * pmult,c1,c2,1,1)
					--paradox[id] = 1
				end
				
				delthis = true
			elseif (mat2 == "empty") then
				addundo({"convert",cdata[1],"empty",ingameid,baseingameid,x,y,dir})
				updateunitmap(unitid,x,y,x,y,unit.strings[UNITNAME])
				delthis = true
				
				local tileid = x + y * roomsizex
				if (emptydata[tileid] == nil) then
					emptydata[tileid] = {}
				end
				
				emptydata[tileid]["conv"] = true
			elseif (mat2 == "createall") then
				delthis_createall = createall_single(unitid)
				delthis = delthis_createall
				delthis_createall_ = true
			end
		end
		
		if delthis_createall_ and (delthis_createall == false) and delthis then
			delthis = false
		end
		
		if delthis and (unit.flags[DEAD] == false) then
			addundo({"remove",unit.strings[UNITNAME],unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID],unit.values[ID],unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.values[VISUALLEVEL],unit.values[COMPLETED],unit.values[VISUALSTYLE],unit.flags[MAPLEVEL],unit.strings[COLOUR],unit.strings[CLEARCOLOUR],unit.followed,unit.back_init,unit.originalname,unit.strings[UNITSIGNTEXT],unit.holder})
			
			if is_parser(unit) then
				updatecode = 1
			end
			
			delunit(unitid)
			dynamic(unitid)
			MF_specialremove(unitid,2)
		end
	elseif (style == "emptyconvert") then
		for a,mats2data in ipairs(mats2) do
			local mat2 = mats2data[1]
			local i = mats2data[2]
			local j = mats2data[3]
			
			if (mat2 ~= "createall") and (mat2 ~= "error") then
				local unitname = unitreference[mat2]
				local newunitid = MF_emptycreate(unitname,i,j)
				local newunit = mmf.newObject(newunitid)
				
				cdata[1] = "empty"
				
				local id = newid()
				local dir = emptydir(i,j)
				
				if (dir == 4) then
					dir = fixedrandom(0,3)
				end
				
				newunit.values[ONLINE] = 1
				newunit.values[XPOS] = i
				newunit.values[YPOS] = j
				newunit.values[DIR] = dir
				newunit.values[ID] = id
				newunit.values[EFFECT] = 1
				newunit.flags[9] = true
				newunit.flags[CONVERTED] = true
				
				cdata[2] = mat2
				addundo({"convert",cdata[1],cdata[2],id,id,i,j,dir})
				addundo({"create",mat2,id,-1,"emptyconvert",i,j,dir})
				
				addunit(newunitid)
				addunitmap(newunitid,i,j,newunit.strings[UNITNAME])
				dynamic(newunitid)
				
				newunit.originalname = "empty"
				
				local tileid = i + j * roomsizex
				if (emptydata[tileid] == nil) then
					emptydata[tileid] = {}
				end
				
				emptydata[tileid]["conv"] = true
				
				if is_parser(newunit) then
					updatecode = 1
				else
					if (featureindex["word"] ~= nil) then
						for i,v in ipairs(featureindex["word"]) do
							local rule = v[1]
							if (rule[1] == newunit.strings[UNITNAME]) then
								updatecode = 1
							elseif (unitid ~= 2) then
								if (rule[1] == unit.strings[UNITNAME]) then
									updatecode = 1
								end
							end
						end
					end
				end
			elseif (mat2 == "createall") then
				createall_single(2,nil,i,j)
			end
		end
	end
end


--[[ Gets the meta level of a string
(times "text_" appears, minus 1, minus 1 again if the string ends with "text_")
Examples:
"baba" = -1
"text_baba" = 0
"text_text_baba" = 1
"text_text_" = 0
"text_text_text_" = 1
]]
function getmetalevel(str)
	local metalevel = -1
	while is_str_special_prefixed(str) do
		for _,v in ipairs(special_prefixes) do
			if string.sub(str, 1, string.len(v)) == v then
				metalevel = metalevel + 1
				str = string.sub(str, string.len(v) + 1)
			end
		end
	end
	if str == "" then
		metalevel = metalevel - 1
	end
	return metalevel
end

-- Fix issue with TEXT MAKE TEXT
function getunitswithverb(rule2, ignorethese_, checkedconds)
	local group = {}
	local result = {}
	local ignorethese = ignorethese_ or {}

	if (featureindex[rule2] ~= nil) then
		for i, v in ipairs(featureindex[rule2]) do
			local rule = v[1]
			local conds = v[2]

			local name = rule[1]

			if (rule[2] == rule2) and (conds[1] ~= "never") and (findnoun(rule[1], nlist.brief) == false) and (string.sub(rule[3], 1, 4) ~= "not ") then
				if (group[name] == nil) then
					group[name] = {}
				end

				table.insert(group[name], { rule[3], conds })
			end
		end

		for i, v in pairs(group) do
			if (string.sub(i, 1, 4) ~= "not ") and (not is_str_broad_noun(i)) and string.sub(i, 1, 4) ~= "meta" then -- changed line
				if (i ~= "empty") then
					local name = i
					local fgroupmembers = unitlists[name]

					if (fgroupmembers ~= nil) and (#fgroupmembers > 0) then
						for c, d in ipairs(v) do
							table.insert(result, { d[1], {}, name })
							local thisthisresult = result[#result][2]

							for a, b in ipairs(fgroupmembers) do
								if testcond(d[2], b, nil, nil, nil, nil, checkedconds) then
									local unit = mmf.newObject(b)

									if (unit.flags[DEAD] == false) then
										local valid = true
										for e, f in ipairs(ignorethese) do
											if (f == b) then
												valid = false
												break
											end
										end

										if valid then
											table.insert(result[#result][2], unit)
										end
									end
								end
							end
						end
					end
				else
					local name = i
					local empties = findempty()

					if (#empties > 0) then
						for c, d in ipairs(v) do
							table.insert(result, { d[1], {}, name })

							for e, f in ipairs(empties) do
								local x = math.floor(f % roomsizex)
								local y = math.floor(f / roomsizex)

								if testcond(d[2], 2, x, y, nil, nil, checkedconds) then
									local valid = true
									for g, h in ipairs(ignorethese) do
										if (f == h) then
											valid = false
											break
										end
									end

									if valid then
										table.insert(result[#result][2], f)
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return result
end

function getunitswitheffect(rule3,nolevels_,ignorethese_,checkedconds,ignorebroken_)
	local group = {}
	local result = {}
	local ignorethese = ignorethese_ or {}
	local ignorebroken = ignorebroken_ or false
	
	local nolevels = nolevels_ or false
	
	if (featureindex[rule3] ~= nil) then
		for i,v in ipairs(featureindex[rule3]) do
			local rule = v[1]
			local conds = v[2]
			
			if (rule[2] == "is") and (conds[1] ~= "never") and (findnoun(rule[1],nlist.brief) == false) then
				table.insert(group, {rule[1], conds})
			end
		end
		
		for i,v in ipairs(group) do
			if (v[1] ~= "empty") then
				local name = v[1]
				local fgroupmembers = unitlists[name]
				
				local valid = true
				
				if (name == "level") and nolevels then
					valid = false
				end
				
				if (fgroupmembers ~= nil) and valid then
					for a,b in ipairs(fgroupmembers) do
						if testcond(v[2],b,nil,nil,nil,nil,checkedconds,ignorebroken) then
							local unit = mmf.newObject(b)
							
							if (unit.flags[DEAD] == false) then
								valid = true
								
								for c,d in ipairs(ignorethese) do
									if (d == b) then
										valid = false
										break
									end
								end
								
								if valid then
									table.insert(result, unit)
								end
							end
						end
					end
				end
			else
				--table.insert(result, {2, v[2]})
			end
		end
	end
	
	return result
end

special_prefixes = {}
for _, v in ipairs(broad_nouns) do
	table.insert(special_prefixes, v .. "_")
	if v ~= "text" then
		for _, thing in ipairs({"full", "short", "objects"}) do
			table.insert(nlist[thing], v)
		end
	end
end

function is_str_broad_noun(str)
	for _, v in ipairs(broad_nouns) do
		if str == v then
			return true
		end
	end
	return false
end

function is_str_notted_broad_noun(str)
	for _, v in ipairs(broad_nouns) do
		if str == "not " .. v then
			return true
		end
	end
	return false
end

function get_broaded_str(str)
	for _,v in ipairs(broad_nouns) do
		if string.sub(str, 1, string.len(v) + 1) == v .. "_" then
			return v
		end
	end
	return str
end

function is_str_special_prefix(str)
	for _, v in ipairs(special_prefixes) do
		if str == v then
			return true
		end
	end
	return false
end

function is_str_special_prefixed(str)
	for _, v in ipairs(special_prefixes) do
		if string.sub(str, 1, string.len(v)) == v then
			return true
		end
	end
	return false
end

function get_pref(str)
	for _, v in ipairs(special_prefixes) do
		if string.sub(str, 1, string.len(v)) == v then
			return v
		end
	end
	return ""
end

function get_ref(str)
	for _, v in ipairs(special_prefixes) do
		if string.sub(str, 1, string.len(v)) == v then
			return string.sub(str, string.len(v) + 1)
		end
	end
	return str
end

function edit_str_meta_layer(str, layer)
	local metalevel = getmetalevel(str)
	local diff = metalevel - layer
	if diff > 0 then
		for i = 1, diff do
			str = get_ref(str)
		end
	elseif diff < 0 then
		local top_pref = get_pref(str)
		if top_pref == "" then top_pref = "text_" end
		str = string.rep(top_pref, -diff) .. str
	end
	return str
end

function equals_or_included(a,b)
	if a == b then return true end
	if ("meta"..getmetalevel(a) == b) then return true end
	if get_pref(a) == b .. "_" then return true end
	return false
end

function can_refer(noun,target)
	local isnot = false
	if string.sub(noun,1,4) == "not " then
		noun = string.sub(noun,5)
		isnot = true
	end
	if isnot then
		if (string.sub(noun,1,4) == "meta") then 
			if (string.sub(noun,5) ~= tostring(getmetalevel(target))) and (metatext_includenoun or is_str_special_prefixed(target)) then return true end
		elseif (noun == "all") then
			if is_str_special_prefixed(target) or target == "empty" then return true end
		elseif (get_pref(noun) == get_pref(target)) and (target ~= noun) and (is_str_special_prefixed(noun) or (findnoun(target) == false)) then return true end
	else
        if equals_or_included(target, noun) then return true end
		if (noun == "all") and (findnoun(target) == false) then return true end
    end

	return false

end

function diff_or_excluded(a,b)
	if a ~= b then
		if string.sub(b, 1, 4) == "meta" then
            if ("meta" .. tostring(getmetalevel(a)) ~= b) and (metatext_includenoun or getmetalevel(a) >= 0) then
                return true
            end
        else
            if get_pref(a) == get_pref(b) then return true end
        end
	end
	return false
end

function is_string_metax(str, include_n1)
	if string.sub(str,1,4) ~= "meta" then return false end
	local metalevel = tonumber(string.sub(str,5))
	if metalevel == nil then return false end
	if metalevel < -1 then return false end
	--check if metalevel is integer
	--if metalevel ~= math.floor(metalevel) then return false end
	if (not include_n1) or (include_n1 == nil) then
		if metalevel == -1 then return false end
	end
	return true
end

function get_text_type(name)
    if is_str_special_prefixed(name) and not is_str_special_prefix(name) then return 0 end
    local aname = "text_"..name
    if objectpalette[aname] ~= nil then
        local altname = objectpalette[aname]
		local result = getactualdata_objlist(altname, "type")
        return result
    end
    local result = editor_objlist[aname]
    if result ~= nil then return result.type end
    return -2
end

function is_parser(unit)
	if (unit == nil) then return false end
	return is_str_special_prefixed(unit.strings[UNITNAME])
end