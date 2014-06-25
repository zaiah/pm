#------------------------------------------------------
# alias_file.sh 
#
# Generates an alias file.
#-----------------------------------------------------#

# List of colors.
COLORS=(
green
red
purple
orange
brown
black
white
gray
blue
)

# Set a random integer.
num=$RANDOM
let "num %= ${#COLORS[@]}"

# Spit out a list.
generate_alias_file() {
	cat << EOF
# Include regular Bash settings.
source $HOME/.bashrc

# Project file.
color=${COLORS[$num]}
terms=2
shade=10
px=11

# Project-specific aliases.
alias reload=\"source $ALIAS_DIR/${PROJECT_NAME}.sh\"

# Project-specific directories. 
home=\"$PROJECT_DIR\"
EOF
}

