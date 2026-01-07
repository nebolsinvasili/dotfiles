pwd_dir="$PWD"
echo "$pwd_dir"

mkdir -p $HOME/repo && cd $HOME/repo
git clone https://github.com/nebolsinvasili/tmux.git && cd ./tmux && ./install.sh && cd ..
git clone https://github.com/nebolsinvasili/ranger.git && cd ./ranger && ./install.sh && cd ..
git clone https://github.com/nebolsinvasili/neovim.git && cd ./neovim && ./install.sh && cd ..

cd "$pwd_dir"
