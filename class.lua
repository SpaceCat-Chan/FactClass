local interface_table = {}

local function copy_protected(child, parent)
	for name, upper_parent in pairs(parent.meta.class.definition.inherit) do
		copy_protected(child, upper_parent)
	end
	for protected_name, _ in pairs(parent.meta.class.definition.protected) do
		child.meta.members.get[protected_name] = function(...)
			return parent.meta.members.get[protected_name](...)
		end
		child.meta.members.set[protected_name] = function(...)
			return parent.meta.members.set[protected_name](...)
		end
		child.meta.members.call[protected_name] = function(...)
			return parent.meta.members.call[protected_name](...)
		end
	end
end

local function copy_public(child, parent)
	for _, upper_parent in pairs(parent.meta.class.definition.inherit) do
		copy_public(child, upper_parent)
	end
	for public_name, _ in pairs(parent.meta.class.definition.public) do
		child.meta.members.get[public_name] = function(...)
			return parent.meta.members.get[public_name](...)
		end
		child.meta.members.set[public_name] = function(...)
			return parent.meta.members.set[public_name](...)
		end
		child.meta.members.call[public_name] = function(...)
			return parent.meta.members.call[public_name](...)
		end
		child.get[public_name] = function(...)
			return child.meta.members.get[public_name](...)
		end
		child.set[public_name] = function(...)
			return child.meta.members.set[public_name](...)
		end
		child.call[public_name] = function(...)
			return child.meta.members.call[public_name](...)
		end
	end
end

function interface_table.class(definition)
	definition.inherit = definition.inherit or {}
	definition.private = definition.private or {}
	definition.protected = definition.protected or {}
	definition.public = definition.public or {}

	local class = {}
	class.definition = definition

	function class:no_constructor_new()
		local instance = {}
		instance.get = {}
		instance.set = {}
		instance.call = {}
		instance.meta = {}
		instance.meta.self = instance
		instance.meta.class = class
		instance.meta.members = {}
		instance.meta.members.get = {}
		instance.meta.members.set = {}
		instance.meta.members.call = {}
		instance.meta.members.meta = instance.meta
		instance.meta.actual_data = {}
		instance.meta.parents = {}

		for name, parent in pairs(self.definition.inherit) do
			instance.meta.parents[name] = parent:no_constructor_new()
			copy_protected(instance, instance.meta.parents[name])
			copy_public(instance, instance.meta.parents[name])
		end

		for private_name, private_value in pairs(self.definition.private) do
			instance.meta.actual_data[private_name] = private_value
			instance.meta.members.get[private_name] = function(...)
				return instance.meta.actual_data[private_name]
			end
			instance.meta.members.set[private_name] = function(data)
				instance.meta.actual_data[private_name] = data
			end
			instance.meta.members.call[private_name] = function(...)
				return instance.meta.actual_data[private_name](instance.meta.members, ...)
			end
		end

		for protected_name, protected_value in pairs(self.definition.protected) do
			instance.meta.actual_data[protected_name] = protected_value
			instance.meta.members.get[protected_name] = function(...)
				return instance.meta.actual_data[protected_name]
			end
			instance.meta.members.set[protected_name] = function(data)
				instance.meta.actual_data[protected_name] = data
			end
			instance.meta.members.call[protected_name] = function(...)
				return instance.meta.actual_data[protected_name](instance.meta.members, ...)
			end
		end

		for public_name, public_value in pairs(self.definition.public) do
			instance.meta.actual_data[public_name] = public_value
			instance.meta.members.get[public_name] = function(...)
				return instance.meta.actual_data[public_name]
			end
			instance.meta.members.set[public_name] = function(data)
				instance.meta.actual_data[public_name] = data
			end
			instance.meta.members.call[public_name] = function(...)
				return instance.meta.actual_data[public_name](instance.meta.members, ...)
			end
			instance.get[public_name] = function(...)
				return instance.meta.members.get[public_name](...)
			end
			instance.set[public_name] = function(...)
				return instance.meta.members.set[public_name](...)
			end
			instance.call[public_name] = function(...)
				return instance.meta.members.call[public_name](...)
			end
		end

		return instance
	end

	function class:new(...)
		local instance = self:no_constructor_new()
		if instance.call.init then
			instance.call.init(...)
		end
		return instance
	end

	return class
end

return interface_table