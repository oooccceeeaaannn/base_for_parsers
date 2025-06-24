condlist['refers'] = function(params,checkedconds,checkedconds_,cdata)
	for i, j in pairs(params) do
		local passedthischeck = false
		local _params = " " .. j
		if cdata.unitid ~= 2 then
			local unitname = mmf.newObject(cdata.unitid).strings[UNITNAME]
		else
			local unitname = "empty"
		end

		_params = string.sub(_params, 2)
        
		if get_ref(unitname) == _params then
            passedthischeck = true
        end

		if hasfeature(unitname, "is", "word", cdata.unitid) and (unitname == _params) then
			passedthischeck = true
		elseif hasfeature(unitname, "is", "symbol", cdata.unitid) and (unitname == _params) then
			passedthischeck = true
		end
		if not passedthischeck then return false, checkedconds end
	end
	return true, checkedconds
end