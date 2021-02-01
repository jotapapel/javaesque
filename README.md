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
Javaesque has three types of *metatypes*: __Enumerations__, __Interfaces__ and __Classes__.

### Creating a new metatype
There are two ways to create a new metatype, but both methods follow the next structure.

1. The __metatype function__: `enum`, `interface` or `class`.
2. The __name__: A string containing the new metatypes name.
3. The __modifiers__: Special functions that modify the metatype (each metatype has different modifiers: enumerations have no modifiers, interfaces have two and classes have three). Modifiers that accept arguments are called before those who don't.
4. The __prototype table__: A table contaning the prototype of the metatype.

#### First method
When using this method we not only create a new metatype, but we also declare a global variable that contains it. 

``` lua
-- all parenthesis are optional
[enum|interface|class]('Name')[:modifier('modifier-var')|:modifier]({
	[...]
})
```

#### Second method
The second method is what I call a _weak_ definition. 

When using this method instead of automatically asigning a global variable to our new metatype, we create a _weak_ reference to it that can be then manually paired with a local variable. 

__Note that with this method we can't pair the _weak_ metatype to a global variable, for that refer to the first method.__

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
__Enumerations__ are a set of defined constants. 

They don't have any modifiers, and you can't modify it's contents once declared.

To use them you simply call the name of the enum followed by the constant variable name `Enum.CONSTANT`.


``` lua
enum 'Colors' {
	'RED', 'GREEN', 'BLUE'
}
```

### 2. Interfaces
__Interfaces__ are tables used as a bueprint of variables.

``` lua
interface 'Coloreable' {
	color = 'red',
	set_color = function(self, color)
		self.color = color
	end
}
```
They have two modifiers: 

1. __extends__: This modifier allows you to make one interface inherit the variables of another.
```lua
interface 'Drawable' : extends 'Coloreable' {
	draw = function(self)
		print(self.width, self.height, self.color)
	end
}
```
2. __static__: This modifier makes the interface and it's variables _static_, which means that when implemented by a class they will all be treated as _class_ variables (more on this in the Class tab.)
```lua
interface 'Counter' : static {
	instance_number = 0,
	get_count = function(self)
		return self.instance_number
	end,
	instance_add = function(self)
		self.instance_number = self.instance_number + 1
	end
}
```
