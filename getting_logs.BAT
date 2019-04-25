@echo off
set back=%cd%
for /D %%i in (D:\DS6020\repos\*) do (
cd "%%i"
git log --name-status --pretty=format:"%%an,%%at,%%cn,%%ct" >> %%i.list
)
cd %back%

