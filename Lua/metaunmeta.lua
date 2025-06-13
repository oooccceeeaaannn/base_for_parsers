-- This is adds the meta and unmeta properties, as well as the meta# nouns.

-- Adds object to editor.
table.insert(editor_objlist_order,"text_meta")
table.insert(editor_objlist_order,"text_unmeta")
table.insert(editor_objlist_order,"text_meta-1")
table.insert(editor_objlist_order,"text_meta0")
table.insert(editor_objlist_order,"text_meta1")
table.insert(editor_objlist_order,"text_meta2")
table.insert(editor_objlist_order,"text_meta3")
editor_objlist["text_meta"] = {
  name = "text_meta",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_quality","text_special"},
  tiling = -1,
  type = 2,
  layer = 20,
  colour = {4, 0},
  colour_active = {4, 1},
}
editor_objlist["text_unmeta"] = {
  name = "text_unmeta",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_quality","text_special"},
  tiling = -1,
  type = 2,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
editor_objlist["text_meta-1"] = {
  name = "text_meta-1",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {4, 1},
  colour_active = {4, 2},
}
editor_objlist["text_meta0"] = {
  name = "text_meta0",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
editor_objlist["text_meta1"] = {
  name = "text_meta1",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
editor_objlist["text_meta2"] = {
  name = "text_meta2",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
editor_objlist["text_meta3"] = {
  name = "text_meta3",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
formatobjlist()

function is_str_metalike_prop(str)
    if metalikes_to_parsers[str] ~= nil then
		return true
	end
	if unmetalikes_to_parsers[str] ~= nil then
		return true
	end
    return (str == "unmexa")
end

function is_str_writelike_verb(str)
    for writelike, noun in pairs(writelikes_to_parsers) do
		if str == writelike then
			return true
		end
	end
    return false
end

-- Implementation.
function conversion(dolevels_)
	local alreadydone = {}
	local dolevels = dolevels_ or false
	
	for i,v in pairs(features) do
		local words = v[1]
		
		local operator = words[2]

		if (operator == "is") or is_str_writelike_verb(operator) or (operator == "become") then
			local output = {}
			local name = words[1]
			local thing = words[3]

			if (not dolevels) and (operator == "is" or operator == "become") and not is_str_special_prefix(name .. "_") and (string.sub(name,1,4)) ~= "meta" and ((thing ~= "not " .. name) and (thing ~= "all") and (not is_str_broad_noun(thing)) and (thing ~= "revert") and not is_str_metalike_prop(thing)) and unitreference[thing] == nil and (is_str_special_prefixed(thing)) and ((unitlists[name] ~= nil and #unitlists[name] > 0) or name == "empty" or name == "level") then
				tryautogenerate(thing)
			elseif (not dolevels) and (is_str_writelike_verb(operator)) and not is_str_special_prefix(name .. "_") and (string.sub(name,1,4)) ~= "meta" and (thing ~= "not " .. name) and unitreference[writelikes_to_parsers[operator] .. "_" .. thing] == nil and ((unitlists[name] ~= nil and #unitlists[name] > 0) or name == "empty" or name == "level") then
				tryautogenerate(writelikes_to_parsers[operator] .. "_" .. thing)
			end

			if (not is_str_broad_noun(name)) --@Merge: omg beeeeg if block
			  and (string.sub(name,1,4) ~= "meta")
			  and ((getmat(thing) ~= nil)
			  	or (thing == "not " .. name)
				or (thing == "all")
				or (unitreference[thing] ~= nil)
				or (is_str_broad_noun(thing))
				or (thing == "revert")
				or (is_str_metalike_prop(thing))
				or ((string.sub(thing,1,4) == "meta") and (unitreference["text_" .. thing] ~= nil))
				or (is_str_writelike_verb(operator)) and (getmat_text(writelikes_to_parsers[operator] .. "_" .. name) or getmat_text(name))) then
				
				if (featureindex[name] ~= nil) and (alreadydone[name] == nil) then
					alreadydone[name] = 1

					for a,b in ipairs(featureindex[name]) do
						local rule = b[1]
						local conds = b[2]
						local target,verb,object = rule[1],rule[2],rule[3]

						if (verb == "is") or (verb == "become") then
							if (target == name) and (object ~= "word") and ((object ~= name) or (verb == "become")) then
								if not is_str_broad_noun(object) and (object ~= "revert") and (object ~= "createall") and (not is_str_metalike_prop(object)) and (string.sub(object,1,4) ~= "meta") then
									if (object == "not " .. name) then
										table.insert(output, {"error", conds, "is"})

									elseif is_str_special_prefixed(object) then
										table.insert(output, {object, conds, "is"})
									else
										for d,mat in pairs(objectlist) do
											if (string.sub(d, 1, 5) ~= "group") and ((d == object)) then
												table.insert(output, {object, conds, "is"})
											end
										end
									end
								elseif (name ~= object) or (verb == "become") then
									if (object ~= "revert") and (not is_str_metalike_prop(object)) then --Note: I don't actually think meta/unmeta needs to be placed at the front.
										table.insert(output, {object, conds, "is"})
									else
										table.insert(output, 1, {object, conds, "is"})
									end
								end
							end
						elseif is_str_writelike_verb(verb) then
							if (string.sub(object, 1, 4) ~= "not ") and (target == name) then
								table.insert(output, {object, conds, verb})
							end
						end
					end
				end
				
				if (#output > 0) then
					local conversions = {}
					
					for k,v3 in pairs(output) do
						local object = v3[1]
						local conds = v3[2]
						local op = v3[3]

						if (op == "is") then
							local metaparser = metalikes_to_parsers[object]
							local unmetaparser = unmetalikes_to_parsers[object]
							if (findnoun(object,nlist.brief) == false) and (object ~= "word") and not is_str_broad_noun(object) and (not is_str_metalike_prop(object)) then
								table.insert(conversions, v3)
							elseif (object == "all") then
								--[[
								addaction(0,{"createall",{name,conds},dolevels})
								createall({name,conds})
								]]--
								table.insert(conversions, {"createall",conds})
							elseif metaparser ~= nil then
								local pref = metaparser .. "_"
								local valid = true -- don't attempt conversion if the object does not exist
								if unitreference[pref .. name] == nil and ((unitreference[name] ~= nil and unitlists[name] ~= nil and #unitlists[name] > 0) or name == "empty" or name == "level") then
									valid = tryautogenerate(pref .. name,name)
								end
								if valid then
									table.insert(conversions, {pref .. name,conds})
								end
							elseif (unmetaparser ~= nil) and get_broaded_str(name) == unmetaparser then
								local unmetad = get_ref(name)
								local valid = (getmat(unmetad) ~= nil or unitreference[unmetad] ~= nil) and not is_str_broad_noun(unmetad) and (unmetad ~= "all") -- don't attempt conversion if the object does not exist
								if unitreference[unmetad] == nil and unitreference[name] ~= nil and unitlists[name] ~= nil and #unitlists[name] > 0 and is_str_special_prefixed(unmetad) then
									valid = tryautogenerate(unmetad)
								end
								if valid then
									table.insert(conversions, {unmetad,conds})
								end
							elseif (object == "unmexa") and is_str_special_prefixed(name) then
								local unmetad = get_ref(name)
								local valid = (getmat(unmetad) ~= nil or unitreference[unmetad] ~= nil) and not is_str_broad_noun(unmetad) and (unmetad ~= "all") -- don't attempt conversion if the object does not exist
								if unitreference[unmetad] == nil and unitreference[name] ~= nil and unitlists[name] ~= nil and #unitlists[name] > 0 and is_str_special_prefixed(unmetad) then
									valid = tryautogenerate(unmetad)
								end
								if valid then
									table.insert(conversions, {unmetad,conds})
								end
							elseif (string.sub(object,1,4) == "meta") then
								local level = string.sub(object,5)
								if tonumber(level) ~= nil and tonumber(level) >= -1 then
									local newname = edit_str_meta_layer(name, level)
									local valid = true -- don't attempt conversion the if object does not exist
									if tonumber(level) >= 0 and unitreference[newname] == nil and ((unitreference[name] ~= nil and unitlists[name] ~= nil and #unitlists[name] > 0) or name == "empty" or name == "level") then
										if is_str_special_prefixed(newname) then
											valid = tryautogenerate(newname)
										else
											valid = false
										end
									end
									if valid then
										table.insert(conversions, {newname,conds})
									end
								end
							elseif is_str_broad_noun(object) then
								local valid = true -- don't attempt conversion if the object does not exist
								local created = object .. "_" .. name
								if unitreference[created] == nil and ((unitreference[name] ~= nil and unitlists[name] ~= nil and #unitlists[name] > 0) or name == "empty" or name == "level") then
									valid = tryautogenerate(created)
								end
								if valid then
									table.insert(conversions, {created,conds})
								end
							end
						elseif is_str_writelike_verb(op) then
							table.insert(conversions, v3)
						end
					end
					
					if (#conversions > 0) then
						convert(name,conversions,dolevels)
					end
				end
			end
		end
	end
end

function convert(stuff,mats,dolevels_)
	local layer = map[0]
	local delthese = {}
	local mat1 = stuff
	local dolevels = dolevels_ or false
	local donewid = false
	
	if (dolevels == false) then
		if (mat1 ~= "empty") then
			local targets = {}
			
			if (unitlists[mat1] ~= nil) then
				targets = unitlists[mat1]
			end
			
			if (editor2.values[CURSORSEXIST] == 1) then
				if (featureindex[mat1] ~= nil) then
					for i,v in ipairs(featureindex[mat1]) do
						local rule = v[1]
						
						if (rule[2] == "is") and (rule[3] == "select") then
							editor.values[NAMEFLAG] = 0
							break
						end
					end
				end
			end
			
			if (#targets > 0) then
				for i,mat in pairs(mats) do
					if (mat[1] == "createall") then
						donewid = true
						break
					end
				end
				
				for i,unitid in pairs(targets) do
					local unit = mmf.newObject(unitid)
					local x,y,dir,id = unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID]
					local name = getname(unit)
					
					local reverting = false
					local mats2 = {}

					if (unit.flags[CONVERTED] == false) then
						for a,matdata in pairs(mats) do
							local mat2 = matdata[1]
							local conds = matdata[2]
							local op = matdata[3]
							
							if is_str_writelike_verb(op) then
								mat2 = writelikes_to_parsers[op] .. "_" .. matdata[1]
							end
							
							if (reverting == false) then
								local objectfound = false
								
								if (unitreference[mat2] ~= nil) and (mat2 ~= "level") then
									local object = unitreference[mat2]
									
									if (tileslist[object]["name"] == mat2) and ((changes[object] == nil) or (changes[object]["name"] == nil)) then
										objectfound = true
									elseif (changes[object] ~= nil) then
										if (changes[object]["name"] ~= nil) and (changes[object]["name"] == mat2) then
											objectfound = true
										end
									end
								else
									objectfound = true
								end
								
								if testcond(conds,unit.fixed) and objectfound then
									local ingameid = 0
									if (a == 1) and (donewid == false) then
										ingameid = id
									elseif (a > 1) or donewid then
										ingameid = newid()
									end
									
									if (mat2 == "revert") then
										if (unit.strings[UNITNAME] ~= unit.originalname) then
											reverting = true
										end
									end
									
									if (mat2 ~= "revert") or ((mat2 == "revert") and reverting) then
										table.insert(mats2, {mat2,ingameid,id})
										unit.flags[CONVERTED] = true
									end
								end
							else
								break
							end
						end
					end
					
					if (#mats2 > 0) then
						addaction(unit.fixed,{"convert",mats2})
					end
				end
			end
		elseif (mat1 == "empty") then
			local convunitmap = {}
			
			for a,unit in pairs(units) do
				local tileid = unit.values[XPOS] + unit.values[YPOS] * roomsizex
				convunitmap[tileid] = 1
			end
			
			for i=0,roomsizex-1 do
				for j=0,roomsizey-1 do
					local empty = true
					local mats2 = {}
					
					local tileid = i + j * roomsizex
					if (convunitmap[tileid] ~= nil) then
						empty = false
					end
					
					if (emptydata[tileid] ~= nil) then
						if (emptydata[tileid]["conv"] ~= nil) and emptydata[tileid]["conv"] then
							empty = false
						end
					end
					
					if (layer:get_x(i,j) ~= 255) then
						empty = false
					end
					
					if empty then
						for a,matdata in pairs(mats) do
							local mat2 = matdata[1]
							local conds = matdata[2]
							local op = matdata[3]
							
							if is_str_writelike_verb(op) then
								mat2 = writelikes_to_parsers[op] .. "_" .. matdata[1]
							end
							
							local objectfound = false
							
							if (unitreference[mat2] ~= nil) and (mat2 ~= "level") then
								local object = unitreference[mat2]
								
								if (tileslist[object]["name"] == mat2) and ((changes[object] == nil) or (changes[object]["name"] == nil)) then
									objectfound = true
								elseif (changes[object] ~= nil) then
									if (changes[object]["name"] ~= nil) and (changes[object]["name"] == mat2) then
										objectfound = true
									end
								end
							elseif (mat2 ~= "revert") then
								objectfound = true
							end

							if (mat2 ~= "empty") and objectfound then
								if testcond(conds,2,i,j) then
									table.insert(mats2, {mat2,i,j})
								end
							end
						end
					end
					
					if (#mats2 > 0) then
						addaction(2,{"emptyconvert",mats2})
					end
				end
			end
		end
	end
	
	if (mat1 == "level") and dolevels then
		for i,v in ipairs(mats) do
			table.insert(levelconversions, v)
		end
	end
end

function convert(stuff,mats,dolevels_)
	local layer = map[0]
	local delthese = {}
	local mat1 = stuff
	local dolevels = dolevels_ or false
	local donewid = false
	
	if (dolevels == false) then
		if (mat1 ~= "empty") then
			local targets = {}
			
			if (unitlists[mat1] ~= nil) then
				targets = unitlists[mat1]
			end
			
			if (editor2.values[CURSORSEXIST] == 1) then
				if (featureindex[mat1] ~= nil) then
					for i,v in ipairs(featureindex[mat1]) do
						local rule = v[1]
						
						if (rule[2] == "is") and (rule[3] == "select") then
							editor.values[NAMEFLAG] = 0
							break
						end
					end
				end
			end
			
			if (#targets > 0) then
				for i,mat in pairs(mats) do
					if (mat[1] == "createall") then
						donewid = true
						break
					end
				end
				
				for i,unitid in pairs(targets) do
					local unit = mmf.newObject(unitid)
					local x,y,dir,id = unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID]
					local name = getname(unit)
					
					local reverting = false
					local mats2 = {}

					if (unit.flags[CONVERTED] == false) then
						for a,matdata in pairs(mats) do
							local mat2 = matdata[1]
							local conds = matdata[2]
							local op = matdata[3]
							
							if is_str_writelike_verb(op) then
								mat2 = writelikes_to_parsers[op] .. "_" .. matdata[1]
							end
							
							if (reverting == false) then
								local objectfound = false
								
								if (unitreference[mat2] ~= nil) and (mat2 ~= "level") then
									local object = unitreference[mat2]
									
									if (tileslist[object]["name"] == mat2) and ((changes[object] == nil) or (changes[object]["name"] == nil)) then
										objectfound = true
									elseif (changes[object] ~= nil) then
										if (changes[object]["name"] ~= nil) and (changes[object]["name"] == mat2) then
											objectfound = true
										end
									end
								else
									objectfound = true
								end
								
								if testcond(conds,unit.fixed) and objectfound then
									local ingameid = 0
									if (a == 1) and (donewid == false) then
										ingameid = id
									elseif (a > 1) or donewid then
										ingameid = newid()
									end
									
									if (mat2 == "revert") then
										if (unit.strings[UNITNAME] ~= unit.originalname) then
											reverting = true
										end
									end
									
									if (mat2 ~= "revert") or ((mat2 == "revert") and reverting) then
										table.insert(mats2, {mat2,ingameid,id})
										unit.flags[CONVERTED] = true
									end
								end
							else
								break
							end
						end
					end
					
					if (#mats2 > 0) then
						addaction(unit.fixed,{"convert",mats2})
					end
				end
			end
		elseif (mat1 == "empty") then
			local convunitmap = {}
			
			for a,unit in pairs(units) do
				local tileid = unit.values[XPOS] + unit.values[YPOS] * roomsizex
				convunitmap[tileid] = 1
			end
			
			for i=0,roomsizex-1 do
				for j=0,roomsizey-1 do
					local empty = true
					local mats2 = {}
					
					local tileid = i + j * roomsizex
					if (convunitmap[tileid] ~= nil) then
						empty = false
					end
					
					if (emptydata[tileid] ~= nil) then
						if (emptydata[tileid]["conv"] ~= nil) and emptydata[tileid]["conv"] then
							empty = false
						end
					end
					
					if (layer:get_x(i,j) ~= 255) then
						empty = false
					end
					
					if empty then
						for a,matdata in pairs(mats) do
							local mat2 = matdata[1]
							local conds = matdata[2]
							local op = matdata[3]
							
							if is_str_writelike_verb(op) then
								mat2 = writelikes_to_parsers[op] .. "_" .. matdata[1]
							end
							
							local objectfound = false
							
							if (unitreference[mat2] ~= nil) and (mat2 ~= "level") then
								local object = unitreference[mat2]
								
								if (tileslist[object]["name"] == mat2) and ((changes[object] == nil) or (changes[object]["name"] == nil)) then
									objectfound = true
								elseif (changes[object] ~= nil) then
									if (changes[object]["name"] ~= nil) and (changes[object]["name"] == mat2) then
										objectfound = true
									end
								end
							elseif (mat2 ~= "revert") then
								objectfound = true
							end

							if (mat2 ~= "empty") and objectfound then
								if testcond(conds,2,i,j) then
									table.insert(mats2, {mat2,i,j})
								end
							end
						end
					end
					
					if (#mats2 > 0) then
						addaction(2,{"emptyconvert",mats2})
					end
				end
			end
		end
	end
	
	if (mat1 == "level") and dolevels then
		for i,v in ipairs(mats) do
			table.insert(levelconversions, v)
		end
	end
end

function dolevelconversions()
	if (#features > 0) and (generaldata.values[WINTIMER] == 0) and (destroylevel_check == false) then
		local mats = levelconversions
		local mat1 = "level"
		local levelmats = {}
		
		local revert = false
		
		for i,matdata in pairs(mats) do
			local conds = matdata[2]
			local mat2 = matdata[1]
			local op = matdata[3]
			
							if is_str_writelike_verb(op) then
								mat2 = writelikes_to_parsers[op] .. "_" .. matdata[1]
							end
			
			local objectfound = false
			
			if (unitreference[mat2] ~= nil) then
				local object = unitreference[mat2]
				
				if (tileslist[object]["name"] == mat2) and ((changes[object] == nil) or (changes[object]["name"] == nil)) then
					objectfound = true
				elseif (changes[object] ~= nil) then
					if (changes[object]["name"] ~= nil) and (changes[object]["name"] == mat2) then
						objectfound = true
					end
				end
			elseif (mat2 == "error") and testcond(conds,1) then
				destroylevel()
			elseif (mat2 == "revert") then
				objectfound = true
			end
			
			if testcond(conds,1) and objectfound then
				if (mat2 ~= "revert") then
					table.insert(levelmats, mat2)
					MF_alert("Converting level into " .. mat2)
				else
					revert = true
					levelmats = {"revert"}
					break
				end
			end
		end
		
		if (#levelmats > 0) and (#levelmats < 50) then
			if (editor.values[INEDITOR] == 0) then
				if (revert == false) then
					level_to_convert = {generaldata.strings[CURRLEVEL], levelmats}
					
					local savestring = ""
					for a,b in pairs(levelmats) do
						savestring = savestring .. b .. ","
					end
					
					local upperlevel = leveltree[#leveltree - 1] or generaldata.strings[CURRLEVEL]
					local convertdata = MF_read("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert","converts")
					local levelconverts = tonumber(convertdata) or 0
					local idtostore = levelconverts
					
					if (levelconverts == 0) then
						local totalconverts = tonumber(MF_read("save",generaldata.strings[WORLD] .. "_converts","total")) or 0
						MF_store("save",generaldata.strings[WORLD] .. "_converts",tostring(totalconverts),generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert")
						totalconverts = totalconverts + 1
						MF_store("save",generaldata.strings[WORLD] .. "_converts","total",tostring(totalconverts))
					end
					
					if (levelconverts > 0) then
						for a=1,levelconverts do
							local result = string.find("___" .. MF_read("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert",tostring(a-1)), "___" .. generaldata.strings[CURRLEVEL])
							
							if (result ~= nil) then
								idtostore = a - 1
							end
						end
					end
					
					MF_store("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert",tostring(idtostore),generaldata.strings[CURRLEVEL] .. "," .. savestring)
					
					if (idtostore == levelconverts) then
						levelconverts = levelconverts + 1
						
						MF_store("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert","converts",tostring(levelconverts))
					end
				else
					level_to_convert = {generaldata.strings[CURRLEVEL], levelmats}
					
					local upperlevel = leveltree[#leveltree - 1] or generaldata.strings[CURRLEVEL]
					local convertdata = MF_read("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert","converts")
					local levelconverts = tonumber(convertdata) or 0
					
					local found = -1
					
					if (levelconverts > 0) then
						for a=1,levelconverts do
							local result = string.find("___" .. MF_read("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert",tostring(a-1)), "___" .. generaldata.strings[CURRLEVEL])
							
							if (result ~= nil) then
								found = a
							end
							
							if (found > 0) and (a > found) then
								local newa = a - 1
								local datatostore = MF_read("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert",tostring(a-1))
								MF_store("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert",tostring(newa-1),datatostore)
							end
						end
					end
					
					if (found > 0) then
						levelconverts = levelconverts - 1
						
						if (levelconverts > 0) then
							MF_store("save",generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert","converts",tostring(levelconverts))
						else
							MF_deletesave_group(generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert","converts")
							
							local totalconverts = tonumber(MF_read("save",generaldata.strings[WORLD] .. "_converts","total"))
							local found2 = -1
							
							if (totalconverts ~= nil) then
								for a=1,totalconverts do
									local result = string.find("___" .. MF_read("save",generaldata.strings[WORLD] .. "_converts",tostring(a-1)), "___" .. generaldata.strings[WORLD] .. "_" .. upperlevel .. "_convert")
							
									if (result ~= nil) then
										found2 = a
									end
									
									if (found2 > 0) and (a > found2) then
										local newa = a - 1
										local datatostore = MF_read("save",generaldata.strings[WORLD] .. "_converts",tostring(a-1))
										MF_store("save",generaldata.strings[WORLD] .. "_converts",tostring(newa-1),datatostore)
									end
								end
							end
							
							if (found2 > 0) then
								totalconverts = totalconverts - 1
								
								if (totalconverts > 0) then
									MF_store("save",generaldata.strings[WORLD] .. "_converts","total",tostring(totalconverts))
								else
									MF_deletesave_group(generaldata.strings[WORLD] .. "_converts")
								end
							end
						end
					end
				end
				
				uplevel()
			else
				level_to_convert = {}
			end
			
			MF_levelconversion()
		elseif (#levelmats >= 50) then
			HACK_INFINITY = 200
			destroylevel("toocomplex")
		end
		
		levelconversions = {}
	end
end