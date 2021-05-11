# A script to install Ipopt and all of the linear models
# This script worked in Linux Mint 20.1
# Kernel 5.4.0-58-generic

# Note: HSL libraries are not included here! You need to get a license and unpack in the main directory!

# Variables
main_dir="$HOME/scratch" # This is the folder in /home/user/$main_dir where the files will be installed
ipopt_dir="ipopt" # The subdirectory with the ipopt install

# Update Apt
sudo apt-get update

# Ipopt dependencies (some may be redundant)
sudo apt-get install gcc g++ gfortran git patch wget pkg-config liblapack-dev libmetis-dev

# Make the main and ipopt directories
if ! [[ -d "$main_dir" ]]
then
  mkdir "$main_dir"
  mkdir "$main_dir/$ipopt_dir"
else
  if ! [[ -d "$main_dir/$ipopt_dir" ]]
  then
    mkdir "$main_dir/$ipopt_dir"
  fi
fi

# Move into the new ipopt directory
cd $main_dir/$ipopt_dir

# Download and make ASL
git clone https://github.com/coin-or-tools/ThirdParty-ASL.git
cd ThirdParty-ASL
./get.ASL
./configure
make
sudo make install

# Install BLAS and LAPACK - not needed if installed above
#./configure --with-lapack="-L$HOME/lib -lf77blas -lcblas -latlas"

# This assumes you have a folder 'coinhsl' in main_dir
if [[ -d "$main_dir/coinhsl" ]]
then
  mkdir $main_dir/$ipopt_dir/ThirdParty-HSL
  cp -r $main_dir/coinhsl  ~/$main_dir/$ipopt_dir/ThirdParty-HSL/
  cd $main_dir/$ipopt_dir/ThirdParty-HSL
  ./configure
  make
  sudo make install
else
  echo "No HSL libraries found"
fi

# Mumps
cd $main_dir/$ipopt_dir
git clone https://github.com/coin-or-tools/ThirdParty-Mumps.git
cd ThirdParty-Mumps
./get.Mumps
./configure
make
sudo make install

# Ipopt (Github latest version)
cd $main_dir/$ipopt_dir
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
ln -s "$main_dir/coinhsl/.libs/libcoinhsl.so" "$main_dir/coinhsl/.libs/libhsl.so"
echo "# Added by intall_ipopt.sh" >> $HOME/.bashrc
echo "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:$main_dir/coinhsl/.libs"\" >> $HOME/.bashrc

