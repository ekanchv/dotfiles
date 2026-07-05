# Additional setup instructions
## Python notebooks
### Molten
- Create virtual environment in `~/.virtualenvs/neovim` and install
```{bash}
pip install pynvim jupyter_client cairosvg plotly kaleido pnglatex pyperclip
```

- install and register ipykernel in local venv
```{bash}
python -m pip install ipykernel jupyter-console
python -m ipykernel install --user --name=myenv --display-name="My Env"
```

### Quarto
- install quarto
```{bash}
cd ~/Downloads
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.38/quarto-1.9.38-linux-amd64.deb
sudo apt install ./quarto-1.9.38-linux-amd64.deb
```

## Markdown
### ASCII latex
```{bash}
# tools
sudo apt install build-essential autoconf automake libtool
mkdir -p /tmp/build
cd /tmp/build
git clone https://github.com/bartp5/libtexprintf.git
./configure
make
sudo make install

# test installation
sudo ldconfig
utftex 'frac{a}{b}'
```
