A love2D Virtual Machine with a stack and a heap where every slot codes to a pixel (Visual Storage).  Includes an interpreter for basic machine code and a sample program.

This file can be ran just like any other love2D file (don't ask me why I made it in love2D, I have no idea).  When you run the Video Memory Computer (VMC), there is a hidden stack, and a 800x600 window where each pixel has a brightness based on the value stored there.  0 is black, 100 is white, everything in between is a gradient depending on the value from 0-100.  Anything above 100 is white.  The stack and heap are manipulated using basic commands ("visual code") that are mostly one character.  The heap also can not store data outside the range of the window, so all data stored will light up pixels, creating an interesting problem of managing memory while displaying images.  Right now the only way to write code for VMC is in visual code, but soon I will add a compiler for a very basic language called "T" that will hopefully make writing code a little easier. Below is an explanation of every command in visual code



^ --- adds a new 0 to the top of the stack
+ --- increment the number at the top of the stack by 1
- --- increment the number at the top of the stack by -1
= --- combine the top 2 values of the stack
* --- duplicate the number at the top of the stack
o --- drop the top value from the stack
!time! --- pauses the execution of the code for time milliseconds
[x,y] --- pop the top number of the stack (non-destructive) and put it in heap slot (x, y).  If x and y are blank x will be the second value on the stack, y will be the third value on the stack
(x,y) --- copy the value in the (x, y) heap slot to the top of the stack.  If x and y are blank x will be the top value of the stack, and y will be the second value on the stack.
:identifier: --- saves a location or bookmark to jump to
;identifier; --- jumps to the corresponding location if the top of the stack is not 0 (this check is destructive).  This can jump forward or backward in the code.



Below is an explanation of the sample code for VMC.  This code will run an animation that fills the entire screen white



^++++++++++ #add a new number to the stack and increment it up to 10

*********=========[0,0] #duplicate the 10 9 times, add them all up to get 100, store it to (0, 0) in the heap

*****=====--[0,1] #sets the stack value to 598, saves it to heap slot (0, 1)

o^++^ #clear the stack, set up the stack to [2, 0]

:B:(0,0)[]oo+^(0,1)-[0,1]!1!;B; #the first loop, push (0, 0) to the stack (100), store this value to the heap based on the next two values on the stack, (0, 2) on the first loop.  Drop the 100 and x coordinate, increment the y coordinate by 1, then add the 0 back on top.  The subtract 1 from the value in heap (0, 1) which is the counter.  Then pause for 1 millisecond, then if the top value is not 0, loops back to the start, this check clears the top value no matter what.  This will loop 598 times, filling in the rest of the first column.

oo(0,0) #clear the data on the stack and push (0, 0) onto the stack (100)

*****=====[0,1](0,0)*==-[0,0] #stores 600 to (0, 1) and a 799 to (0, 0).  These are counters for the next loop

o^^+ #clear the stack, then make the stack [0, 1]

:D:(0,2)[]o+(0,0)-[0,0];D; #first part of the loop.  This is quite similar to the B loop above, but now we are incrementing the x value instead of the y value (remember x is higher on the stack).  Each time this happens, take 1 off of the counter at (0, 0)

o+^+(0,2)*******=======-[0,0]o(0,1)-[0,1]!1!;D; #once the loop ends, drop the x value, increment y by 1, then add a 1 back to the top of the stack for the starting x value.  Reset the (0, 0) counter to 799, and decrease the (0, 1) counter by 1.  Then, pause for 1 millisecond and return to the original loop, these two loops will continue, filling out the entire grid.

(0,2)[0,1] #now that everything is done, add a 100 to slot (0, 1) to fill in the last pixel
