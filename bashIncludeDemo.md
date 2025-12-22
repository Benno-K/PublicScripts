# bashIncludeDemo
modern scripting language havw the ability
to use some include directives to include
code that should be re-used.
This is somehow missing for bash as you can
only source code.

## The idea
To provide re-usable code the idea was to 
create code, that on one hand can be sourced
to inherit it's function and on the other hand
executes it's function (which is useful for 
testing the function. Assuming you store the
"include"s along with the scripIf you go with 
only one function per file and name that after the file,the use can be straightforward.
``` bash
#!/bin/bash
. ${$0%%/*}/mytool
mytool arg1 arg2 ...
```

## Demo code
To demonstrate this I provided two files:
- bashIncludeDemo
- useIncludeDemo

The `useIncludeDemo` script sources 
`bashIncludeDemo` file and invokes the
`bashIncludeDemo` function to demonstrate the
use of both like a real usecase.
On the other hand one might directly invoke
(NOT source) bashIncludeDemo (with or without
argumens) to test the functionality of the
function.

