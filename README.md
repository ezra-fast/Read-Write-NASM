# Read and Write to Virtual Address During Runtime

This pure x86-64 program solicits a virtual address from the user, and then prompts the user to either read what is at that address or write bits to that virtual address during runtime. If the user is able to identify and provide an address being used to store one of the output strings and write to that address during execution, it is possible to witness the address space being injected without execution stopping (the output will be changed according to user input).
