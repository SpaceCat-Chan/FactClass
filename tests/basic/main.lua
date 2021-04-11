package.path = "../../?.lua;"..package.path -- only needed because the library is outside this folder
local Class = require('class')


local Animal = {
    protected = {
        leg_number = 0,
        speaks = false
    },
    public = {
        get_leg_number = function(self)
            return Class.get(self, "leg_number")
        end,
        get_speaks = function(self)
            return Class.get(self, "speaks")
        end
    }
}
Animal = Class.class(Animal, "Animal")

local my_animal = Animal.new()

print("Generic Animal:")
print(Animal.call.get_leg_number(my_animal))
print(Animal.call.get_speaks(my_animal))

local Human = {
    inherit = {
        Animal = Animal
    },
    public = {
        init = function(self)
            Class.set(self, "leg_number", 2)
            Class.set(self, "speaks", true)
        end
    }
}
Human = Class.class(Human, "Human")

local my_human = Human.new()

print("\nHuman:")
print(Human.call.get_leg_number(my_human))
print(Human.call.get_speaks(my_human))

local many_leg = {
    inherit = {
        Animal = Animal
    },
    public = {
        set_leg_number = function(self, leg_count)
            Class.set(self, "leg_number", leg_count)
        end,
        init = function(self, leg_count)
            Class.set(self, "leg_number", leg_count)
        end,
        get_leg_number = function(self)
            print("many_leg get_leg")
            -- if you override a base class function, you can only access the base class version if it is public
            return Class.call(self.meta.parents.Animal, "get_leg_number")
        end
    }
}
many_leg = Class.class(many_leg, "many_leg")

local leg_10 = many_leg.new(10)
local leg_20 = many_leg.new(20)

print("\nleg 10:")
print(many_leg.call.get_leg_number(leg_10))
print(many_leg.call.get_speaks(leg_10))

print("\nleg 20:")
print(many_leg.call.get_leg_number(leg_20))
print(many_leg.call.get_speaks(leg_20))

many_leg.call.set_leg_number(leg_10, 4)
print("\nleg 10 new:")
print(many_leg.call.get_leg_number(leg_10))
print(many_leg.call.get_speaks(leg_10))


local many_things = {Animal.new(), Human.new(), Animal.new(), many_leg.new(42)}
for i, v in pairs(many_things) do
    print("\narray index "..tostring(i)..":")
    print(Class.call(v, "get_leg_number"))
    print(Class.call(v, "get_speaks"))
end
