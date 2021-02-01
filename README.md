# Javaesque for Lua
Library that adds Java-like functionalities to Lua.

``` lua
require 'javaesque'

enum 'Colors' {
	'RED', 'GREEN', 'BLUE'
}

interface 'Coloreable' {
	color = Colors.RED,
	set_color = function(self, color)
		self.color = color
	end
}

interface 'Drawable' : extends 'Coloreable' {
	draw = function(self)
		print(self.width, self.height, self.color)
	end
}

class 'Shape' : implements 'Drawable' {
	constructor = function(self, width, height)
		self.width, self.height = width or self.width, height or self.height
	end;

	width = 10, height = 10
}

local shape1 = Shape(30, 30)
shape1:draw() -- 30	30	RED
shape1:set_color(Colors.BLUE)
shape1:draw() -- 30 30. BLUE
```

## Usage
Metatypes are the backbone of this library. 

There are three types of *metatypes*: **Enumerations**, **Interfaces** and **Classes**.

### Creating a new metatype
There are two ways to create a new metatype.

#### First method
When using the first method we not only create a new metatype, but also a global variable with the name of the newly created metatype that contains it. 

This method has four distintive parts that must be called in the following order:
1. The **metatype function**: `enum`, `interface` or `class`.
2. The **name**: A string containing the new metatypes name.
3. The **modifiers**: Special functions that modify the metatype (each metatype has different modifiers: enumerations have no modifiers, interfaces have two and classes have three).
4. The **prototype table**: A table contaning the prototype of the metatype.

``` lua
	[enum|interface|class] 'Name' [:modifier 'modifier-var'| :modifier] {
		[...]
	}
```

#### Second method
The second method is what I call a _weak_ definition. 

When using this method instead of automatically asigning a global variable to our new metatype, we create a _weak_ reference to it that can be manually paired with a local variable.

``` lua
	-- correct use
	local key = [enum|interface|class] (nil) [: modifier 'modifier-var'| : modifier] {
		[...]
	}
	
	-- non-valid use
	key = [enum|interface|class] (nil) [: modifier 'modifier-var'| : modifier] {
		[...]
	}
```

(Note that with this method we can't pair the _weak_ metatype to a global variable, for that refer to the first method.)

## The metatypes
### Enumerations
**Enumerations** are a set of defined constants. To use them you simply call the name of the enum followed by the constant variable name `Enum.CONSTANT`.

They don't have any modifiers.

``` lua
	enum 'Days' {
		'Monday', 'Tuesday', 'Wenesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
	}
	
	local Colors = enum (nil) {
		'Red', 'Green', 'Blue'
	}
```
