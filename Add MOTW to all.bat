cd /d "%~dp0"
powershell -c "dir | foreach { echo '[ZoneTransfer]' 'ZoneId=3' | set-content ( '.\' + $_.name + ':Zone.Identifier' ) }"