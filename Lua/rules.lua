


-- Makes this just use the addoption function, so TEXT IS PUSH works.
function addbaserule(rule1,rule2,rule3,conds_)
	local conds = conds_ or {}
	local rule = {rule1,rule2,rule3}

	addoption(rule,conds,{},false,nil,{"base"})
end


-- All: Enables TEXT IS WORD functionality if enabled.
function code(alreadyrun_)
	curr_parser = "none"
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false

	if (updatecode == 1) then
		HACK_INFINITY = HACK_INFINITY + 1
		--MF_alert("code being updated!")

		if generaldata.flags[LOGGING] then
			logrulelist.new = {}
		end

		MF_removeblockeffect(0)
		wordrelatedunits = {}

		do_mod_hook("rule_update",{alreadyrun})

		if (HACK_INFINITY < 200) then
			if metatext_textisword then
				addbaserule("text","is","word")
			end
			local checkthese = {}
			local wordidentifier = ""
			wordunits,wordidentifier,wordrelatedunits = findwordunits()

			if (#wordunits > 0) then
				for i,v in ipairs(wordunits) do
					if testcond(v[2],v[1]) then
						local unit = mmf.newObject(v[1])
						table.insert(checkthese, v[1])
					end
				end
			end

			features = {}
			featureindex = {}
			condfeatureindex = {}
			visualfeatures = {}
			notfeatures = {}
			groupfeatures = {}
			local firstwords = {}
			local alreadyused = {}

			do_mod_hook("rule_baserules") 

			for i,v in ipairs(baserulelist) do
				addbaserule(v[1],v[2],v[3],v[4])
			end
			if metatext_textisword then
				addbaserule("text","is","word")
			end

			formlettermap()

			if (#codeunits > 0) then
				for i,v in ipairs(codeunits) do
					if metatext_textisword then
						setcolour(v)
					else
						table.insert(checkthese, v)
					end
				end
			end

			if (#checkthese > 0) or (#letterunits > 0) or (#parserunits > 0) then
				for iid,unitid in ipairs(checkthese) do
					local unit = mmf.newObject(unitid)
					local x,y = unit.values[XPOS],unit.values[YPOS]
					local ox,oy,nox,noy = 0,0
					local tileid = x + y * roomsizex

					setcolour(unit.fixed)

					if (alreadyused[tileid] == nil) and (unit.values[TYPE] ~= 5) and (unit.flags[DEAD] == false) then
						for i=1,2 do
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1]
							noy = ndrs[2]

							--MF_alert("Doing firstwords check for " .. unit.strings[UNITNAME] .. ", dir " .. tostring(i))

							local hm = codecheck(unitid,ox,oy,i)
							local hm2 = codecheck(unitid,nox,noy,i,false,true) -- count letters

							if (#hm == 0) and (#hm2 > 0) then
								--MF_alert("Added " .. unit.strings[UNITNAME] .. " to firstwords, dir " .. tostring(i))

								table.insert(firstwords, {{unitid}, i, 1, unit.strings[UNITNAME], unit.values[TYPE], {}})

								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end

								alreadyused[tileid][i] = 1
							end
						end
					end
				end

				--table.insert(checkthese, {unit.strings[UNITNAME], unit.values[TYPE], unit.values[XPOS], unit.values[YPOS], 0, 1, {unitid})

				for a,b in pairs(letterunits_map) do
					for iid,data in ipairs(b) do
						local x,y,i = data[3],data[4],data[5]
						local unitids = data[7]
						local width = data[6]
						local word,wtype = data[1],data[2]

						local unitid = unitids[1]

						local tileid = x + y * roomsizex

						if (alreadyused[tileid] == nil) or ((alreadyused[tileid] ~= nil) and (alreadyused[tileid][i] == nil)) then
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1] * width
							noy = ndrs[2] * width

							local hm = codecheck(unitid,ox,oy,i)
							local hm2 = codecheck(unitid,nox,noy,i)

							if (#hm == 0) and (#hm2 > 0) then
								-- MF_alert(word .. ", " .. tostring(width))

								table.insert(firstwords, {unitids, i, width, word, wtype, {}})

								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end

								alreadyused[tileid][i] = 1
							end
						end
					end
				end
				
				curr_parser = "text"
				docode(firstwords,wordunits)
				for name,func in pairs(parsingfuncs) do
					curr_parser = name
					func()
				end
				subrules()
				grouprules()
				playrulesound = postrules(alreadyrun)
				updatecode = 0

				local newwordunits,newwordidentifier,wordrelatedunits = findwordunits()

				--MF_alert("ID comparison: " .. newwordidentifier .. " - " .. wordidentifier)

				if (newwordidentifier ~= wordidentifier) then
					updatecode = 1
					code(true)
				else
					--domaprotation()
				end
			elseif metatext_textisword then
				updatecode = 0

				local newwordunits,newwordidentifier,wordrelatedunits = findwordunits()

				--MF_alert("ID comparison: " .. newwordidentifier .. " - " .. wordidentifier)

				if (newwordidentifier ~= wordidentifier) then
					updatecode = 1
					code(true)
				else
					--domaprotation()
				end
			end
		else
			MF_alert("Level destroyed - code() run too many times")
			destroylevel("infinity")
			return
		end

		if (alreadyrun == false) then
			effects_decors()

			if (featureindex["broken"] ~= nil) then
				brokenblock(checkthese)
			end

			if (featureindex["3d"] ~= nil) then
				updatevisiontargets()
			end

			if generaldata.flags[LOGGING] then
				updatelogrules()
			end
		end

		do_mod_hook("rule_update_after",{alreadyrun})
	end

	if (alreadyrun == false) then
		local rulesoundshort = ""
		alreadyrun = true
		if playrulesound and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
			local pmult,sound = checkeffecthistory("rule")
			rulesoundshort = sound
			local rulename = "rule" .. tostring(math.random(1,5)) .. rulesoundshort
			MF_playsound(rulename)
		end
	end
end

-- also fixes text prefix with letters (that's what parse_letter is for)
function codecheck(unitid,ox,oy,cdir_,ignore_end_,parse_letter)
	local unit = mmf.newObject(unitid)
	local ux,uy = unit.values[XPOS],unit.values[YPOS]
	local x = unit.values[XPOS] + ox
	local y = unit.values[YPOS] + oy
	local result = {}
	local letters = false
	local justletters = false
	local cdir = cdir_ or 0

	local ignore_end = false
	if (ignore_end_ ~= nil) then
		ignore_end = ignore_end_
	end

	if (cdir == 0) then
		MF_alert("CODECHECK - CDIR == 0 - why??")
	end

	local tileid = x + y * roomsizex

	if (unitmap[tileid] ~= nil) then
		for i,b in ipairs(unitmap[tileid]) do
			local v = mmf.newObject(b)
			local w = 1

			if (v.values[TYPE] ~= 5 or parse_letter) and (v.flags[DEAD] == false) then -- letter texts are considered when NOT a firstword
				if (v.strings[UNITTYPE] == "text") and not metatext_textisword then
					table.insert(result, {{b}, w, v.strings[NAME], v.values[TYPE], cdir})
				else
					if (#wordunits > 0) then
						for c,d in ipairs(wordunits) do
							if (b == d[1]) and testcond(d[2],d[1]) then
								if metatext_textisword and (string.sub(v.strings[UNITNAME],1,5) == "text_") then
									table.insert(result, {{b}, w, v.strings[NAME], v.values[TYPE], cdir})
								else
									table.insert(result, {{b}, w, get_broaded_str(v.strings[UNITNAME]), v.values[TYPE], cdir})
								end
							end
						end
					end
				end
			else
				justletters = true
			end
		end
	end

	if (letterunits_map[tileid] ~= nil) then
		for i,v in ipairs(letterunits_map[tileid]) do
			local unitids = v[7]
			local width = v[6]
			local word = v[1]
			local wtype = v[2]
			local dir = v[5]

			if (string.len(word) > 5) and (string.sub(word, 1, 5) == "text_") then
				word = string.sub(v[1], 6)
			end

			local valid = true
			if ignore_end and ((x ~= v[3]) or (y ~= v[4])) and (width > 1) then
				valid = false
			end

			if (cdir ~= 0) and (width > 1) then
				if ((cdir == 1) and (ux > v[3]) and (ux < v[3] + width)) or ((cdir == 2) and (uy > v[4]) and (uy < v[4] + width)) then
					valid = false
				end
			end

			--MF_alert(word .. ", " .. tostring(valid) .. ", " .. tostring(dir) .. ", " .. tostring(cdir))

			if (dir == cdir) and valid then
				table.insert(result, {unitids, width, word, wtype, dir})
				letters = true
			end
		end
	end

	return result,letters,justletters
end

--[[
Makes text rules apply to all text.
Also makes NOT METATEXT act as all text except the subject, and fixes quirks if enabled.
]]--
function addoption(option,conds_,ids,visible,notrule,tags_,visualonly_)
	--MF_alert(option[1] .. ", " .. option[2] .. ", " .. option[3])

	local visual = true
	local visualonly = false

	if (visible ~= nil) then
		visual = visible
	end
	if visualonly_ ~= nil then
		visualonly = visualonly_
		if visualonly == true and visual == false then
			return
		end
	end

	local conds = {}

	if (conds_ ~= nil) then
		conds = conds_
	else
		MF_alert("nil conditions in rule: " .. option[1] .. ", " .. option[2] .. ", " .. option[3])
	end

	local tags = tags_ or {}

	local foundparsertag = false
	for _,tag in ipairs(tags) do
		if (tag == curr_parser) then
			foundparsertag = true
			break
		end
	end

	if not foundparsertag then
		table.insert(tags, curr_parser .. "rule")
	end

	if (#option == 3) then
		local rule = {option,conds,ids,tags}
		local target = option[1]
		local verb = option[2]
		local effect = option[3]
		local foundtag
		local tageverfound = false
		for _, v in ipairs(broad_nouns) do
			foundtag = false
			if metatext_fixquirks then
				for num, tag in pairs(tags) do
					if tag == v then --or (is_string_metax(tag)) then
						foundtag = true
						tageverfound = true
						break
					end
				end
			end
			if foundtag or (metatext_hasmaketextnometa and (get_pref(target) == v .. "_" or is_string_metax(target))) then
				if effect == v then
					if verb == "is" and foundtag then
						effect = target
					elseif verb == "has" or verb == "become" then
						effect = v .. "_" .. v
					elseif verb == "make" then
						visualonly = true
					end
				elseif effect == "not " .. v then
					if verb == "is" and foundtag then
						effect = "not " .. target
					elseif verb == "has" or verb == "become" then
						effect = "not " .. v .. "_" .. v
					elseif verb == "make" then
						visualonly = true
					end
				elseif is_str_broad_noun(effect) then
					if verb == "has" or verb == "become" or verb == "make" or verb == "is" then
						effect = effect .. "_" .. v
					end
				elseif string.sub(effect, 1, 5) == "group" or string.sub(effect, 1, 9) == "not group" then
					if (verb == "has" or verb == "make" or verb == "become") and foundtag then
						return
					end
				end
				rule = { { target, verb, effect }, conds, ids, tags }
			end
		end
		if metatext_istextnometa and (is_str_broad_noun(effect) or is_str_notted_broad_noun(effect)) and verb == "is" and (is_str_special_prefixed(target) or is_string_metax(target)) then
			if effect == get_broaded_str(target) then
				effect = target
			elseif effect == "not "..get_broaded_str(target) then
				effect = "not " .. target
			elseif string.sub(target, 1, 4) ~= "meta" then
				if is_str_broad_noun(effect) then
					effect = effect .. "_" .. get_broaded_str(target)
				end
			end
			rule = { { target, verb, effect }, conds, ids, tags }
		elseif ((string.sub(effect, 1, 4) == "meta") or (string.sub(effect, 1, 8) == "not meta")) and (verb == "is" or verb == "become") then
			local isnot = (string.sub(effect, 1, 8) == "not meta")
			local level = string.sub(effect, 5)
			if isnot then
				level = string.sub(effect, 9)
			end
			if tonumber(level) ~= nil and tonumber(level) >= -1 then
				local metalevel = getmetalevel(target)
				if metalevel == tonumber(level) and (findnoun(target, nlist.brief) == false and (not is_str_broad_noun(target))) then
					effect = target
					if isnot then
						effect = "not " .. target
					end
					rule = { { target, verb, effect }, conds, ids, tags }
				end
			end
		end
		if not visualonly then
			table.insert(features, rule)
		end

		if (featureindex[effect] == nil) and not visualonly then
			featureindex[effect] = {}
		end

		if (featureindex[target] == nil) and not visualonly then
			featureindex[target] = {}
		end

		if (featureindex[verb] == nil) and not visualonly then
			featureindex[verb] = {}
		end

		if not visualonly then
			table.insert(featureindex[effect], rule)
			table.insert(featureindex[verb], rule)
		end

		if (target ~= effect) and not visualonly then
			table.insert(featureindex[target], rule)
		end

		if visual then
			local originalrule = {option,conds,ids,tags}
			local visualrule = copyrule(originalrule)
			table.insert(visualfeatures, visualrule)
			if visualonly then
				return
			end
		end

		local groupcond = false

		if (string.sub(target, 1, 5) == "group") or (string.sub(effect, 1, 5) == "group" and ((not is_str_writelike_verb(verb)) or not tageverfound)) or (string.sub(target, 1, 9) == "not group") or (string.sub(effect, 1, 9) == "not group") then
			groupcond = true
		end

		if (notrule ~= nil) then
			local notrule_effect = notrule[1]
			local notrule_id = notrule[2]

			if (notfeatures[notrule_effect] == nil) then
				notfeatures[notrule_effect] = {}
			end

			local nr_e = notfeatures[notrule_effect]

			if (nr_e[notrule_id] == nil) then
				nr_e[notrule_id] = {}
			end

			local nr_i = nr_e[notrule_id]

			table.insert(nr_i, rule)
		end

		if (#conds > 0) then
			local addedto = {}

			for i,cond in ipairs(conds) do
				local condname = cond[1]
				if (string.sub(condname, 1, 4) == "not ") then
					condname = string.sub(condname, 5)
				end

				if (condfeatureindex[condname] == nil) then
					condfeatureindex[condname] = {}
				end

				if (addedto[condname] == nil) then
					table.insert(condfeatureindex[condname], rule)
					addedto[condname] = 1
				end

				if (cond[2] ~= nil) then
					if (#cond[2] > 0) then
						local newconds = {}

						--alreadyused[target] = 1

						for a,b in ipairs(cond[2]) do
							local alreadyused = {}

							if (b ~= "all") and (b ~= "not all") then
								alreadyused[b] = 1
								table.insert(newconds, b)
							elseif (b == "all") then
								for a,mat in pairs(objectlist) do
									if (alreadyused[a] == nil) and (findnoun(a,nlist.short) == false) then
										table.insert(newconds, a)
										alreadyused[a] = 1
									end
								end
							elseif (b == "not all") then
								table.insert(newconds, "empty")
								for _,v in ipairs(broad_nouns) do
									table.insert(newconds, v)
								end
							end

							if (string.sub(b, 1, 5) == "group") or (string.sub(b, 1, 9) == "not group") then
								groupcond = true
							end
						end

						cond[2] = newconds
					end
				end
			end
		end

		if groupcond then
			table.insert(groupfeatures, rule)
		end

		local targetnot = string.sub(target, 1, 4)
		local targetnot_ = string.sub(target, 5)

		if (targetnot == "not ") and ((objectlist[targetnot_] ~= nil) or (targetnot_ == "all")) and (string.sub(targetnot_, 1, 5) ~= "group") and (string.sub(effect, 1, 5) ~= "group") and (string.sub(effect, 1, 9) ~= "not group") or (((string.sub(effect, 1, 5) == "group") or (string.sub(effect, 1, 9) == "not group")) and (targetnot_ == "all")) then
			if (targetnot_ ~= "all") then
				if (is_str_special_prefixed(targetnot_)) then
					local pref = get_pref(targetnot_)
					for i,mat in pairs(fullunitlist) do
						if (i ~= targetnot_) and (get_pref(i) == pref) then
							local rule = {i,verb,effect}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
						end
					end
				elseif string.sub(targetnot_, 1, 4) == "meta" then
					local level = string.sub(targetnot_, 5)
					if tonumber(level) == nil then
						level = -2
					end
					local donelevel = {}
					donelevel[tonumber(level)] = 1
					if not metatext_includenoun then
						donelevel[-1] = 1
					end
					for i,mat in pairs(fullunitlist) do
						local metalevel = getmetalevel(i)
						if donelevel[metalevel] == nil and (findnoun(i,nil,true) == false) then
							donelevel[metalevel] = 1
							local rule = {"meta"..metalevel,verb,effect}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
						end
					end
				else
					for i,mat in pairs(objectlist) do
						if (i ~= targetnot_) and (findnoun(i) == false) then
							local rule = {i,verb,effect}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
						end
					end
				end
			else
				local rule = { "empty", verb, effect }
				local newconds = {}
				for a, b in ipairs(conds) do
					table.insert(newconds, b)
				end
				addoption(rule, newconds, ids, false, { effect, #featureindex[effect] }, tags)
				for _,i in ipairs(broad_nouns) do
					local rule = {i,verb,effect}
					local newconds = {}
					for a,b in ipairs(conds) do
						table.insert(newconds, b)
					end
					addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
				end
			end
		end
		if is_str_broad_noun(target) and fullunitlist ~= nil then
			for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
				if (get_pref(a) == target .. "_") then
					local newconds = {}
					local newtags = {}
					local stop = false

					for c,d in ipairs(conds) do
						table.insert(newconds, d)
					end

					for c,d in ipairs(tags) do
						table.insert(newtags, d)
					end

					table.insert(newtags, target)

					local newword1 = a
					local newword2 = verb
					local newword3 = effect
					if objectlist[a] == nil then
						objectlist[a] = 1
					end
					if newword3 == target then
						if newword2 == "is" then
							newword3 = newword1
						elseif newword2 == "has" or newword2 == "become" then
							newword3 = target .. "_" .. target
						elseif newword2 == "make" then
							stop = true
						end
					elseif newword3 == "not " .. target then
						if newword2 == "is" then
							newword3 = "not " .. newword1
						elseif newword2 == "has" or newword2 == "become" then
							newword3 = "not " .. target .. "_" .. target
						elseif newword2 == "make" then
							stop = true
						end
					elseif string.sub(newword3,1,5) == "group" or string.sub(newword3,1,9) == "not group" then
						if newword2 == "become" or newword2 == "has" or newword2 == "make" then
							stop = true
						end
					end

					local newrule = {newword1, newword2, newword3}
					if not stop then
						addoption(newrule,newconds,ids,false,nil,newtags)
					end
				end
			end
			if (verb == "mimic") and (is_str_broad_noun(effect) or is_string_metax(effect)) then --@mods (metatext x extrem)
				for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
                    if (get_pref(a) == effect .. "_") or is_string_metax(effect) then
                        local stop = false
						local newconds = {}
						local newtags = {}

						for c,d in ipairs(conds) do
							table.insert(newconds, d)
						end

						for c,d in ipairs(tags) do
							if d == "dontadd" then
								stop = true
								break
							end
							table.insert(newtags, d)
						end

						table.insert(newtags, "visualmimic")
						table.insert(newtags, "verb"..effect)

						local newword1 = target
						local newword2 = verb
						local newword3 = a

						local newrule = {newword1, newword2, newword3}
						if not stop then
							addoption(newrule,newconds,ids,false,nil,newtags)
						end
					end
				end
			end
		elseif string.sub(target,1,4) == "meta" and fullunitlist ~= nil then
			local level = string.sub(target,5)
			if tonumber(level) ~= nil and tonumber(level) >= -1 then
				for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
					local metalevel = getmetalevel(a)
					if metalevel == tonumber(level) and (findnoun(a,nil,true) == false) then
						local newconds = {}
						local newtags = {}
						local stop = false

						for c,d in ipairs(conds) do
							table.insert(newconds, d)
						end

						for c,d in ipairs(tags) do
							table.insert(newtags, d)
						end

						table.insert(newtags, target)

						local newword1 = a
						local newword2 = verb
						local newword3 = effect
						if newword3 == get_broaded_str(a) and metalevel >= 0 then
							if newword2 == "is" then
								newword3 = newword1
							elseif newword2 == "has" or newword2 == "become" then
								newword3 = newword3.."_"..newword3
							elseif newword2 == "make" then
								stop = true
							end
						elseif newword3 == "not "..get_broaded_str(a) and metalevel >= 0 then
							if newword2 == "is" then
								newword3 = "not " .. newword1
							elseif newword2 == "has" or newword2 == "become" then
								newword3 = "not "..newword3.."_"..newword3
							elseif newword2 == "make" then
								stop = true
							end
						elseif newword3 == target then
							if newword2 == "is" or newword2 == "become" or newword2 == "has" then
								newword3 = newword1
							elseif newword2 == "make" then
								stop = true
							end
						elseif newword3 == "not " .. target then
							if newword2 == "is" or newword2 == "become" or newword2 == "has" then
								newword3 = "not " .. newword1
							elseif newword2 == "make" then
								stop = true
							end
						elseif string.sub(newword3,1,5) == "group" or string.sub(newword3,1,9) == "not group" then
							if newword2 == "become" or newword2 == "has" or newword2 == "make" then
								stop = true
							end
						end

						local newrule = {newword1, newword2, newword3}
						if not stop then
							addoption(newrule,newconds,ids,false,nil,newtags)
						end
					end
				end
			end
			if (verb == "mimic") and (is_str_broad_noun(effect) or is_string_metax(effect)) then
				if tonumber(level) ~= nil and tonumber(level) >= -1 then
					for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
						local metalevel = getmetalevel(a)
						if metalevel == tonumber(level) and (findnoun(a,nil,true) == false) then
							local newconds = {}
							local newtags = {}
							local stop = false

							for c,d in ipairs(conds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(tags) do
								if d == "dontadd" then
									stop = true
									break
								end
								table.insert(newtags, d)
							end

							table.insert(newtags, "visualmimic")
							table.insert(newtags, "verb"..effect)
							table.insert(newtags, "verbmeta" .. level)

							local newword1 = target
							local newword2 = verb
							local newword3 = a

							local newrule = {newword1, newword2, newword3}
							if not stop then
								addoption(newrule,newconds,ids,false,nil,newtags)
							end
						end
					end
				end
				if is_string_metax(effect) then
					for _, metan in ipairs(broad_nouns) do
                        local newconds = {}
                        local newtags = {}

                        for c, d in ipairs(conds) do
                            table.insert(newconds, d)
                        end

                        for c, d in ipairs(tags) do
                            table.insert(newtags, d)
                        end

                        table.insert(newtags, "visualmimic")
                        table.insert(newtags, "dontadd")
                        table.insert(newtags, "verb" .. metan)
                        table.insert(newtags, "verbmeta" .. level)

                        local newword1 = target
                        local newword2 = verb
                        local newword3 = metan

                        local newrule = { newword1, newword2, newword3 }
                        addoption(newrule, newconds, ids, false, nil, newtags)
                    end
				end
			end
		elseif (is_str_broad_noun(effect) or is_str_notted_broad_noun(effect)) and (targetnot ~= "not ") and verb ~= "is" and verb ~= "become" and verb ~= "make" and verb ~= "has" and (not is_str_writelike_verb(verb)) and verb ~= "follow" then
			for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
				local reale = effect
				local isnot = string.sub(effect, 1, 4) == "not "
				if isnot then reale = string.sub(effect, 5) end
				if (get_pref(a) == reale .. "_") then
					local stop = false
					local newconds = {}
					local newtags = {}

					for c,d in ipairs(conds) do
						table.insert(newconds, d)
					end

					for c,d in ipairs(tags) do
						if d == "dontadd" then
							stop = true
							break
						end
						table.insert(newtags, d)
					end

					table.insert(newtags, "verb"..reale)

					local newword1 = target
					local newword2 = verb
					local newword3 = a
					if isnot then
						newword3 = "not " .. a
					end

					local newrule = {newword1, newword2, newword3}
					if not stop then
						addoption(newrule,newconds,ids,false,nil,newtags)
					end
				end
			end
		elseif ((string.sub(effect,1,4) == "meta" or string.sub(effect,1,8) == "not meta")) and (targetnot ~= "not ") and verb ~= "is" and verb ~= "become" and verb ~= "make" and verb ~= "has" and (not is_str_writelike_verb(verb)) and verb ~= "follow" then
            local isnot = (string.sub(effect, 1, 8) == "not meta")
			local level = string.sub(effect,5)
			if isnot then
				level = string.sub(effect,9)
			end
			if tonumber(level) ~= nil and tonumber(level) >= -1 then
				for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
					local metalevel = getmetalevel(a)
					if metalevel == tonumber(level) and (findnoun(a,nil,true) == false) then
						local newconds = {}
						local newtags = {}

						for c,d in ipairs(conds) do
							table.insert(newconds, d)
						end

						for c,d in ipairs(tags) do
							table.insert(newtags, d)
						end
						
						if is_str_special_prefixed(a) then
							table.insert(newtags, "verb"..get_broaded_str(a))
						end
						table.insert(newtags, "verbmeta" .. level)

						local newword1 = target
						local newword2 = verb
						local newword3 = a
						if objectlist[a] == nil then
							objectlist[a] = 1
						end
						if isnot then
							newword3 = "not " .. a
						end

						local newrule = {newword1, newword2, newword3}
						addoption(newrule,newconds,ids,false,nil,newtags)
					end
				end
			end
			if (verb == "mimic") and isnot == false then
				for _,metan in ipairs(broad_nouns) do
                    local newconds = {}
                    local newtags = {}

                    for c, d in ipairs(conds) do
                        table.insert(newconds, d)
                    end

                    for c, d in ipairs(tags) do
                        table.insert(newtags, d)
                    end

                    table.insert(newtags, "dontadd")
                    table.insert(newtags, "verb" .. metan)
                    table.insert(newtags, "verbmeta" .. level)

                    local newword1 = target
                    local newword2 = verb
                    local newword3 = metan
                    if fullunitlist[metan] == nil then
                        fullunitlist[metan] = 1
                    end

                    local newrule = { newword1, newword2, newword3 }
                    addoption(newrule, newconds, ids, false, nil, newtags)
                end
			end
		end
	end
end

-- Fixes various MIMIC bugs.
function subrules()
	local mimicprotects = {}

	if (featureindex["all"] ~= nil) then
		for k,rules in ipairs(featureindex["all"]) do
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]
			local tags = rules[4]

			if (rule[3] == "all") then
				if (rule[2] ~= "is") then
					local nconds = {}

					if (featureindex["not all"] ~= nil) then
						for a,prules in ipairs(featureindex["not all"]) do
							local prule = prules[1]
							local pconds = prules[2]

							if (prule[1] == rule[1]) and (prule[2] == rule[2]) and (prule[3] == "not all") then
								local ipconds = invertconds(pconds)

								for c,d in ipairs(ipconds) do
									table.insert(nconds, d)
								end
							end
						end
					end

					for i,mat in pairs(objectlist) do
						if (findnoun(i) == false) then
							local newrule = {rule[1],rule[2],i}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							for a,b in ipairs(nconds) do
								table.insert(newconds, b)
							end
							addoption(newrule,newconds,ids,false,nil,tags)
						end
					end
				end
			end

			if (rule[1] == "all") and (string.sub(rule[3], 1, 4) ~= "not ") then
				local nconds = {}

				if (featureindex["not all"] ~= nil) then
					for a,prules in ipairs(featureindex["not all"]) do
						local prule = prules[1]
						local pconds = prules[2]

						if (prule[1] == rule[1]) and (prule[2] == rule[2]) and (prule[3] == "not " .. rule[3]) then
							local ipconds = invertconds(pconds)

							if crashy_ then
								crashy = true
							end

							for c,d in ipairs(ipconds) do
								table.insert(nconds, d)
							end
						end
					end
				end

				for i,mat in pairs(objectlist) do
					if (findnoun(i) == false) then
						local newrule = {i,rule[2],rule[3]}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						for a,b in ipairs(nconds) do
							table.insert(newconds, b)
						end
						addoption(newrule,newconds,ids,false,nil,tags)
					end
				end
			end

			if (rule[1] == "all") and (string.sub(rule[3], 1, 4) == "not ") then
				for i,mat in pairs(objectlist) do
					if (findnoun(i) == false) then
						local newrule = {i,rule[2],rule[3]}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						addoption(newrule,newconds,ids,false,nil,tags)
					end
				end
			end
		end
	end

	if (featureindex["mimic"] ~= nil) then
		for i,rules in ipairs(featureindex["mimic"]) do
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]

			if (rule[2] == "mimic") then
				local object = rule[1]
				local target = rule[3]
				local isnot = false

				if (string.sub(target, 1, 4) == "not ") then
					target = string.sub(target, 5)
					isnot = true
				end

				if isnot then
					if (mimicprotects[object] == nil) then
						mimicprotects[object] = {}
					end

					table.insert(mimicprotects[object], {target, conds, rule[3]})
				end
			end
		end
	end

	if (featureindex["mimic"] ~= nil) then
		for i,rules in ipairs(featureindex["mimic"]) do
			local visualonly = false
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]
			local visual = true
			local verbpair = {}
			for i,v in ipairs(tags) do
				if is_str_broad_noun(v) or string.sub(v,1,4) == "meta" then
					visual = false
				elseif v == "visualmimic" then
					visualonly = true
				elseif string.sub(v,1,4) == "verb" then
					verbpair[string.sub(v,5)] = 1
				end
			end

			if (rule[2] == "mimic") then
				local object = rule[1]
				local target = rule[3]
				local mprotects = mimicprotects[object] or {}
				local extraconds = {}

				local valid = true
				if is_str_broad_noun(object) or string.sub(object,1,4) == "meta" then
					visualonly = true
				end

				if (string.sub(target, 1, 4) == "not ") then
					valid = false
				end

				for a,b in ipairs(mprotects) do
					if (b[1] == target) then
						local pconds = b[2]

						if (#pconds == 0) then
							valid = false
						else
							local newconds = invertconds(pconds)

							for c,d in ipairs(newconds) do
								table.insert(extraconds, d)
							end
						end
					end
				end

				local copythese = {}

				if valid then
					if (getmat(object,true) ~= nil) and (getmat(target,true) ~= nil) then
						if (featureindex[target] ~= nil) then
							copythese = featureindex[target]
						end
					end

					for a,b in ipairs(copythese) do
						local trule = b[1]
						local tconds = b[2]
						local ids = b[3]
						local ttags = b[4]

						local valid = true
						for c,d in ipairs(ttags) do
							if (d == "mimic") or verbpair[d] ~= nil or (string.sub(d,1,4) == "verb") then
								valid = false
								break
							end
						end

						if (trule[1] == target) and (trule[2] ~= "mimic") and valid then
							local newconds = {}
							local newtags = {}

							for c,d in ipairs(tconds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(conds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(extraconds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(ttags) do
								table.insert(newtags, d)
							end

							for c,d in ipairs(tags) do
								table.insert(newtags, d)
							end

							table.insert(newtags, "mimicparent_" .. tostring(i))
							table.insert(newtags, "mimic")
							
							local newword1 = object
							local newword2 = trule[2]
							local newword3 = trule[3]
							
							local newrule = {newword1, newword2, newword3}
							
							limiter = limiter + 1
							addoption(newrule,newconds,ids,true,nil,newtags,visualonly)
							
							if (limiter > limit) then
								MF_alert("Level destroyed - mimic happened too many times!")
								destroylevel("toocomplex")
								return
							end
						end
					end
				end
			end
		end
	end
end


-- Disables if X IS X, like REVERT.
function postrules(alreadyrun_)
	local protects = {}
	local newruleids = {}
	local ruleeffectlimiter = {}
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false

	for i,unit in ipairs(units) do
		unit.active = false
	end

	local limit = #features

	for i,rules in ipairs(features) do
		if (i <= limit) then
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]

			if (rule[1] == rule[3]) and (rule[2] == "is") then
				table.insert(protects, i)
			end

			if (ids ~= nil) then
				local works = true
				local idlist = {}
				local effectsok = false

				if (#ids > 0) then
					for a,b in ipairs(ids) do
						table.insert(idlist, b)
					end
				end

				if (#idlist > 0) and works then
					for a,d in ipairs(idlist) do
						for c,b in ipairs(d) do
							if (b ~= 0) then
								local bunit = mmf.newObject(b)

								if is_parser(bunit) then
									bunit.active = true
									setcolour(b,"active")
								end
								newruleids[b] = 1

								if (ruleids[b] == nil) and (#undobuffer > 1) and (alreadyrun == false) and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
									if (ruleeffectlimiter[b] == nil) then
										local x,y = bunit.values[XPOS],bunit.values[YPOS]
										local c1,c2 = getcolour(b,"active")
										--MF_alert(b)
										MF_particles_for_unit("bling",x,y,5,c1,c2,1,1,b)
										ruleeffectlimiter[b] = 1
									end

									if (rule[2] ~= "play") then
										playrulesound = true
									end
								end
							end
						end
					end
				elseif (#idlist > 0) and (works == false) then
					for a,visualrules in pairs(visualfeatures) do
						local vrule = visualrules[1]
						local same = comparerules(rule,vrule)

						if same then
							table.remove(visualfeatures, a)
						end
					end
				end
			end

			local rulenot = 0
			local neweffect = ""

			local nothere = string.sub(rule[3], 1, 4)

			if (nothere == "not ") then
				rulenot = 1
				neweffect = string.sub(rule[3], 5)
			end

			if (rulenot == 1) then
				local newconds,crashy = invertconds(conds,nil,rule[3])

				local newbaserule = {rule[1],rule[2],neweffect}

				local target = rule[1]
				local verb = rule[2]

				for a,b in ipairs(featureindex[target]) do
					local same = comparerules(newbaserule,b[1])

					if same then
						--MF_alert(rule[1] .. ", " .. rule[2] .. ", " .. neweffect .. ": " .. b[1][1] .. ", " .. b[1][2] .. ", " .. b[1][3])
						local theseconds = b[2]

						if (#newconds > 0) then
							if (newconds[1] ~= "never") then
								for c,d in ipairs(newconds) do
									table.insert(theseconds, d)
								end
							else
								theseconds = {"never",{}}
							end
						end

						if crashy then
							addoption({rule[1],"is","crash"},theseconds,ids,false,nil,rules[4])
						end

						b[2] = theseconds
					end
				end
			end
		end
	end

	if (#protects > 0) then
		for i,v in ipairs(protects) do
			local rule = features[v]

			local baserule = rule[1]
			local conds = rule[2]

			local target = baserule[1]

			local newconds = {{"never",{}}}

			if (conds[1] ~= "never") then
				if (#conds > 0) then
					newconds = {}

					for a,b in ipairs(conds) do
						local condword = b[1]
						local condgroup = {}

						if (string.sub(condword, 1, 1) == "(") then
							condword = string.sub(condword, 2)
						end

						if (string.sub(condword, -1) == ")") then
							condword = string.sub(condword, 1, #condword - 1)
						end

						local newcondword = "not " .. condword

						if (string.sub(condword, 1, 3) == "not") then
							newcondword = string.sub(condword, 5)
						end

						if (a == 1) then
							newcondword = "(" .. newcondword
						end

						if (a == #conds) then
							newcondword = newcondword .. ")"
						end

						if (b[2] ~= nil) then
							for c,d in ipairs(b[2]) do
								table.insert(condgroup, d)
							end
						end

						table.insert(newconds, {newcondword, condgroup})
					end
				end

				if (featureindex[target] ~= nil) then
					for a,rules in ipairs(featureindex[target]) do
						local targetrule = rules[1]
						local targetconds = rules[2]
						local object = targetrule[3]

						if (targetrule[1] == target) and (((targetrule[2] == "is") and (target ~= object)) or is_str_writelike_verb(targetrule[2])) and ((getmat(object) ~= nil) or (object == "revert") or is_str_writelike_verb(targetrule[2]) or (object == "meta")  or (object == "unmeta")) and (string.sub(object, 1, 5) ~= "group") then
							if (#newconds > 0) then
								if (newconds[1] == "never") then
									targetconds = {}
								end

								for c,d in ipairs(newconds) do
									table.insert(targetconds, d)
								end
							end

							rules[2] = targetconds
						end
					end
				end
			end
		end
	end

	ruleids = newruleids

	if (spritedata.values[VISION] == 0) then
		ruleblockeffect()
	end

	return playrulesound
end


--[[
Makes NOT METATEXT act as all text except the subject in group membership.
Also fixes a ridiculous amount of group bugs.
--]]
function grouprules()
	groupmembers = {}
	local groupmembers_quick = {}

	local isgroup = {}
	local isnotgroup = {}
	local xgroup = {}
	local xnotgroup = {}
	local groupx = {}
	local notgroupx = {}
	local groupxgroup = {}
	local groupxgroup_diffname = {}
	local groupisnotgroup = {}
	local notgroupisgroup = {}

	local evilrecursion = false
	local notgroupisgroup_diffname = {}

	local memberships = {}

	local combined = {}

	for i,v in ipairs(groupfeatures) do
		local rule = v[1]
		local conds = v[2]

		local type_isgroup = false
		local type_isnotgroup = false
		local type_xgroup = false
		local type_xnotgroup = false
		local type_groupx = false
		local type_notgroupx = false
		local type_recursive = false

		local groupname1 = ""
		local groupname2 = ""

		if (string.sub(rule[1], 1, 5) == "group") then
			type_groupx = true
			groupname1 = rule[1]
		elseif (string.sub(rule[1], 1, 9) == "not group") then
			type_notgroupx = true
			groupname1 = string.sub(rule[1], 5)
		end

		if (string.sub(rule[3], 1, 5) == "group") then
			type_xgroup = true
			groupname2 = rule[3]

			if (rule[2] == "is") then
				type_isgroup = true
			end
		elseif (string.sub(rule[3], 1, 9) == "not group") then
			type_xnotgroup = true
			groupname2 = string.sub(rule[3], 5)

			if (rule[2] == "is") then
				type_isnotgroup = true
			end
		end

		if (conds ~= nil) and (#conds > 0) then
			for a,cond in ipairs(conds) do
				local params = cond[2] or {}
				for c,param in ipairs(params) do
					if (string.sub(param, 1, 5) == "group") or (string.sub(param, 1, 9) == "not group") then
						type_recursive = true
						break
					end
				end
			end
		end

		if type_isgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				table.insert(isgroup, {v, type_recursive})

				if (memberships[rule[3]] == nil) then
					memberships[rule[3]] = {}
				end

				if (memberships[rule[3]][rule[1]] == nil) then
					memberships[rule[3]][rule[1]] = {}
				end

				table.insert(memberships[rule[3]][rule[1]], {v, type_recursive})
			elseif (type_notgroupx == false) then
				if (groupname1 == groupname2) then
					table.insert(groupxgroup, {v, type_recursive})
				else
					table.insert(groupxgroup_diffname, {v, type_recursive})
				end
			else
				if (groupname1 == groupname2) then
					table.insert(notgroupisgroup, {v, type_recursive})
				else
					evilrecursion = true
					table.insert(notgroupisgroup_diffname, {v, type_recursive})
				end
			end
		elseif type_xgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				table.insert(xgroup, {v, type_recursive})
			else
				table.insert(groupxgroup, {v, type_recursive})
			end
		elseif type_isnotgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				if (isnotgroup[rule[1]] == nil) then
					isnotgroup[rule[1]] = {}
				end

				table.insert(isnotgroup[rule[1]], {v, type_recursive})

				if (xnotgroup[rule[1]] == nil) then
					xnotgroup[rule[1]] = {}
				end

				table.insert(xnotgroup[rule[1]], {v, type_recursive})
			elseif (type_notgroupx == false) then
				if (groupname1 == groupname2) then
					table.insert(groupisnotgroup, {v, type_recursive})
				else
					table.insert(groupxgroup_diffname, {v, type_recursive})
				end
			else
				if (groupname1 == groupname2) then
					table.insert(groupxgroup, {v, type_recursive})
				else
					evilrecursion = true
					table.insert(notgroupisgroup_diffname, {v, type_recursive})
				end
			end
		elseif type_xnotgroup then
			if (xnotgroup[rule[1]] == nil) then
				xnotgroup[rule[1]] = {}
			end

			table.insert(xnotgroup[rule[1]], {v, type_recursive})
		elseif type_groupx then
			table.insert(groupx, {v, type_recursive})
		elseif type_notgroupx then
			table.insert(notgroupx, {v, type_recursive})
		end
	end

	local diffname_done = false
	local diffname_used = {}

	while (diffname_done == false) do
		diffname_done = true

		for i,v_ in ipairs(groupxgroup_diffname) do
			if (diffname_used[i] == nil) then
				local v = v_[1]
				local recursion = v_[2] or false

				local rule = v[1]
				local conds = v[2]
				local ids = v[3]
				local tags = v[4]

				local gn1 = rule[1]
				local gn2 = rule[3]

				local notrule = false
				if (string.sub(gn2, 1, 4) == "not ") then
					notrule = true
				end

				local newconds = {}
				newconds = copyconds(newconds,conds)

				for a,b_ in ipairs(isgroup) do
					local b = b_[1]
					local brec = b_[2] or recursion or false
					local grule = b[1]
					local gconds = b[2]
					local gtags = b[4]

					if (grule[3] == gn1) then
						diffname_used[i] = 1
						diffname_done = false

						newconds = copyconds(newconds,gconds)

						local newrule = {grule[1],"is",gn2}
						local newtags = concatenate(tags,gtags)

						if (notrule == false) then
							table.insert(isgroup, {{newrule,newconds,ids,newtags}, brec})
						else
							if (isnotgroup[grule[1]] == nil) then
								isnotgroup[grule[1]] = {}
							end

							table.insert(isnotgroup[grule[1]], {{newrule,newconds,ids,newtags}, brec})
						end
					end
				end
			end
		end
	end

	if evilrecursion then
		diffname_done = false
		local evilrec_id = ""
		local evilrec_id_base = ""
		local evilrec_memberships_base = {}
		local evilrec_memberships_quick = {}

		local evilrec_limit = 0

		for i,v in pairs(memberships) do
			evilrec_id_base = evilrec_id_base .. i
			for a,b in pairs(v) do
				evilrec_id_base = evilrec_id_base .. a

				if (evilrec_memberships_quick[i] == nil) then
					evilrec_memberships_quick[i] = {}
				end

				evilrec_memberships_quick[i][a] = b

				if (evilrec_memberships_base[i] == nil) then
					evilrec_memberships_base[i] = {}
				end

				evilrec_memberships_base[i][a] = b
			end
		end

		evilrec_id = evilrec_id_base

		while (diffname_done == false) and (evilrec_limit < 10) do
			local foundmembers = {}
			local foundid = evilrec_id_base

			for i,v in pairs(evilrec_memberships_base) do
				foundid = foundid .. i
				for a,b in pairs(v) do
					foundid = foundid .. a
				end
			end

			for i,v_ in ipairs(notgroupisgroup_diffname) do
				local v = v_[1]
				local recursion = v_[2] or false

				local rule = v[1]
				local conds = v[2]
				local ids = v[3]
				local tags = v[4]

				local notrule = false
				local gn1 = string.sub(rule[1], 5)
				local gn2 = rule[3]

				if (string.sub(gn2, 1, 4) == "not ") then
					notrule = true
					gn2 = string.sub(gn2, 5)
				end

				if (foundmembers[gn2] == nil) then
					foundmembers[gn2] = {}
				end

				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and ((evilrec_memberships_quick[gn1] == nil) or ((evilrec_memberships_quick[gn1] ~= nil) and (evilrec_memberships_quick[gn1][a] == nil))) then
						if (foundmembers[gn2][a] == nil) then
							foundmembers[gn2][a] = {}
						end

						table.insert(foundmembers[gn2][a], {v, recursion})
					end
				end
			end

			for i,v in pairs(foundmembers) do
				foundid = foundid .. i
				for a,b in pairs(v) do
					foundid = foundid .. a
				end
			end

			-- MF_alert(foundid .. " == " .. evilrec_id)

			if (foundid == evilrec_id) then
				diffname_done = true

				for i,v in pairs(foundmembers) do
					for a,d in pairs(v) do
						for c,b_ in ipairs(d) do
							local b = b_[1]
							local brule = b[1]
							local rec = b_[2] or false

							local newrule = {a,"is",brule[3]}
							local newconds = {}
							newconds = copyconds(newconds,b[2])
							local newids = concatenate(b[3])
							local newtags = concatenate(b[4])

							if (string.sub(brule[3], 1, 4) ~= "not ") then
								table.insert(isgroup, {{newrule,newconds,newids,newtags}, rec})
							else
								if (isnotgroup[a] == nil) then
									isnotgroup[a] = {}
								end

								table.insert(isnotgroup[a], {{newrule,newconds,newids,newtags}, rec})
							end
						end
					end
				end
			else
				evilrec_memberships_quick = {}
				evilrec_id = foundid

				for i,v in pairs(evilrec_memberships_base) do
					evilrec_memberships_quick[i] = {}

					for a,b in pairs(v) do
						evilrec_memberships_quick[i][a] = b
					end
				end

				for i,v in pairs(foundmembers) do
					evilrec_memberships_quick[i] = {}

					for a,b in pairs(v) do
						evilrec_memberships_quick[i][a] = b
					end
				end

				evilrec_limit = evilrec_limit + 1
			end
		end

		if (evilrec_limit >= 10) then
			HACK_INFINITY = 200
			destroylevel("infinity")
			return
		end
	end

	memberships = {}

	for i,v_ in ipairs(isgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local name_ = rule[1]
		local namelist = {}

		if (string.sub(name_, 1, 4) ~= "not ") and (metatext_fixquirks or ((not is_str_broad_noun(name_)) and string.sub(name_,1,4) ~= "meta")) then
			namelist = {name_}
		elseif (name_ ~= "not all") and (metatext_fixquirks or ((not is_str_broad_noun(name_)) and string.sub(name_,1,4) ~= "meta")) then
			if is_str_special_prefixed(get_ref(name_)) then --Exceptions for NOT METATEXT and NOT META#
				for a,b in pairs(fullunitlist) do
					if (is_str_special_prefixed(a)) and (a ~= get_ref(name_)) then
						table.insert(namelist, a)
					end
				end
			elseif string.sub(name_, 5, 8) == "meta" then
				local level = string.sub(name_, 9)
				if tonumber(level) == nil then
					level = -2
				end
				for a,b in pairs(fullunitlist) do
					local metalevel = getmetalevel(a)
					if metalevel ~= tonumber(level) and (findnoun(a,nil,true) == false) and (metatext_includenoun or metalevel >= 0) then
						timedmessage(a,0,#namelist)
						table.insert(namelist, a)
					end
				end
			else
				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and (a ~= string.sub(name_, 5)) then
						table.insert(namelist, a)
					end
				end
			end
		end

		for index,name in ipairs(namelist) do
			local never = false

			local prevents = {}

			if (isnotgroup[name] ~= nil) then
				for a,b_ in ipairs(isnotgroup[name]) do
					local b = b_[1]
					local brule = b[1]

					local grouptype = string.sub(brule[3], 5)

					if (grouptype == rule[3]) then
						recursion = b_[2] or recursion
						local pconds,crashy,neverfound = invertconds(b[2])

						if (neverfound == false) then
							for a,cond in ipairs(pconds) do
								table.insert(prevents, cond)
							end
						else
							never = true
							break
						end
					end
				end
			end

			if (never == false) then
				local fconds = {}
				fconds = copyconds(fconds,conds)
				fconds = copyconds(fconds,prevents)

				table.insert(groupmembers, {name,fconds,rule[3],recursion,v[4]})

				if (groupmembers_quick[name .. "_" .. rule[3]] == nil) then
					groupmembers_quick[name .. "_" .. rule[3]] = {}
				end

				table.insert(groupmembers_quick[name .. "_" .. rule[3]], {name,fconds,rule[3],recursion})

				if (memberships[rule[3]] == nil) then
					memberships[rule[3]] = {}
				end

				table.insert(memberships[rule[3]], {name,fconds,v[4]})

				for a,b_ in ipairs(groupx) do
					local b = b_[1]
					recursion = b_[2] or recursion

					local grule = b[1]
					local gconds = b[2]
					local gids = b[3]
					local gtags = b[4]

					if (grule[1] == rule[3]) then
						local newrule = {name,grule[2],grule[3]}
						local newconds = {}
						local newids = concatenate(ids,gids)
						local newtags = concatenate(tags,gtags)

						newconds = copyconds(newconds,conds)
						newconds = copyconds(newconds,gconds)

						if (#prevents == 0) and (not is_str_broad_noun(name_)) and string.sub(name_,1,4) ~= "meta" then
							table.insert(combined, {newrule,newconds,newids,newtags})
						elseif (not is_str_broad_noun(name_)) and string.sub(name_,1,4) ~= "meta" then
							newconds = copyconds(newconds,prevents)
							table.insert(combined, {newrule,newconds,newids,newtags})
						end
					end
				end
			end
		end
	end

	for i,v_ in ipairs(groupxgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local gn1 = rule[1]
		local gn2 = rule[3]

		local never = false

		local notrule = false
		if (string.sub(gn1, 1, 4) == "not ") then
			notrule = true
			gn1 = string.sub(gn1, 5)
		end

		local prevents = {}
		if (xnotgroup[gn1] ~= nil) then
			for a,b_ in ipairs(xnotgroup[gn1]) do
				local b = b_[1]
				local brule = b[1]

				if (brule[1] == rule[1]) and (brule[2] == rule[2]) and (brule[3] == "not " .. rule[3]) then
					recursion = b_[2] or recursion

					local pconds,crashy,neverfound = invertconds(b[2])

					if (neverfound == false) then
						for a,cond in ipairs(pconds) do
							table.insert(prevents, cond)
						end
					else
						never = true
						break
					end
				end
			end
		end

		if (never == false) then
			local team1 = {}
			local team2 = {}

			if (notrule == false) then
				if (memberships[gn1] ~= nil) then
					for a,b in ipairs(memberships[gn1]) do
						table.insert(team1, b)
					end
				end
			else
				local ignorethese = {}

				if (memberships[gn1] ~= nil) then
					for a,b in ipairs(memberships[gn1]) do
						ignorethese[b[1]] = 1

						local iconds,icrash,inever = invertconds(b[2])

						if (inever == false) then
							table.insert(team1, {b[1],iconds,b[3]})
						end
					end
				end

				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and (ignorethese[a] == nil) then
						table.insert(team1, {a})
					end
				end
			end

			if (memberships[gn2] ~= nil) then
				for a,b in ipairs(memberships[gn2]) do
					table.insert(team2, b)
				end
			end

			for a,b in ipairs(team1) do
				for c,d in ipairs(team2) do
					local newrule = {b[1],rule[2],d[1]}
					local newconds = {}
					newconds = copyconds(newconds,conds)

					if (b[2] ~= nil) then
						newconds = copyconds(newconds,b[2])
					end

					if (d[2] ~= nil) then
						newconds = copyconds(newconds,d[2])
					end

					if (#prevents > 0) then
						newconds = copyconds(newconds,prevents)
					end

					local newids = concatenate(ids)
					local newtags = concatenate(tags)

					table.insert(combined, {newrule,newconds,newids,newtags})
				end
			end
		end
	end

	if (#notgroupx > 0) then
		for name,v in pairs(objectlist) do
			if (findnoun(name) == false) then
				for a,b_ in ipairs(notgroupx) do
					local b = b_[1]
					local recursion = b_[2] or false

					local rule = b[1]
					local conds = b[2]
					local ids = b[3]
					local tags = b[4]

					local newconds = {}
					newconds = copyconds(newconds,conds)

					local groupname = string.sub(rule[1], 5)
					local valid = true

					if (groupmembers_quick[name .. "_" .. groupname] ~= nil) then
						for c,d in ipairs(groupmembers_quick[name .. "_" .. groupname]) do
							recursion = d[4] or recursion

							local iconds,icrash,inever = invertconds(d[2])
							newconds = copyconds(newconds,iconds)

							if inever then
								valid = false
								break
							end
						end
					end

					if valid then
						local newrule = {name,rule[2],rule[3]}
						local newids = {}
						local newtags = {}
						newids = concatenate(newids,ids)
						newtags = concatenate(newtags,tags)

						table.insert(combined, {newrule,newconds,newids,newtags})
					end
				end
			end
		end
	end

	for i,v_ in ipairs(xgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		if (string.sub(rule[1], 1, 5) ~= "group") and (string.sub(rule[1], 1, 9) ~= "not group") and (rule[2] ~= "is") then
			local team2 = {}

			if (memberships[rule[3]] ~= nil) then
				for a,b in ipairs(memberships[rule[3]]) do
					local foundtag = false
					if metatext_fixquirks and (rule[2] == "become" or rule[2] == "has" or rule[2] == "make" or is_str_writelike_verb(b[1])) and (not is_str_broad_noun(b[1])) and string.sub(b[1],1,4) ~= "meta" then
						for num,tag in ipairs(b[3]) do
							if is_str_broad_noun(tag) or string.sub(tag,1,4) == "meta" then
								foundtag = true
								break
							end
						end
					elseif (is_str_broad_noun(b[1]) or string.sub(b[1],1,4) == "meta") and (rule[2] ~= "become" and rule[2] ~= "has" and rule[2] ~= "make" and (not is_str_writelike_verb(rule[2]))) then
						foundtag = true
					end
					if not foundtag then
						table.insert(team2, b)
					end
				end
			end

			for a,b in ipairs(team2) do
				local newrule = {rule[1],rule[2],b[1]}
				local newconds = {}
				newconds = copyconds(newconds,conds)

				if (b[2] ~= nil) then
					newconds = copyconds(newconds,b[2])
				end

				local newids = concatenate(ids)
				local newtags = concatenate(tags)

				table.insert(combined, {newrule,newconds,newids,newtags})
			end
		end
	end

	for i,k in pairs(xnotgroup) do
		for c,v_ in ipairs(k) do
			local v = v_[1]
			local recursion = v_[2] or false

			local rule = v[1]
			local conds = v[2]
			local ids = v[3]
			local tags = v[4]

			if (string.sub(rule[1], 1, 5) ~= "group") and (string.sub(rule[1], 1, 9) ~= "not group") and (rule[2] ~= "is") then
				local team2 = {}

				local gn2 = string.sub(rule[3], 5)

				if (memberships[gn2] ~= nil) then
					for a,b in ipairs(memberships[gn2]) do
						table.insert(team2, b)
					end
				end

				for a,b in ipairs(team2) do
					local newrule = {rule[1],rule[2],"not " .. b[1]}
					local newconds = {}
					newconds = copyconds(newconds,conds)

					if (b[2] ~= nil) then
						newconds = copyconds(newconds,b[2])
					end

					local newids = concatenate(ids)
					local newtags = concatenate(tags)

					table.insert(combined, {newrule,newconds,newids,newtags})
				end
			end
		end
	end

	for i,v_ in ipairs(groupisnotgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local team1 = {}

		if (memberships[rule[1]] ~= nil) then
			for a,b in ipairs(memberships[rule[1]]) do
				table.insert(team1, b)
			end
		end

		for a,b in ipairs(team1) do
			local newrule = {b[1],"is","crash"}
			local newconds = {}
			newconds = copyconds(newconds,conds)

			if (b[2] ~= nil) then
				newconds = copyconds(newconds,b[2])
			end

			local newids = concatenate(ids)
			local newtags = concatenate(tags)

			table.insert(combined, {newrule,newconds,newids,newtags})
		end
	end

	for i,v_ in ipairs(notgroupisgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local team1 = {}

		local gn1 = string.sub(rule[1], 5)

		local ignorethese = {}

		if (memberships[gn1] ~= nil) then
			for a,b in ipairs(memberships[gn1]) do
				ignorethese[b[1]] = 1

				local iconds,icrash,inever = invertconds(b[2])

				if (inever == false) then
					table.insert(team1, {b[1],iconds})
				end
			end
		end

		for a,b in pairs(objectlist) do
			if (findnoun(a) == false) and (ignorethese[a] == nil) then
				table.insert(team1, {a})
			end
		end

		for a,b in ipairs(team1) do
			local newrule = {b[1],"is","crash"}
			local newconds = {}
			newconds = copyconds(newconds,conds)

			if (b[2] ~= nil) then
				newconds = copyconds(newconds,b[2])
			end

			local newids = concatenate(ids)
			local newtags = concatenate(tags)

			table.insert(combined, {newrule,newconds,newids,newtags})
		end
	end

	for i,v in ipairs(combined) do
		addoption(v[1],v[2],v[3],false,nil,v[4])
	end
end
function findwordunits()
	local result = {}
	local alreadydone = {}
	local checkrecursion = {}
	local related = {}

	local identifier = ""
	local fullid = {}

	if (featureindex["word"] ~= nil) then
		for i,v in ipairs(featureindex["word"]) do
			local rule = v[1]
			local conds = v[2]
			local ids = v[3]

			local name = rule[1]
			local subid = ""

			if (rule[2] == "is") then
				if (fullunitlist[name] ~= nil) and (findnoun(name,nlist.short,true) == false) and (metatext_textisword or string.sub(name,1,5) ~= "text_") and (alreadydone[name] == nil) then
					local these = findall({name,{}})
					alreadydone[name] = 1

					if (#these > 0) then
						for a,b in ipairs(these) do
							local bunit = mmf.newObject(b)
							local valid = true

							if (featureindex["broken"] ~= nil) then
								if (hasfeature(getname(bunit),"is","broken",b,bunit.values[XPOS],bunit.values[YPOS]) ~= nil) then
									valid = false
								end
							end

							if valid then
								table.insert(result, {b, conds})
								subid = subid .. name
								-- LISÄÄ TÄHÄN LISÄÄ DATAA
							end
						end
					end
				end

				if (#subid > 0) then
					for a,b in ipairs(conds) do
						local condtype = b[1]
						local params = b[2] or {}

						subid = subid .. condtype

						if (#params > 0) then
							for c,d in ipairs(params) do
								subid = subid .. tostring(d)

								related = findunits(d,related,conds)
							end
						end
					end
				end

				table.insert(fullid, subid)

				--MF_alert("Going through " .. name)

				if (#ids > 0) then
					if (#ids[1] == 1) then
						local firstunit = mmf.newObject(ids[1][1])

						local notname = name
						if (string.sub(name, 1, 4) == "not ") then
							notname = string.sub(name, 5)
						end

						local foundnontexttag = false
						for _,noun in ipairs(broad_nouns) do
							if noun ~= "text" then
								for _,tag in ipairs(v[4]) do
									if tag == noun .. "rule" then
										foundnontexttag = true
										goto largebreak
									end
								end
							end
						end
						:: largebreak ::

						if (firstunit.strings[UNITNAME] ~= "text_" .. name) and (firstunit.strings[UNITNAME] ~= "text_" .. notname) and not foundnontexttag then
							--MF_alert("Checking recursion for " .. name)
							table.insert(checkrecursion, {name, i})
						end
					end
				else
					MF_alert("No ids listed in Word-related rule! rules.lua line 1302 - this needs fixing asap (related to grouprules line 1118)")
				end
			end
		end

		table.sort(fullid)
		for i,v in ipairs(fullid) do
			-- MF_alert("Adding " .. v .. " to id")
			identifier = identifier .. v
		end

		-- MF_alert("Identifier: " .. identifier)

		for a,checkname_ in ipairs(checkrecursion) do
			local found = false

			local checkname = checkname_[1]

			local b = checkname
			if (string.sub(b, 1, 4) == "not ") then
				b = string.sub(checkname, 5)
			end

			for i,v in ipairs(featureindex["word"]) do
				local rule = v[1]
				local ids = v[3]
				local tags = v[4]

				-- Gotta change this to prevent some false infinite loops
				if (rule[1] == b) or can_refer(rule[1], b) then
					for c,g in ipairs(ids) do
						for a,d in ipairs(g) do
							local idunit = mmf.newObject(d)

							-- Tässä pitäisi testata myös Group!
							if (idunit.strings[UNITNAME] == "text_" .. rule[1]) or (rule[1] == "all") then
								--MF_alert("Matching objects - found")
								found = true
							elseif (string.sub(rule[1], 1, 5) == "group") then
								--MF_alert("Group - found")
								found = true
							elseif (rule[1] ~= checkname) and (string.sub(rule[1], 1, 3) == "not") then
								--MF_alert("Not Object - found")
								found = true
							elseif (idunit.strings[UNITNAME] == "text_text_") then
								found = true
							end
						end
					end

					for c,g in ipairs(tags) do
						if (g == "mimic") then
							found = true
						end
					end
				end
			end

			if (found == false) then
				--MF_alert("Wordunit status for " .. b .. " is unstable!")
				identifier = "null"
				wordunits = {}

				for i,v in pairs(featureindex["word"]) do
					local rule = v[1]
					local ids = v[3]

					--MF_alert("Checking to disable: " .. rule[1] .. " " .. ", not " .. b)

					if (rule[1] == b) or (rule[1] == "not " .. b) then
						v[2] = {{"never",{}}}
					end
				end

				if (string.sub(checkname, 1, 4) == "not ") then
					local notrules_word = notfeatures["word"]
					local notrules_id = checkname_[2]
					local disablethese = notrules_word[notrules_id]

					for i,v in ipairs(disablethese) do
						v[2] = {{"never",{}}}
					end
				end
			end
		end
	end

	--MF_alert("Current id (end): " .. identifier)

	return result,identifier,related
end

--[[ Hempuli implemented a wonderful new system that makes rule parsing more efficient...
but that means every rule needs to have a noun. Modifies this to detect the prefix and claim there's a noun.]]--
function calculatesentences(unitid,x,y,dir)
	local drs = dirs[dir]
	local ox,oy = drs[1],drs[2]

	local finals = {}
	local sentences = {}
	local sentence_ids = {}

	local sents = {}
	local done = false
	local verbfound = false
	local objfound = false
	local starting = true

	local step = 0
	local rstep = 0
	local combo = {}
	local variantshere = {}
	local totalvariants = 1
	local maxpos = 0

	local limiter = 5000

	local combospots = {}

	local unit = mmf.newObject(unitid)

	local done = false
	while (done == false) and (totalvariants < limiter) do
		local words,letters,jletters = codecheck(unitid,ox*rstep,oy*rstep,dir,true,(step~=0))

		--MF_alert(tostring(unitid) .. ", " .. unit.strings[UNITNAME] .. ", " .. tostring(#words))

		step = step + 1
		rstep = rstep + 1

		if (totalvariants >= limiter) then
			MF_alert("Level destroyed - too many variants A")
			destroylevel("toocomplex")
			return nil
		end

		if (totalvariants < limiter) then
			if (#words > 0) then
				sents[step] = {}

				for i,v in ipairs(words) do
					--unitids, width, word, wtype, dir

					--MF_alert("Step " .. tostring(step) .. ", word " .. v[3] .. " here")

					if (v[4] == 1) then
						verbfound = true
					end

					if (v[4] == 0) or (v[4] == 4 and is_str_special_prefix(v[3])) then
						objfound = true
					end

					if starting and ((v[4] == 0) or (v[4] == 3) or (v[4] == 4)) then
						starting = false
					end

					table.insert(sents[step], v)
				end

				if starting then
					sents[step] = nil
					step = step - 1
				else
					totalvariants = totalvariants * #words
					variantshere[step] = #words
					combo[step] = 1

					if (totalvariants >= limiter) then
						MF_alert("Level destroyed - too many variants B")
						destroylevel("toocomplex")
						return nil
					end

					if (#words > 1) then
						combospots[#combospots + 1] = step
					end

					if (totalvariants > #finals) then
						local limitdiff = totalvariants - #finals
						for i=1,limitdiff do
							table.insert(finals, {})
						end
					end
				end
			else
				--MF_alert("Step " .. tostring(step) .. ", no words here, " .. tostring(letters) .. ", " .. tostring(jletters))

				if jletters then
					variantshere[step] = 0
					sents[step] = {}
					combo[step] = 0

					if starting then
						sents[step] = nil
						step = step - 1
					end
				else
					done = true
				end
			end
		end
	end

	--MF_alert(tostring(step) .. ", " .. tostring(totalvariants))

	if (totalvariants >= limiter) then
		MF_alert("Level destroyed - too many variants C")
		destroylevel("toocomplex")
		return nil
	end

	if (verbfound == false) or (step < 3) or (objfound == false) then
		return {},{},0,0,{}
	end

	maxpos = step

	local combostep = 0

	for i=1,totalvariants do
		step = 1
		sentences[i] = {}
		sentence_ids[i] = ""

		while (step < maxpos) do
			local c = combo[step]

			if (c ~= nil) then
				if (c > 0) then
					local s = sents[step]
					local word = s[c]

					local w = word[2]

					--MF_alert(tostring(i) .. ", step " .. tostring(step) .. ": " .. word[3] .. ", " .. tostring(#word[1]) .. ", " .. tostring(w))

					table.insert(sentences[i], {word[3], word[4], word[1], word[2]})
					sentence_ids[i] = sentence_ids[i] .. tostring(c - 1)

					step = step + w
				else
					break
				end
			else
				MF_alert("c is nil, " .. tostring(step))
				break
			end
		end

		if (#combospots > 0) then
			combostep = 0

			local targetstep = combospots[combostep + 1]

			combo[targetstep] = combo[targetstep] + 1

			while (combo[targetstep] > variantshere[targetstep]) do
				combo[targetstep] = 1

				combostep = (combostep + 1) % #combospots

				targetstep = combospots[combostep + 1]

				combo[targetstep] = combo[targetstep] + 1
			end
		end
	end

	--[[
	MF_alert(tostring(totalvariants) .. ", " .. tostring(#sentences))
	for i,v in ipairs(sentences) do
		local text = ""

		for a,b in ipairs(v) do
			text = text .. b[1] .. " "
		end

		MF_alert(text)
	end
	]]--

	return sentences,finals,maxpos,totalvariants,sentence_ids
end

