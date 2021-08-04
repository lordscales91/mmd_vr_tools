set +H
echo Launching Python script "$1"
python3 "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
read -n 1 -s -r -p "Press any key to continue"