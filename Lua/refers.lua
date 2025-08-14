condlist['refers'] = function(params,checkedconds,checkedconds_,cdata)
	for i, j in pairs(params) do
		local passedthischeck = false
		local _params = tostring(j)
		local unitname
		if cdata.unitid ~= 2 then
			if cdata.unitid ~= 1 then
				unitname = mmf.newObject(cdata.unitid).strings[UNITNAME]
			else
				unitname = "level"
			end
		else
			unitname = "empty"
		end
        
		if (get_ref(unitname) == _params) and (is_str_special_prefixed(unitname)) then
            passedthischeck = true
        end

		if hasfeature(unitname, "is", "word", cdata.unitid) and (unitname == _params) then
			passedthischeck = true
		end
		if not passedthischeck then return false, checkedconds end
	end
	return true, checkedconds
end