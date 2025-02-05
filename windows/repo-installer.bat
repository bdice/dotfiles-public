if exist "%USERPROFILE%\code" (
for /F "delims=" %%R in (repos.txt) do git clone --recurse-submodules git@github.com:glotzerlab/%%R.git "%USERPROFILE%\code\%%R"
) else (
echo "code directory does not exist"
)
