# _Javaesque_

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

## Metatypes
Javaesque has three types of *metatypes*: **Enumerations**, **Interfaces** and **Classes**.

### Creating a new metatype
There are two ways to create a new metatype, but both methods follow the next structure.

1. The **metatype function**: `enum`, `interface` or `class`.
2. The **name**: A string containing the new metatypes name.
3. The **modifiers**: Special functions that modify the metatype (each metatype has different modifiers: enumerations have no modifiers, interfaces have two and classes have three).
4. The **prototype table**: A table contaning the prototype of the metatype.

#### First method
When using this method we not only create a new metatype, but we also declare a global variable that contains it. 

``` lua
[enum|interface|class] 'Name' [:modifier 'modifier-var'| :modifier] {
	[...]
}
```

#### Second method
The second method is what I call a _weak_ definition. 

When using this method instead of automatically asigning a global variable to our new metatype, we create a _weak_ reference to it that can be then manually paired with a local variable. **Note that with this method we can't pair the _weak_ metatype to a global variable, for that refer to the first method.**

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

### 1. Enumerations
**Enumerations** are a set of defined constants. 

They don't have any modifiers, and you can't modify it's contents once declared.

To use them you simply call the name of the enum followed by the constant variable name `Enum.CONSTANT`.


``` lua
enum 'Days' {
	'Monday', 'Tuesday', 'Wenesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
}

local Colors = enum (nil) {
	'Red', 'Green', 'Blue'
}
```

### 2. Interfaces
**Interfaces** are tables used as a bueprint of variables.

``` lua
interface 'Stack' {
	e = {},

	push = function(self, ...)
	end,
	
	pop = function(self, ...)
	end,
	
	peek = function(self, ...)
	end
}
```

You can **_extend* interfaces just as you would extend classes.
-- You can declare interfaces as STATIC on definition, this means that when implemented,
-- all variables of the interface will be registered as class variables.

