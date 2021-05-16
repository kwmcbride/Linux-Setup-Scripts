# Script to install k_aug and add to PATH in .bashrc
# This script worked using MacOS Big Sur with the M1 chip

# Variables - directories where you want to install k_aug
main_dir="$HOME/scratch"
sub_dir="k_aug_install"

# This is where you installed ASL
asl_install_dir="$HOME/scratch"
# This is where you installed HSL
hsl_install_dir="$HOME/scratch"
# This is where most libraries are found (don't change unless your set-up is different)
usr_dir="/usr/local"

#Option to print stuff out (0 or 1)
verbose=1

# The Github repo where k_aug is hosted
repo="https://github.com/dthierry/k_aug.git"

# Just incase this is not yet installed
#sudo apt-get update

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
function find_dir()
{
    local  __resultvar=$1
    if ! [[ ${!__resultvar} ]]; then
        eval $__resultvar="$(find $2 -name $3 | sort -d -r | head -n 1 | xargs dirname)"
    else
		echo "not working"
    fi
}

lib_name='dylib'

search_dir=$usr_dir
find_dir dir_dep_1 $search_dir "asl.h"
find_dir dir_dep_2 $search_dir "getstub.h"
find_dir dir_dep_3 $search_dir "arith.h"
find_dir dir_asl $search_dir "libcoinasl.$lib_name"

search_dir=$usr_dir
find_dir dir_hsl $search_dir "libcoinhsl.$lib_name"

search_dir=$usr_dir
find_dir dir_metis $search_dir "libmetis.$lib_name"
find_dir dir_blas $search_dir "libblas.$lib_name"
find_dir dir_lapack $search_dir "liblapack.$lib_name"
find_dir dir_gfortran $search_dir "libgfortran.$lib_name"

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
sed -i '' "s:include_directories(/usr/local/include/coin-or/asl ):include_directories(${dir_dep_1} ${dir_dep_2} ${dir_dep_3} ):g" CMakeLists.txt
  
# ASL
echo "ASL: $dir_asl is being used for the ASL library"
sed -i '' "s:find_library(COINASL NAMES asl \${libaslname} HINTS /usr/local/lib REQUIRED):find_library(COINASL NAMES asl \${libaslname} HINTS /usr/local/lib $dir_asl REQUIRED):g" CMakeLists.txt

# HSL
echo "HSL: $dir_hsl is being used for the HSL library"
sed -i '' "s:find_library(COINHSL NAMES \${libhslname} HINTS /usr/local/lib REQUIRED):find_library(COINHSL NAMES \${libhslname} HINTS /usr/local/lib $dir_hsl REQUIRED):g" CMakeLists.txt

# metis
echo "METIS: $dir_metis is being used for the Metis library"
sed -i '' "s:find_library(COINMETIS NAMES metis \${libmetisname} HINTS /usr/local/lib REQUIRED):find_library(COINMETIS NAMES metis \${libmetisname} HINTS /usr/local/lib $dir_metis REQUIRED):g" CMakeLists.txt

# blas
echo "BLAS: $dir_blas is being used for the BLAS library"
sed -i '' "s:find_library(BLAS NAMES blas \${libblasname} HINTS /usr/lib /usr/local/lib REQUIRED):find_library(BLAS NAMES blas \${libblasname} HINTS /usr/lib /usr/local/lib $dir_blas REQUIRED):g" CMakeLists.txt

# lapack
echo "LAPACK: $dir_lapack is being used for the LAPACK library"
sed -i '' "s:find_library(LAPACK NAMES lapack \${liblapackname} HINTS /usr/lib /usr/local/lib REQUIRED):find_library(LAPACK NAMES lapack \${liblapackname} HINTS /usr/lib /usr/local/lib $dir_lapack REQUIRED):g" CMakeLists.txt

# gfortran
echo "GFORTRAN: $dir_gfortran is being used for the GFortran library"
sed -i '' "s:find_library(GFORTRAN NAMES gfortran HINTS /usr/local/opt/gcc/lib/gcc/10 REQUIRED):find_library(GFORTRAN NAMES gfortran HINTS $dir_gfortran REQUIRED):g" CMakeLists.txt

# verbosity update
sed -i '' "s:set(PRINT_VERBOSE 0):set(PRINT_VERBOSE $verbose):g" CMakeLists.txt

# Make it all!
cmake CMakeLists.txt
make

# Add k_aug executable to path
echo "# Added by install_k_aug.sh" >> $HOME/.bashrc
echo "export PATH=\"\$PATH:$main_dir/$sub_dir/k_aug/bin"\" >> $HOME/.bashrc
# Done!
