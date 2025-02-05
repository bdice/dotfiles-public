rem Set up conda environment with desired packages

rem set GLOTZER_PKGS="hoomd freud signac signac-flow gsd fresnel"
set "SCIPY_PKGS=python=3.9 numpy pandas scipy matplotlib sympy seaborn statsmodels tqdm cython"
set "ML_PKGS=scikit-learn networkx"
set "NB_PKGS=ipython ipykernel jupyterlab pythreejs"
set "DOC_PKGS=sphinx sphinx_rtd_theme nbsphinx jupyter_sphinx sphinxcontrib-bibtex"
set "DEV_PKGS=deprecation flake8 autopep8 black isort pre-commit nose ddt tbb tbb-devel coverage h5py ripgrep pytest pydocstyle pylint rope jupyterlab_code_formatter scikit-build"
set "SIGNAC_PKGS=pytables filelock click ruamel.yaml pytest-subtests coverage pytest-cov pymongo"
set "ALL_PKGS=%SCIPY_PKGS% %ML_PKGS% %NB_PKGS% %DOC_PKGS% %DEV_PKGS% %SIGNAC_PKGS%"

rem Set up channels
cmd /C conda config --add channels conda-forge

if not exist "%USERPROFILE%\mambaforge\envs\dice" (
echo "Creating conda environment."
cmd /C conda create --yes --name dice
)

rem cmd /C conda install %ALL_PKGS%
cmd /C conda install --name dice %ALL_PKGS%
