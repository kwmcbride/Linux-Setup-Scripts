#!/bin/bash

default_install_dir="scratch/ipopt"
# This function installs the required dependencies for Ipopt
function install_dependencies()
{
   # Update apt-get
   sudo apt-get update
   # Ipopt dependencies (some may be redundant)
   sudo apt-get install gcc g++ gfortran git patch wget pkg-config liblapack-dev libmetis-dev
}

function coinhsl_directory()
{
    _coin_tar_dir=${coin_tar_dir:-"$HOME/scratch"}
    
    if [[ "${_coin_tar_dir:0:1}" == '/' ]];
    then 
      tar_dir=$_coin_tar_dir
    else
      tar_dir="$HOME/$_coin_tar_dir"
    fi
  
  	echo $tar_dir
	#The zipped tarball should be in the main directory (where it should be for installation)
    coin_dir="coinhsl"
    FILE=$(find $tar_dir -name "coinhsl-*.tar.gz")
	# Just to make sure
	is_tar=$(file $FILE | grep -q 'gzip compressed data' && echo 1 || echo 0)

	echo $FILE

    if [ $is_tar == 1 ];
		then
		# extract and rename the directory to coinhsl, which Ipopt is expecting
		tar xvzf $FILE
		mv coinhsl-*/ $coin_dir
	fi
}

# Sets up the installation directory
function set_up_directory()
{    
    # Set defualt path if not provided
    install_dir=${1:-"$default_install_dir"}
    
    if [[ "${install_dir:0:1}" == '/' ]];
    then 
      main_dir=$install_dir
    else
      main_dir="$HOME/$install_dir"
    fi
    
    echo "The installation directory is $main_dir"
}

# Finds the directory of a given library (to see if they exist, primarily)
function find_dir()
{
    local  __resultvar=$1
    if ! [[ ${!__resultvar} ]]; then
        eval $__resultvar="$(find $2 -name $3 -printf '%h\n' | sort -d -r | head -n 1)"
    fi
}

# Install a linear algebra package
function install_package()
{
    cd $main_dir
	echo "Cloning into the following repository: $1"
	local url=$1
	git_file=${url##*/}
	git_file_name=${git_file%%.*}
	git_name="get.${git_file_name##*-}"
	# Remove the old directory - perhaps just check and move on?
	if [[ -d "./$get_file_name" ]]
	then
	    echo "Directory already exists"
	else
	    echo "Direcrtory does not exist, cloning into repo..."
	    git clone $1
	    #rm -rf "$_get_file_name"
	fi
   
    # Make sure HSL doesn't get through - this will not happen though
	if ! [ "$get_name" == "HSL" ]; then
	  cd $main_dir/$git_file_name
	  ./$git_name
	fi
	cd $main_dir/$git_file_name
	./configure
	make
	sudo make install
}

# Core function to install Ipopt
function install_ipopt()
{
    _has_ipopt=$(which ipopt)
    if [[ -x "$_has_ipopt" ]];
        then
        echo "Ipopt already installed, exiting installation"
        echo "Please remove current installed ipopt executable and restart"
        exit 1
    else
        main_dir=${main_dir:-"$default_install_dir"}
    	# Make the main and ipopt directories
		if ! [[ -d "$main_dir" ]]
		then
		  mkdir -p "$main_dir"
		fi
		# Move into the new ipopt directory
		cd $main_dir
    
	 	_has_asl=""
		_has_hsl=""
		_has_mumps=""

		search_dir="/usr"

		find_dir _has_asl $search_dir "libcoinasl.so"
		find_dir _has_mumps $search_dir "libcoinmumps.so"
		find_dir _has_hsl $search_dir "libcoinhsl.so"

		package="ASL"
		if [ $_has_asl ]
		then 
		  echo "$package shared objects found: $_has_asl"
		else
		  echo "$package shared objects not found: installing now..."
		  install_package "https://github.com/coin-or-tools/ThirdParty-$package.git"
		fi

		package="Mumps"
		if [ $_has_mumps ]
		then 
		  echo "$package shared objects found: $_has_mumps"
		else
		  echo "$package shared objects not found: installing now..."
		  install_package "https://github.com/coin-or-tools/ThirdParty-$package.git"
		fi

		package="HSL"
		if [ $_has_hsl ]
		then 
		  echo "$package shared objects found: $_has_hsl"
		else
		  echo "$package shared objects not found: installing now..."
		  
		  coinhsl_directory
		  echo "moved stuff"
		  echo $main_dir
		  # Install HSL libraries
		  if [[ -d "$main_dir/coinhsl" ]]
			then
			  mkdir -p $main_dir/ThirdParty-HSL
			  mv $main_dir/coinhsl  $main_dir/ThirdParty-HSL/
			  cd $main_dir/ThirdParty-HSL/coinhsl
			  ./configure
			  make
			  sudo make install
			else
			  echo "No HSL libraries found"
		  fi
		fi

		# Ipopt (Github latest version)
		cd $main_dir
		git clone https://github.com/coin-or/Ipopt.git
		cd Ipopt
		mkdir build && cd build
		../configure
		make
		make test
		sudo make install

		# You need this archive in order to find libgfortran3, which is required for Ipopt
		sudo bash -c "echo 'deb http://gb.archive.ubuntu.com/ubuntu bionic main universe' >> /etc/apt/sources.list"
		sudo apt-get install libgfortran3

		# Add libhsl.so to PATH - it is unfortunate that this is the way...
		ln -s "$main_dir/ThirdParty-HSL/coinhsl/.libs/libcoinhsl.so" "$main_dir/ThirdParty-HSL/coinhsl/.libs/libhsl.so"
		echo "# Added by intall_ipopt.sh" >> $HOME/.bashrc
		echo "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:$main_dir/ThirdParty-HSL/coinhsl/.libs"\" >> $HOME/.bashrc
    fi
}

# Option control
while getopts "p:d:c:" arg; do
  case $arg in
    # Installation path 
    p) install_dir_arg=$OPTARG;;
    # Option to install the required dependencies
    d) install_dependencies;;
    # Provide the path to the coinhsl tar ball
    c) coin_tar_dir=$OPTARG;;
  esac
done

set_up_directory $install_dir_arg
install_ipopt

