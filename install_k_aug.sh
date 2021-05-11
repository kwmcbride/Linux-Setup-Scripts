# Script to install k_aug and add to PAth in .bashrc
# This script worked in Linux Mint 20.1
# Kernel 5.4.0-58-generic

# Variables - directories where you want to install k_aug
main_dir="$HOME/scratch"
sub_dir="k_aug_install"

# This is where you installed ASL
asl_install_dir="$HOME/scratch"
# This is where you installed HSL
hsl_install_dir="$HOME/scratch"
# This is where most libraries are found (don't change unless your set-up is different)
usr_dir="/usr/lib"

# The Github repo where k_aug is hosted
repo="https://github.com/dthierry/k_aug.git"

# Just incase this is not yet installed
#sudo apt-get update
sudo apt-get install cmake

# Manual dependency directory entry - not necessary unless the auto install doesn't work
# This is where your (1) asl.h, (2) getstub.h, and (3) arith.h files are located
dir_dep_1="" 
dir_dep_2="" 
dir_dep_3="" 

# Library packages
dir_asl=""
dir_hsl=""
dir_metis=""
dir_blas=""
dir_lapack=""
dir_gfortran=""

# Automatic dependency lookup - finds the directory of the latest version of the file
search_dir=$asl_install_dir
if ! [[ ${dir_dep_1} ]];
  then dir_dep_1="$(find $search_dir -name asl.h -printf '%h\n' | sort -d -r | head -n 1)"
fi
if ! [[ ${dir_dep_2} ]];
  then dir_dep_2="$(find $search_dir -name getstub.h -printf '%h\n' | sort -d -r | head -n 1)"
fi
if ! [[ ${dir_dep_3} ]];
  then dir_dep_3="$(find $search_dir -name arith.h -printf '%h\n' | sort -d -r | head -n 1)"
fi
if ! [[ ${dir_asl} ]];
  then dir_asl="$(find $search_dir -name libcoinasl.so -printf '%h\n' | sort -d -r | head -n 1)"
fi

search_dir=$hsl_install_dir
if ! [[ ${dir_hsl} ]];
  then dir_hsl="$(find $search_dir -name libcoinhsl.so -printf '%h\n' | sort -d -r | head -n 1)"
fi

search_dir=$usr_dir
if ! [[ ${dir_metis} ]];
  then dir_metis="$(find $search_dir -name libmetis.so -printf '%h\n' | sort -d -r | head -n 1)"
fi
if ! [[ ${dir_blas} ]];
  then dir_blas="$(find $search_dir -name libblas.so -printf '%h\n' | sort -d -r | head -n 1)"
fi
if ! [[ ${dir_lapack} ]];
  then dir_lapack="$(find $search_dir -name liblapack.so -printf '%h\n' | sort -d -r | head -n 1)"
fi
if ! [[ ${dir_gfortran} ]];
  then dir_gfortran="$(find $search_dir -name libgfortran.so -printf '%h\n' | sort -d -r | head -n 1)"
fi

# Make the scratch folder in the home directory
if ! [[ -d "$main_dir" ]]
then
   mkdir "$main_dir"
   mkdir "$main_dir/$sub_dir"
else
  if ! [[ -d "$main_dir/$sub_dir" ]]
  then
    mkdir "$main_dir/$sub_dir"
  else
    rm -rf "$main_dir/$sub_dir"
    mkdir "$main_dir/$sub_dir"
  fi
fi

cd $main_dir/$sub_dir

git clone $repo

# Change into correct directory
cd k_aug

# Incase you mess up
cp CMakeLists.txt CMakeLists-original.txt

# Change the ASL dependencies
echo "DEP: $dir_dep_1, $dir_dep_2, and $dir_dep_3 are being used for the ASL dependencies"
sed -i "s:include_directories(/usr/local/include/coin-or/asl ):include_directories(${dir_dep_1} ${dir_dep_2} ${dir_dep_3} ):g" CMakeLists.txt
  
# ASL
echo "ASL: $dir_asl is being used for the ASL library"
sed -i "s:find_library(COINASL NAMES asl \${libaslname} HINTS /usr/local/lib REQUIRED):find_library(COINASL NAMES asl \${libaslname} HINTS /usr/local/lib $dir_asl REQUIRED):g" CMakeLists.txt

# HSL
echo "HSL: $dir_hsl is being used for the HSL library"
sed -i "s:find_library(COINHSL NAMES \${libhslname} HINTS /usr/local/lib REQUIRED):find_library(COINHSL NAMES \${libhslname} HINTS /usr/local/lib $dir_hsl REQUIRED):g" CMakeLists.txt

# metis
echo "METIS: $dir_metis is being used for the Metis library"
sed -i "s:find_library(COINMETIS NAMES metis \${libmetisname} HINTS /usr/local/lib REQUIRED):find_library(COINMETIS NAMES metis \${libmetisname} HINTS /usr/local/lib $dir_metis REQUIRED):g" CMakeLists.txt

# blas
echo "BLAS: $dir_blas is being used for the BLAS library"
sed -i "s:find_library(BLAS NAMES blas \${libblasname} HINTS /usr/lib /usr/local/lib REQUIRED):find_library(BLAS NAMES blas \${libblasname} HINTS /usr/lib /usr/local/lib $dir_blas REQUIRED):g" CMakeLists.txt

# lapack
echo "LAPACK: $dir_lapack is being used for the LAPACK library"
sed -i "s:find_library(LAPACK NAMES lapack \${liblapackname} HINTS /usr/lib /usr/local/lib REQUIRED):find_library(LAPACK NAMES lapack \${liblapackname} HINTS /usr/lib /usr/local/lib $dir_lapack REQUIRED):g" CMakeLists.txt

# gfortran
echo "GFORTRAN: $dir_gfortran is being used for the GFortran library"
sed -i "s:find_library(GFORTRAN NAMES gfortran HINTS /usr/local/opt/gcc/lib/gcc/10 REQUIRED):find_library(GFORTRAN NAMES gfortran HINTS $dir_gfortran REQUIRED):g" CMakeLists.txt

# Make it all!
cmake CMakeLists.txt
make

# Add k_aug executable to path
echo "# Added by install_k_aug.sh" >> $HOME/.bashrc
echo "export PATH=\"\$PATH:$main_dir/$sub_dir/k_aug/bin"\" >> $HOME/.bashrc
# Done!
