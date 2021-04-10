package.path = "../../?.lua;"..package.path -- only needed because the library is outside this folder
local Class = require('class')


local Animal = {
    protected = {
        leg_number = 0,
        speaks = false
    },
    public = {
        get_leg_number = function(self)
            return self.get.leg_number(self)
        end,
        get_speaks = function(self)
            return self.get.speaks(self)
        end
    }
}
Animal = Class.class(Animal)

local my_animal = Animal:new()

print("Generic Animal:")
print(my_animal.call.get_leg_number())
print(my_animal.call.get_speaks())

local Human = {
    inherit = {
        Animal = Animal
    },
    public = {
        init = function(self)
            self.set.leg_number(2)
            self.set.speaks(true)
        end
    }
}
Human = Class.class(Human)

local my_human = Human:new()

print("\nHuman:")
print(my_human.call.get_leg_number())
print(my_human.call.get_speaks())

local many_leg = {
    inherit = {
        Animal
    },
    public = {
        set_leg_number = function(self, leg_count)
            self.set.leg_number(leg_count)
        end,
        init = function(self, leg_count)
            self.set.leg_number(leg_count)
        end
    }
}
many_leg = Class.class(many_leg)

local leg_10 = many_leg:new(10)
local leg_20 = many_leg:new(20)

print("\nleg 10:")
print(leg_10.call.get_leg_number())
print(leg_10.call.get_speaks())

print("\nleg 20:")
print(leg_20.call.get_leg_number())
print(leg_20.call.get_speaks())

leg_10.call.set_leg_number(4)
print("\nleg 10 new:")
print(leg_10.call.get_leg_number())
print(leg_10.call.get_speaks())