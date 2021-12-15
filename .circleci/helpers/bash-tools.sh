# Display a header in the UI.
#
# This will attempt to user Figlet to generate the header, otherwise it will
# fall back to a formatted ASCII header
#
# Parameters:
#     $1    => The header string to display
#
header () {
	figlet_bin=`which figlet`

	if [[ ! "$figlet_bin" == "" ]]; then
		figlet $1
	else
		echo
		echo "---------------------------------------------------------------------------------"
		echo "  $1"
		echo "---------------------------------------------------------------------------------"
		echo
	fi
}

headerline()
{
	echo
	echo "---------------------------------------------------------------------------------"
	echo "  $1"
	echo "---------------------------------------------------------------------------------"
	echo
}

array_2_env()
{
	array=$1
	export ARRAY_definition="$(declare -p array)"
}