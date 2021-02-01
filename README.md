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

There are three types of *metatypes*: Enumerations, Interfaces and Classes.

### Creating a new metatype
There are two ways to create a new metatype.

#### First method
The first method has four blocks:
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

When using the first method we not only create a new metatype, but also a global variable with the name of the newly created metatype that contains it. 

When using this method instead we create a _weak_ reference to the metatype that can be manually paired with a local variable.

``` lua
	-- correct use
	local key = [enum|interface|class] (nil) [: modifier 'modifier-var'| : modifier] {
		[...]
	}
	
	-- incorrect, non-valid use
	key = [enum|interface|class] (nil) [: modifier 'modifier-var'| : modifier] {
		[...]
	}
```

(Note that with this method we can't pair the _weak_ metatype to a global variable, for that refer to the first method)


### Enumerations
There are two ways of declaring a new class.

The first method used to create a new class is to call it's function, followed by a string stating the name of the new class and finished with a table containing all the class definitions (more on this later).
``` lua
class 'Animal' {
	[...]
}
```

The second method is what I call a _weak_ definition. 
When using the first method we not only create a new class, but also a global variable with the name of the newly created class that contains it. When using this method instead we create a _weak_ class that can be manually paired with a local variable.
(Note that with this method we cannot pair the _weak_ class with a global variable, for that refer to the first method)

``` lua
-- Allowed
local Structure = class (nil) {
	[...]
}

-- Forbidden
Structure = class (nil) {
	[...]
}
```
