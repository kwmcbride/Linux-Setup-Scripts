# Script to install k_aug and add to PAth in .bashrc
# This script worked in Linux Mint 20.1
# Kernel 5.4.0-58-generic

# Variables - directories where you want to install k_aug
main_dir="$HOME/scratch"
sub_dir="k_aug_install"

# The Github repo where k_aug is hosted
repo="https://github.com/dthierry/k_aug.git"

# Just incase this is not yet installed
#sudo apt-get update
sudo apt-get install cmake

# This is where your asl.h and getstub.h files are located (line 93)
asl_dir="$HOME/scratch/test_ipopt/ThirdParty-ASL/solvers"
# This may be necessary for other files (for example arith.h is here)
extra_dir="$HOME/scratch/test_ipopt/ThirdParty-ASL"

# Here are the directories for the various dependencies - change these to your settings!
dir_libcoinasl="$HOME/scratch/test_ipopt/ThirdParty-ASL/.lib"
dir_libcoinhsl=""
dir_libmetis="/usr/lib/x86_64-linux-gnu"
dir_blas="/usr/lib/x86_64-linux-gnu/blas"
dir_lapack="/usr/lib/x86_64-linux-gnu/lapack"
dir_gfortran="/usr/lib/gcc/x86_64-linux-gnu/9"

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

# This section adds all the directories entered at the top of the file

# Change the ASL dependencies
if [ -z "$asl_dir" ]
then
  echo "\$asl_dir is empty and defaults /usr/local/include/coin-or/asl is being used"
else
  echo "$asl_dir is being used for the ASL libraries"
  sed -i "s:include_directories(/usr/local/include/coin-or/asl ):include_directories(${asl_dir} ${extra_dir} ):g" CMakeLists.txt
fi

# ASL
if [ -z "$dir_libcoinasl" ]
then
  echo "\$dir_libcoinasl is empty and default is being used"
else
  echo "$dir_libcoinasl is being used"
  sed -i "s:find_library(COINASL NAMES asl \${libaslname} HINTS /usr/local/lib REQUIRED):find_library(COINASL NAMES asl \${libaslname} HINTS /usr/local/lib $dir_libcoinasl REQUIRED):g" CMakeLists.txt
fi

# HSL
if [ -z "$dir_libcoinhsl" ]
then
  echo "\$dir_libcoinhsl is empty and default is being used"
else
  echo "$dir_libcoinhsl is being used"
  sed -i "s:find_library(COINHSL NAMES \${libhslname} HINTS /usr/local/lib REQUIRED):find_library(COINHSL NAMES ${libhslname} HINTS /usr/local/lib $dir_libcoinhsl REQUIRED):g" CMakeLists.txt
fi

# metis
if [ -z "$dir_libmetis" ]
then
  echo "\$dir_libmetis is empty and defaults /usr/local/lib is being used"
else
  echo "$dir_libmetis is being used for the ASL libraries"
  sed -i "s:find_library(COINMETIS NAMES metis \${libmetisname} HINTS /usr/local/lib REQUIRED):find_library(COINMETIS NAMES metis \${libmetisname} HINTS /usr/local/lib $dir_libmetis REQUIRED):g" CMakeLists.txt
fi

# blas
if [ -z "$dir_blas" ]
then
  echo "\$dir_blas is empty and default is being used"
else
  echo "$dir_blas is being used"
  sed -i "s:find_library(BLAS NAMES blas \${libblasname} HINTS /usr/lib /usr/local/lib REQUIRED):find_library(BLAS NAMES blas \${libblasname} HINTS /usr/lib /usr/local/lib $dir_blas REQUIRED):g" CMakeLists.txt
fi

# lapack
if [ -z "$dir_lapack" ]
then
  echo "\$dir_lapack is empty and default is being used"
else
  echo "$dir_lapack is being used"
  sed -i "s:find_library(LAPACK NAMES lapack \${liblapackname} HINTS /usr/lib /usr/local/lib REQUIRED):find_library(LAPACK NAMES lapack \${liblapackname} HINTS /usr/lib /usr/local/lib $dir_lapack REQUIRED):g" CMakeLists.txt
fi

# lapack
if [ -z "$dir_gfortran" ]
then
  echo "$dir_gfortran is empty and default is being used"
else
  echo "$dir_gfortran is being used"
  sed -i "s:find_library(GFORTRAN NAMES gfortran HINTS /usr/local/opt/gcc/lib/gcc/10 REQUIRED):find_library(GFORTRAN NAMES gfortran HINTS $dir_gfortran REQUIRED):g" CMakeLists.txt
fi

# Make it all!
cmake CMakeLists.txt
make

# Add k_aug executable to path
echo "# Added by install_k_aug.sh" >> $HOME/.bashrc
echo "export PATH=\"\$PATH:$main_dir/$sub_dir/k_aug/bin"\" >> $HOME/.bashrc
# Done!
