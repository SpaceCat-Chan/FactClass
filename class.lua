local class_table = {}
class_table.classes = {}
class_table.inv_classes = {}

function class_table.copy_parents(child, parent, parent_name)
	for _,upper_parent in pairs(parent.meta.parents) do
		class_table.copy_parents(child, upper_parent)
	end
	for variable, _ in pairs(parent.definition.protected) do
		child.get[variable] = function(self)
			if self.meta.self == self then
				error("protected members can't be getted from public interface")
			end
			return self.meta.parents[parent_name].meta.members[variable]
		end
		child.set[variable] = function(self, new)
			if self.meta.self == self then
				error("protected members can't be setted from public interface")
			end
			self.meta.parents[parent_name].meta.members[variable] = new
		end
		child.call[variable] = function(self, ...)
			if self.meta.self == self then
				error("protected members cant be called from public interface")
			end
			parent.functions[variable](self.meta.parents[parent_name].meta.members, ...)
		end
	end
	for variable, _ in pairs(parent.definition.public) do
		child.get[variable] = function(self)
			return self.meta.parents[parent_name][variable]
		end
		child.set[variable] = function(self, new)
			self.meta.parents[parent_name][variable] = new
		end
		child.call[variable] = function(self, ...)
			return parent.meta.functions[variable](self.meta.parents[parent_name].meta.members, ...)
		end
	end
end

function class_table.class(definition, name)
	if name == nil then
		error("remember class name")
	end

	definition.inherit = definition.inherit or {}
	definition.private = definition.private or {}
	definition.protected = definition.protected or {}
	definition.public = definition.public or {}

	local class = {}
	class.definition = definition

	class.get = {}
	class.set = {}
	class.call = {}
	class.meta = {}
	class.meta.functions = {}
	class.meta.public_variables = {}
	class.meta.other_variables = {}
	class.meta.class = class
	class.meta.name = name
	class.meta.parents = {}

	for parent_name, parent in pairs(definition.inherit) do
		class.meta.parents[parent_name] = parent
		class_table.copy_parents(class, parent, parent_name)
	end

	for variable, init in pairs(definition.private) do
		class.get[variable] = function(self)
			if self.meta.self == self then
				error("private members can't be getted from public interface")
			end
			return self[variable]
		end
		class.set[variable] = function(self, new)
			if self.meta.self == self then
				error("private members can't be setted from public interface")
			end
			self[variable] = new
		end
		class.call[variable] = function(self, ...)
			if self.meta.self == self then
				error("private members cant be called from public interface")
			end
			return class.meta.functions[variable](self, ...)
		end
		if type(init) == "function" then
			class.meta.functions[variable] = init
		end
	end

	for variable, init in pairs(definition.protected) do
		class.get[variable] = function(self)
			if self.meta.self == self then
				error("protected members can't be getted from public interface")
			end
			return self[variable]
		end
		class.set[variable] = function(self, new)
			if self.meta.self == self then
				error("protected members can't be setted from public interface")
			end
			self[variable] = new
		end
		class.call[variable] = function(self, ...)
			if self.meta.self == self then
				error("protected members cant be called from public interface")
			end
			return class.meta.functions[variable](self, ...)
		end
		if type(init) == "function" then
			class.meta.functions[variable] = init
		end
	end

	for variable, init in pairs(definition.public) do
		class.get[variable] = function(self)
			return self.meta.self[variable]
		end
		class.set[variable] = function(self, new)
			self.meta.self[variable] = new
		end
		class.call[variable] = function(self, ...)
			return class.meta.functions[variable](self.meta.members, ...)
		end
		if type(init) == "function" then
			class.meta.functions[variable] = init
		end
	end

	function class.new_no_construct()
		local instance = {}
		instance.meta = {}
		instance.meta.members = {}
		instance.meta.members.meta = instance.meta
		instance.meta.parents = {}
		instance.meta.class_name = name
		instance.meta.self = instance

		for parent_name, parent in pairs(class.definition.inherit) do
			instance.meta.parents[parent_name] = parent:new_no_construct()
		end

		for variable, init in pairs(definition.private) do
			if type(init) ~= "function" then
				instance.meta.members[variable] = init
			end
		end

		for variable, init in pairs(definition.protected) do
			if type(init) ~= "function" then
				instance.meta.members[variable] = init
			end
		end

		for variable, init in pairs(definition.public) do
			if type(init) ~= "function" then
				instance[variable] = init
			end
		end

		return instance
	end

	function class.new(...)
		local instance = class.new_no_construct()
		if class.meta.functions.init then
			class.meta.functions.init(instance.meta.members, ...)
		end
		return instance
	end

	class_table.classes[name] = class
	class_table.inv_classes[class] = name
	return class
end

function class_table.get(self, name)
	return class_table.classes[self.meta.class_name].get[name](self)
end

function class_table.set(self, name, data)
	return class_table.classes[self.meta.class_name].set[name](self, data)
end

function class_table.call(self, name, ...)
	return class_table.classes[self.meta.class_name].call[name](self, ...)
end

return class_table
