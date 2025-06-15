@echo off
echo Teams Clone Signaling Server Launcher

REM Check if node_modules exists
if not exist "node_modules\" (
    echo Installing dependencies...
    call npm install
)

echo Starting Teams Clone Signaling Server...
call npm run dev 