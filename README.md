# Bradley's Dotfiles

## Linux/Mac Setup

```bash
mkdir -p $HOME/code
cd $HOME/code
git clone --recurse-submodules git@github.com:bdice/dotfiles-public.git
cd dotfiles-public
bash bootstrap.sh
```

## Windows Setup

```batch
mkdir %USERPROFILE%\code
cd %USERPROFILE%\code
git clone --recurse-submodules git@github.com:bdice/dotfiles-public.git
cd dotfiles-public
```

Then install Miniconda:

```batch
cd %USERPROFILE%\code\dotfiles-public\windows
install-miniconda.bat
```

Then restart the shell and run:

```batch
cd %USERPROFILE%\code\dotfiles-public
bootstrap.bat
```
