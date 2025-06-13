condlist['refers'] = function(params,checkedconds,checkedconds_,cdata)
	for i, j in pairs(params) do
		local _params = " " .. j

		local unitname = mmf.newObject(cdata.unitid).strings[UNITNAME]
		_params = string.sub(_params, 2)
        
		if get_ref(unitname) == _params then
            return true, checkedconds
        end

		if hasfeature(unitname, "is", "word", cdata.unitid) and (unitname == _params) then
			return true, checkedconds
		elseif hasfeature(unitname, "is", "symbol", cdata.unitid) and (unitname == _params) then
			return true, checkedconds
		end
	end
	return false, checkedconds
end