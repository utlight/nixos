tpdev() {
	case "$1" in
	up)
		vpncmd localhost /CLIENT /CMD AccountConnect tpdev
		;;
	down)
		vpncmd localhost /CLIENT /CMD AccountDisconnect tpdev
		;;
	*)
		echo "Usage: tpdev up|down" >&2
		return 1
		;;
	esac
}
