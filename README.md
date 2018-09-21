# xNN's Kernelbuilder
> Android kernel build script written in Bash


- - -


- Usage: 

`./build.sh -h` : show Help.
 
`./build.sh -a` : execute the complete script.


-  for debugging and/or eliminating build errors:  
  `./build.sh -b` : only clean the kernel source & outputfolder, then build.
  

`./build.sh -c` : only clean output directory, then build.



- - -


- Functions:

```
"0  = show_greeter             |  = praise the script builder :)"
"1  = make_output_dir          |  = create Output directory"
"2  = make clean               |  "
"3  = make config              |  = define a kernelconfiguration"
"4  = make menuconfig          |  = make menuconfig"
"5  = compile                  |  = compile the kernel"
"6  = copy_kernel              |  = copy compiled kernel to Out"
"7  = make_modules             |  = make and install .ko files to Out"

```

- - -

To-Do:
- [ ] add support for kernels not crosscompiled

