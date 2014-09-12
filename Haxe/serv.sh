
until false
do
	echo "Server started..."
	haxe --wait 6000
	echo "Server crashed with exit code $?. Respawning..."
	sleep 1
done