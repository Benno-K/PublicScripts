# bashIncludeDemo
Modern scripting languages have the ability
to use some include directives to implement re-usable code and modularize code. This is somehow missing for bash as you can only `source` code (using `. filename`).

## The idea
To provide re-usable code, the idea was to 
create code, that can be sourced to inherit it's function and, in addition to that, on the can execute it's function (which is useful for testing the function). 
To make it easy and straightforward:
1. Name file and function in it identical
2. Store file in the same directory as the script

Now you can use your code by
1. Sourcing the file (defines function)
2. Using the function

Assuming you are coding sth. named `mytool` and you store the "include"s along with the script and if you go with 
only one function per file and further assuming name that function after the file, the use can be used straightforward[^1][^2][^3].
``` bash
#!/bin/bash
# Somewhere before it is used: source it
. ${0%/*}/mytool
# Further down in the code: use it
mytool arg1 arg2 ...
```
See [^4] for what `${0%/*}` does.

## Demo code
To demonstrate this I provided two files:
- bashIncludeDemo
- useIncludeDemo

The [useIncludeDemo](useIncludeDemo) script sources 
[bashIncludeDemo](bashIncludeDemo) file and invokes the
`bashIncludeDemo` function to demonstrate the use of both like in a real use-case.
On the other hand one might directly invoke
(NOT source) bashIncludeDemo (with or without
argumens) to test the functionality of the
function.

[^1]: For the filename (equivalent to `basename "$0"`), one could use `${0##*/}`, which removes the longest match of `*/` from the start. <br/>So `%` means matching from the end, `#` means matching from the start, and one of these two means shortest match, while two of them mean longest match.

[^2]: Having described this: there are quite some more of these substitution possibilities. Want to go into details? Go [here](https://tldp.org/LDP/abs/html/parameter-substitution.html)

[^3]: of course you can add more than one function - but these then cannot be tested birectly by running the script. I only would recommend this if your main function depends on the function you add. And remember: they all go to one single name-space. So better make sure to use unique names for additional functions!

[^4]:The construct `${0%/*}` removes the shortest match of `/*` from the end of `$0`, effectively extracting the directory path — similar to `dirname "$0"`. It avoids spawning a subprocess, making it faster but less readable. 

