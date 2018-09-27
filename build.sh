#!/bin/bash

#
#   Kernel build script by xNN
#   (https://github.com/xNNism)
#


###############################################
##     Colorize and add text parameters      ##
###############################################

blk=$(tput setaf 0) # black
red=$(tput setaf 1) # red
grn=$(tput setaf 2) # green
ylw=$(tput setaf 3) # yellow
blu=$(tput setaf 4) # blue
mga=$(tput setaf 5) # magenta
cya=$(tput setaf 6) # cyan
wht=$(tput setaf 7) # white
#
txtbld=$(tput bold) # Bold
bldblk=${txtbld}$(tput setaf 0) # black
bldred=${txtbld}$(tput setaf 1) # red
bldgrn=${txtbld}$(tput setaf 2) # green
bldylw=${txtbld}$(tput setaf 3) # yellow
bldblu=${txtbld}$(tput setaf 4) # blue
bldmga=${txtbld}$(tput setaf 5) # magenta
bldcya=${txtbld}$(tput setaf 6) # cyan
bldwht=${txtbld}$(tput setaf 7) # white
txtrst=$(tput sgr0) # Reset


###################################
##     ADDITIONAL PARAMETERS     ##
###################################

# ${CPU}
CPU=$(lscpu | grep "Model name:" | cut -c 22-)
# ${CORES}
CORES=$(lscpu | grep "^CPU(s)" | cut -c 22-)
# ${BLOCK_DEV}
BLOCK_DEV=$(echo -e "${Yellow}Block Devices: \n${Green}$(lsblk | grep "sd." | awk '{print "'${Red}'> '${Green}'"$1" '${Yellow}'Type: '${Green}'"$6" '${Yellow}'Size: '${Green}'"$4" '${Green}'"$7}' | column -t | sed 's/>/    >/')")
# ${K_VERSION}
K_VERSION=$(uname -srm)
# ${SHELL}
SHELL="$SHELL"
# ${GPU_TEMP}
GPU_TEMP=$(echo -e "$(sensors | grep "temp1:" | cut -c 16-22)")
# ${CPU_TEMP}
CPU_TEMP=$(echo -e "$(sensors | grep "Package id 0:" | cut -c 17-23)")
# ${CPU_CLOCK}
CPU_CLOCK=$(echo -e "$(cat /proc/cpuinfo | grep "cpu MHz" | cut -c 12-15)")


##############################
##     SET ENVIRONMENT     ##
##############################

KERNEL_DIR="/path/to/kernel/source"
OUTPUT_DIR="$KERNEL_DIR/Out"
ARCHITECTURE=" "  # (e.g.: "arm" "amrch64")
TOOLCHAIN="/path/to/toolchain"  # (e.g.: "/opt/toolchains/linaro-aarch64-linux-gnu/bin/aarch64-linux-gnu-") 
KERNEL_IMAGE=" "  # (e.g.: "Image.gz-dtb", "zImage", "zImage-dtb")
DEFCONFIG=" "  # (e.g.: "msm9884_defconfig")
KERNEL_NAME=" " # (e.g.: "-MyKernel")
NUM_CPUS=" " # (e.g.: "2","4","8"...)

## export parameters
export ARCH=$ARCHITECTURE
export CROSS_COMPILE="$TOOLCHAIN"

## if no CPU number given, use all.
if [ -z "$NUM_CPUS" ]; then
 NUM_CPUS=`grep -c ^processor /proc/cpuinfo`
fi


#######################
##     FUNCTIONS     ##
#######################

make_output_dir()
{
	echo -e "#1 - make and/or clean the output directory..."

	# remove old output folder and create empty one
	rm -r -f $OUTPUT_DIR
	mkdir $OUTPUT_DIR
}

make_clean()
{
	echo -e "#2 - cleaning the source..."

	# jump to build path and make clean
	cd $KERNEL_DIR
	make clean
}

make_defconfig()
{
	echo -e "#3 - set kernelconfig"
	echo

  if [ -z "$DEFCONFIG" ]; then

    DEFCONFIG_DIR="arch/$ARCHITECTURE/configs"
    LIST_DEFCONFIGS=$(echo -e "$(ls arch/$ARCHITECTURE/configs)")

    echo "$LIST_DEFCONFIGS"
    echo
    echo "Select a kernelconfig"

    echo -n "Enter defconfig and press [ENTER]: "
    read defconfig
    echo

    make $defconfig

  fi
}

menuconfig()
{

  echo "Do you wish to make menuconfig?"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) make menuconfig; break;;
          No ) ;;
      esac
  done

}

compile()
{
	echo -e "compile"

	TIMESTAMP1=$(date +%s)

	# jump to build path
	cd $KERNEL_DIR
	# compile source
		make -j$NUM_CPUS  2>&1 |tee $OUTPUT_DIR/compile.log

	TIMESTAMP2=$(date +%s)

}

copy_kernel()
{
	echo -e "copy compiled kernel image"
  if [ -e "arch/$ARCHITECTURE/boot/$KERNEL_IMAGE" ]; then
    cp arch/$ARCHITECTURE/boot/$KERNEL_IMAGE $OUTPUT_DIR/
  fi
}

make_modules()
{
make INSTALL_MOD_PATH=$OUTPUT_DIR modules
make INSTALL_MOD_PATH=$OUTPUT_DIR modules_install
}

display_help()
{
	echo
	echo
	echo "Function menu"
	echo "======================================================================"
	echo
    echo "0  = show_greeter             |  = praise the script builder :)"
	echo "1  = make_output_dir          |  = create Output directory"
	echo "2  = make clean               |  "
	echo "3  = make config              |  = define a kernelconfiguration"
    echo "4  = make menuconfig          |  = make menuconfig"
	echo "5  = compile                  |  = compile the kernel"
    echo "6  = copy_kernel              |  = copy compiled kernel to Out"
    echo "7  = make_modules             |  = make and install .ko files to Out"
	echo
	echo "-a   = complete, execute steps 1-4"
	echo "-b   = clean the output dir &  the source, then compile"
	echo "-c   = only clean output dir & compile"
	echo
	echo "======================================================================"
	echo
	echo "Parameters:"
	echo "************"
	echo "Kernel source directory: $KERNEL_DIR"
	echo "Output directory: $OUTPUT_DIR"
    echo "Architecture: $ARCHITECTURE:"
    echo "Cross_compile toolchain: $TOOLCHAIN:"
    echo "Kernel name: $KERNEL_NAME"
    echo "CPU Cores to use: $NUM_CPUS"
    echo "Current CPU clock speed: $CPU_CLOCK"
    echo "Current CPU temperature: $CPU_TEMP"
    echo
	echo "======================================================================"
}

show_greeter()
{
	echo ""
	echo " ${bldred}     xNN's "
	echo " ${bldylw}	 ____  __.                         .__ ___.         .__.__       .__	"
	echo " ${bldylw}	|    |/ _|___________  ____   ____ |  |\_ |__  __ __|__|  |    __| _	"
	echo " ${bldylw}	|      <_/ __ \_  __ \/    \_/ __ \|  | | __ \|  |  \  |  |   / __ |	"
	echo " ${bldylw}	|    |  \  ___/|  | \/   |  \  ___/|  |_| \_\ \  |  /  |  |__/ /_/ |	"
	echo " ${bldylw}	|____|__ \___  >__|  |___|  /\___  >____/___  /____/|__|____/\____ |	"
	echo " ${bldylw}	        \/   \/           \/     \/         \/                    \/	"
	echo
	echo " ${bldylw}	${CPU} ${txtrst}"
    echo " ${bldylw}	Physical cores: ${CORES} ${txtrst}"
    echo " ${bldylw}	Current temp: ${CPU_TEMP} ${txtrst}"
    echo ""
    echo ""
}

###########################
##     MAIN FUNCTION     ##
###########################

case "$1" in
	-a)
     show_greeter
     make_output_dir
     make_clean
     make_defconfig
     menuconfig
     compile
     copy_kernel
     make_modules
     ;;
	-b)
    show_greeter
    make_output_dir
    make_clean
    compile
    copy_kernel
    make_modules
		;;
	-c)
    show_greeter
    make_output_dir
    compile
    copy_kernel
    make_modules
		;;
  0)
  	show_greeter
  	;;
	1)
		make_output_dir
		;;
	2)
		make_clean
		;;
	3)
		make_defconfig
		;;
  4)
  	menuconfig
  	;;
	5)
		compile
		;;
  6)
  	copy_kernel
  	;;
  7)
  	make_modules
  	;;
	-h)
		display_help
		;;
esac
