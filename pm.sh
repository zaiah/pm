#!/bin/bash -
#===============================================
#
#  FILE:  			pm.sh
#  USAGE:  			./pm.sh [name-of-project]
#  DESCRIPTION:  	A project manager.
#  REQUIREMENTS: 
#  BUGS:  ---
#  NOTES:  ---
#  AUTHOR:  
#   Antonio Ramar Collins II, 
#	 ramar.collins@gmail.com, 
#   zaiah.dj@gmail.com
#  COMPANY:  Vokayent (vokayent@gmail.com) 
#  VERSION:  1.0
#  CREATED:  04/03/2013 09:09:33 PM EDT
#  REVISION:  ---
#
# USE `tput` to change terminal backgrounds on
# the fly.
#================================================

# Constants
IFS=' 
'

# Get the settings.
BINDIR="$(dirname "$(readlink -f $0)")"
source "$BINDIR/files/__config.sh"


#########################
# Usage message.
#########################
__USAGE_MSG="
Usage: ./project 
		[ help | -h | --help ] 
		[ global | add-function | edit-function | remove-function ] 
		[ show N ]
		[ -cknor ] [ -t N ] <project-name>

Options:
--first-run           Run for the first time.
--setup               Setup globals.
--install <dir>       Install $PROGRAM to <dir>.
--uninstall           Uninstalls $PROGRAM according to user logged in.
--as <user>           Run this as a particular user. 
-d | --editor         Set an editor when trying to configure.
-f | --hooks          Edit hooks for a certain project.
-p | --progress       Get the progress of a project.  (May use curses)
-m | 
 --file-manager <prg> Use <prg> as a file manager for this project.
-t | --terminals <N>  Use <N> terminals when opening or configuring a 
                      project.
-c | 
 --configure <name>   Configure project referenced by <name>.
-l | --list           List all projects.
-? | --last           List what we were last doing.
-k | --kill <name>    Kill all open instances of project <name>.
-s | --spawn <int>    Open <int> number of terminal windows.
-n | --new <name>     Create a new project called <name>.
-r | --remove <name>  Remove project referenced by <name>.
-o | --open <name>    Open project referenced by <name>.
-u | 
 --unregister <name>  Remove project referenced by <name> from $PROGRAM's
                      database.
-g | 
 --register <name>    Add some project to $PROGRAM's database.
-a | --at <dir>       Create the project at <dir>
-v | --verbose        Be verbose in output.
"


# __insert_new_record
# 	Makes a new database record while checking to see if it exists already.
__insert_new_record() {
	# Grab a senisible record.
	GET_RECORD="$( $__SQLITE $__DB "SELECT 
project_name 
FROM project_description
WHERE
project_name = '$PROJECT_NAME'")"

	# Add our stuff.
	if [ -z "$GET_RECORD" ] 
	then
		__TABLE="project_description"
		__ADD "NULL,'$PROJECT_NAME', '${PROJECT_DESC-""}', '${PROJECT_DIR}', $(date +%s), $(date +%s), '${USER_NAME}'"

	# Fail if not.
	else
		echo "Project: $PROJECT_NAME already exists."
		echo "You may either remove the project entirely" 
		echo " or name it something entirely different."
		usage 1
	fi
}


# install
# 	Install program.
install_all() {
	# Install globally. 
	if [ ! -z "$INSTALL_DIR" ]
	then
	  GET_OLD_INSTALL_DIR="$($__SQLITE $__DB "SELECT exec_dir FROM
  settings
  WHERE
  user_added = '${USER_NAME}'")"

	  # Add to the table.
	  if [ -z "$GET_OLD_INSTALL_DIR" ] 
	  then
		  __TABLE="settings"	
		  __UPDATE "exec_dir = '$INSTALL_DIR'" \
			  "user_added = '${USER_NAME}'"

	  # Update the table.
	  else
		  __TABLE="settings"	
		  __UPDATE "exec_dir = '$INSTALL_DIR'" \
			  "user_added = '${USER_NAME}'"
	  fi

	  # Link.
	  [ ! -z $VERBOSE ] && LNFLAGS="-sv" || LNFLAGS="-s"
	  [ ! -z $VERBOSE ] && echo "Installing $PROGRAM to $INSTALL_DIR..."
	  ln $LNFLAGS "$BINDIR/${PROGRAM}.sh" "$INSTALL_DIR/${PROGRAM}"

	# Die if no install directory supplied.
	else
	 	echo "The --install flag must have a directory name specified on the command line.  Try something like the following:"
		echo "./pm --install $HOME/bin"
		usage 1 
	fi
}


# uninstall
#  Uninstall it...
uninstall() {
	# Set flags.
	[ ! -z $VERBOSE ] && RMFLAGS="-fv" || RMFLAGS="-f"

	GET_OLD_INSTALL_DIR="$($__SQLITE $__DB "SELECT exec_dir FROM
	  settings
	  WHERE
	  user_added = '${USER_NAME}'")"

	# Remove per our results.
	if [ ! -z "$GET_OLD_INSTALL_DIR" ]
	then	
  		__TABLE="settings"	
  		__UPDATE "exec_dir = ''" \
	  		"user_added = '${USER_NAME}'"
		rm $RMFLAGS "${GET_OLD_INSTALL_DIR}/${PROGRAM}"
	fi
}


# make_new_project 
# 	Create project.
make_new_project() {
	# Check for a project directory.
	if [ -z "$PROJECT_DIR" ]
	then
		echo "No project directory supplied."
		echo "Try the --at flag?"
		usage 1

	else	 
		# Set different flags.
		[ ! -z $VERBOSE ] && MKDIRFLAGS="-pv" || MKDIRFLAGS="-p"

		# Check for duplicate dir and entry names in project_db
		__insert_new_record		# Should die if something is in the system.
	
		# Prepare and create project directory.
		mkdir $MKDIRFLAGS $PROJECT_DIR;

		# Run hooks at project initialization.
		# Configure outside of this funciton.
		[ ! -z "$HOOKS" ] && __run_hooks
		
		# Set up terminal settings. 
		# Move to the database eventually.
		ALIAS_FILE="$ALIAS_DIR/${PROJECT_NAME}.sh" 
		if [ ! -f "$ALIAS_FILE" ]
		then
			echo "source $HOME/.bashrc

# Special parameters for urxvt
# 
# Available colors are:
# green, red, purple, orange, brown, black, white, gray, blue
# 
# Also can try #hexShades!
color=green
terms=2
shade=30
px=11

# Project-specific aliases.
alias reload=\"source $ALIAS_DIR/${PROJECT_NAME}.sh\"

# Project-specific directories. 
home=\"$PROJECT_DIR\"
	" >> $ALIAS_FILE
		fi
	fi
}


# Kill all project windows.
killwindows() {
	# Get all task IDs and kill them.
	# I always get file errors here...
	# so let's consider using the db for this...
	{ while read id; do kill -9 $id; done } < $project_dir/.processes 
}


# Run the hooks.
__run_hooks() {
	# Load each file we asked for but don't run the code yet.
	for EACH_HOOK in ${HOOKS[@]}
	do 
		[ ! -z "$VERBOSE" ] && echo "Including"
		[ -f "$EACH_HOOK" ] && source "${HOOKS_DIR}/${EACH_HOOK}.sh"
	done 
}


# Integrate some project.
integrate_project() {
	# Get install directory.
	if [ -z "$PROJECT_DIR" ]; then
		echo "To integrate a new project, you must specify a directory for"
		echo " the install directory with the --at flag."
		usage 1

	# Insert a record.
	else
		__insert_new_record
		[ ! -z "$HOOKS" ] && __run_hooks
	fi
}


# Open a project using Urxvt.
spawn() {
	if [ ! -z "$PROJECT_NAME" ] 
	then
		# Load project settings.
		WHERE_CLAUSE="WHERE project_name = '$PROJECT_NAME' AND who_added = '$USER_NAME'"
		PROJECT_DIR=$($__SQLITE $__DB "SELECT project_dir FROM project_description $WHERE_CLAUSE;")

		# Load your term settings. (These can go in another file.)
		ALIAS_FILE=$ALIAS_DIR/${PROJECT_NAME}.sh
		if [ -f "$ALIAS_FILE" ] 
		then
			source $ALIAS_DIR/${PROJECT_NAME}.sh 
		else
			printf "No project: ${PROJECT_NAME} name found.\n" 
			printf "Perhaps create a new one with pm --new?\n" 
			exit 1
		fi
	
		cd $PROJECT_DIR

		# Open a f/m with your project.
		#if [ ! -z $mgr ]; then
		#	$file_manager $USERDIR;
		#fi
		
		# Run any commands relevant to your project.
		#chmod a+x ${USERDIR}/.run.sh
		#${USERDIR}/.run.sh

		# Check that we actually found a project.
		if [ ! -z $PROJECT_DIR ] || [[ "$PROJECT_DIR" =~ "" ]]
		then
			# Set defaults.
			terminalEmulator=${terminalEmulator-'urxvt'}
			TERM_NUMBER=${TERM_NUMBER-2}
			font=${font-"Bitstream Vera Sans Mono"}
			px=${px-12}
			color=${color-"purple"}
			shade=${shade-20}

			# Open your project in terminal of choice. (urxvt is standard)	
			EMULATOR="urxvt"
			for iterations in `seq 1 $TERM_NUMBER`
			do 
				{
				$EMULATOR -fn "xft:$font:pixelsize=$px" \
				-depth 32 -bg "[$shade]$color" -fg white \
				-g 80x50 -tr -sh $shade -sr \
				-title "$PROJECT_NAME" -e bash --rcfile $ALIAS_DIR/${PROJECT_NAME}.sh
			} &
		#		echo $! >> $USERDIR/.processes
			done
		fi

		# Update modified date.
		$__SQLITE $__DB "UPDATE project_description SET date_last_updated = $(date +%s) $WHERE_CLAUSE" 

	#	# Record process ID's.
	#	for xpid in $(ps aux |\
	#		grep 'urxvt' |\
	#		grep 'title v' |\
	#		awk '{print $2}')
	#	do
	#		echo $xpid >> $project_dir/.processes
	#	done
	#
		# Return status.
		exit 0
	fi
}


# open 
#  Open a new project within some terminal window or via screen.
open () {
	echo "open"
}


# unregister
#  Remove all record of a project in the database.  
unregister() {
	# Remove database record.
	$__SQLITE $__DB "DELETE FROM project_description WHERE project_name = '$PROJECT_NAME';" 
} 


# remove
#		Remove a project from the database and the filesystem.
remove() {
	# Verbose
	[ ! -z $VERBOSE ] && RMFLAGS="-rfv" || RMFLAGS="-rf"

	# Remove alias file
	[ -f "$ALIAS_DIR/${PROJECT_NAME}.sh" ] && rm $RMFLAGS $ALIAS_DIR/${PROJECT_NAME}.sh		

	# Remove project dir.
	PROJECT_DIR="$( $__SQLITE $__DB "SELECT project_dir FROM project_description WHERE project_name = '$PROJECT_NAME';" )"
	[ -d "$PROJECT_DIR" ] && rm $RMFLAGS $PROJECT_DIR

	# Unregister the project.
	unregister
}


# list_all_projects
#		List all projects stored by $PROGRAM.
list_all_projects() {
	echo '...'
}

#########################
# Evaluate options.
#########################
[ -z "$BASH_ARGV" ] && usage 1 "Nothing to do."
while [ $# -gt 0 ]
do
case "$1" in
	# Install for the first time.
	--first-run)
		FIRST_RUN=true
	;;

	# Setup global variables and whatnot.
	--setup)
		SETUP=true
	;;

	--as)
		shift
		USERNAME="$1"
	;;

	# Install systemwide.
	-i | --install)  
		INSTALL=true
		shift
		INSTALL_DIR="$1"
	;;

	# Uninstall systemwide.
	--uninstall)
		UNINSTALL=true
	;;

	# Setup or open a project with $TERMS number of terminals.
	-e | --editor)
		shift
		EDITOR="$1"
	;;

	# Configure hooks from here.  Split by -f.	
	-f | --hooks)
		shift
		if [ -z "$HOOKS" ]
		then
			declare -a HOOKS
			HOOKS=( "$1" )
		else
			HOOKS[${#HOOKS[@]}]="$1"
		fi
	;;

	# Setup or open a project with $TERMS number of terminals.
	-m | --file-manager)
		USE_MGR=true 
		shift
		MGR_EXEC="$(which $1)"
		if [ ! -z "$MGR_EXEC" ]
		then
			FILE_MGR="$MGR_EXEC"
		fi	
	;;

	# Mass import
	--mass-import)
		DO_MASS_IMPORT=true
		shift
		MASS_IMPORT_DIR="$1"
	;;

	# Setup or open a project with $TERMS number of terminals.
	-t | --terminals)
		TERMCOUNT=true
		shift
		TERMS=$1  			
	;;
	
	# Set a duration.
	-d | --from)
		shift
		DURATION="$1"
	;;

	# Configure a project.
	-c | --configure) 	
		CONFIGURE=true
		shift
		PROJECT_NAME="$1"
	;;

	# Projects
	-p | --progress)
		GET_PROGRESS=true
		shift
		PROJECT_NAME="$1"
	;;

	# Get information on all the projects in the database.
	-l | --list)
		LIST_ALL=true
	;;

	# Get information on all the projects in the database.
	-? | --last)
		GET_LAST=true
		# Auto chooses last 10.
		shift
		if [[ $1 = [0-9] ]]
		then
			LAST_LIMIT=$1
		fi
	;;

	# Kill a project (if there are many windows)
	-k | --kill)			
		KILL_WINDOWS=true
		shift
		PROJECT_NAME="$1"	
	;;

	# Make a new project.
	-n|--new)
		MAKE_NEW_PROJECT=true
		shift
		PROJECT_NAME="$1"	
	;;

	# Open a project.
	-o | --open)
		OPEN_PROJECT=true
		shift
		PROJECT_NAME="$1"	
	;;

	# Remove a project entirely.
	-r | --remove)
		REMOVE_PROJECT=true
		shift
		PROJECT_NAME="$1"	
	;;	

	# Remove a project entirely.
	-u | --unregister)
		UNREGISTER_PROJECT=true
		shift
		PROJECT_NAME="$1"	
	;;	

	# Make pm aware of a project's existence.
	-g | --register)
		INTEGRATE_PROJECT=true
		shift
		PROJECT_NAME="$1"	
	;;	

	# Create a new terminal window.
	-s | --spawn)
		SPAWN=true
		OPEN_PROJECT=true
		
		# Catch next argument if a number.
		if [[ $2 =~ [0-9] ]]
		then 
			shift
			TERM_NUMBER="$1"

		# Break because we've hit an option.
		elif [[ $2 =~ '--' ]]
		then
			echo "Usage: ./$PROGRAM --spawn expects a numerical argument."
			exit 1	
		fi	
	;;

	# Let pm know to set up the project at directory $PROJECT_DIR.
	-a | --at)
		shift
		PROJECT_DIR="$1"	
	;;

	# Be verbose.
	-v | --verbose)
		VERBOSE=true
	;;

	# Make a new project.
	-*) 
		echo "$1 is not a recognized option!"
		usage 1
	;;
	*) break;;
esac
shift
done


#########################
# Checks 
#########################
USER_NAME="${USERNAME-${USER}}"


# Run for the first time.
if [ ! -z "$FIRST_RUN" ]
then
  # Dependency check.
  PROGRAMS=("which" "sqlite3")	# terms are important
  declare -a PROGRAM_PATH
  PCOUNT=1
  for n in ${PROGRAMS[@]}
  do
	  LOCATION=$(which $n 2>/dev/null)
	  [ ! -z $VERBOSE ] && echo "Checking for package: $n on system."
	  if [[ -z "$LOCATION" ]]
	  then
		  printf "$n does not seem to be available on your system.\n"
		  printf "Please use your package manager or configure this\n"
		  printf "software package from source.\n"	
		  exit 1
	  else
		  [ ! -z $VERBOSE ] && printf "$(basename $n) is on system at: $LOCATION\n"
	  fi
  done
			  
	# Configure globals.
	[ -z "$EDITOR" ] && EDITOR=vi
	[ -z "$FILE_MGR" ] && FILE_MGR=  # need a list...
				  
	# Create filesystem cruft.
	[ ! -z "$VERBOSE" ] && printf "Creating $PROGRAM directories & files.\n"
   mkdir -p $DIR \
		$PROJECTS_DIR \
		$ARCHIVES_DIR \
		$HOOKS_DIR \
		$ALIAS_DIR \
		$HOOKS_DIR \
		$PRE_DIR \
		$POST_DIR \
		$PROCESS_DIR

	# Write your SQL file.
	$__SQLITE $__DB < $SQL_FILE

	# Write global defaults to file.
  echo "# Project global settings
DEFAULT_PROJECT_DIR=$PROJECTS_DIR
DEFAULT_EDITOR=$GEDITOR

# Parameters
TIME_LIMIT_BEFORE_ARCHIVE=never

# Per project
DEFAULT_FILE_MGR=$GFILE_MGR
DEFAULT_TERMS=2" > $DEFAULTS

  	# File is successfully written.
	if [ ! -z "$VERBOSE" ]
	then
  		# Write out success message for file.
  		[ -f "$DEFAULTS" ] && echo "Global settings for $PROGRAM successfully created."

  		# Success message.
		if [ -f "$__DB" ]
		then
			echo "Databases successfully initialized at $__DB."
			echo "pm is ready to go!"
		fi
	fi # ! -z VERBOSE

	
	# Start editing files.
	$__SQLITE $__DB "INSERT INTO settings VALUES ( null, '$USER_NAME', 1, '', '', '$EDITOR', '' );" 	


	# Install if asked.
	[ ! -z "$INSTALL" ] && install_all

	# Exit if successful.
	exit 0
fi


# Get a list of sites.
if [ ! -z "$LIST_ALL" ]
then 
	# Only proceed if we've got data.
	RES=$($__SQLITE $__DB "SELECT * FROM project_description LIMIT 1;")
	if [ -z "$RES" ]
	then
		echo "No projects created or added so far with $PROGRAM."
		echo "How about adding a few with $PROGRAM --new <name>?"
		exit 1

	# Check the duration string for smart stuff.
	elif [ ! -z "$DURATION" ]
	then
		DAY_LENGTH=86400
		INC=0
		NUM_POS=0

		# Find where the first strings exist. 
		while [ $INC -lt ${#DURATION} ]; do
			if [[ ${DURATION:$INC:1} != [0-9] ]]
			then
				STR_POS=$INC
				break
			fi
			INC=$(( $INC + 1 ))
		done

		# Break down times by year.
		REQUESTED_TIME=${DURATION:0:$STR_POS}
		if [[ ${DURATION:$STR_POS:1} == 'y' ]] 
		then
			ONE_YEAR=$(( $DAY_LENGTH * 365 ))		# No leapyear?
			TIME_INC=$(( $ONE_YEAR * $REQUESTED_TIME ))
			
		# ...by months - Not finished...
		#elif [[ ${DURATION:$STR_POS:1} == 'm' ]]
		#then
		#	ONE_MONTH=$(( $DAY_LENGTH * 30 ))		# This needs to be smarter. 
		#	TIME_INC=$(( $ONE_MONTH * $REQUESTED_TIME ))

		# ...by day 
		elif [[ ${DURATION:$STR_POS:1} == 'd' ]]
		then
			TIME_INC=$(( $DAY_LENGTH * $REQUESTED_TIME ))
			echo $REQUESTED_TIME days
			echo $TIME_INC seconds 

		elif [[ ${DURATION:$STR_POS:1} == 'h' ]]
		then
			TIME_INC=$(( 60 * 60 * $REQUESTED_TIME ))
			echo $REQUESTED_TIME hours 
			echo $TIME_INC seconds

		elif [[ ${DURATION:$STR_POS:1} == 'm' ]]
		then
			TIME_INC=$(( 60 * $REQUESTED_TIME ))
			echo $REQUESTED_TIME minutes 
			echo $TIME_INC seconds
		
		
		elif [[ ${DURATION:$STR_POS:1} == 's' ]]
		then
			TIME_INC=$REQUESTED_TIME
			echo $REQUESTED_TIME seconds 
			echo $TIME_INC seconds

		fi
		
		# Purty message.
		TIME_WINDOW=$(( $(date +%s) - $TIME_INC ))
		printf "Pulling all projects opened after:\n" 
		echo $(date --date="@${TIME_WINDOW}")

		# Pull the projects
		$__SQLITE -line $__DB "SELECT * FROM project_description WHERE date_last_updated > $TIME_WINDOW;"
		
	else 
		$__SQLITE -line $__DB "SELECT * FROM project_description;"
		exit 0
	fi
fi


# Executables
[ -f "$DEFAULTS" ] && source "$DEFAULTS"


# Configure a project.
if [ ! -z "$CONFIGURE" ]
then
	# Get the editor from the database.
	__EDITOR="$( $__SQLITE $__DB "SELECT editor FROM settings WHERE user_added = '$USER_NAME';")"

	# Configure your file.
	$__EDITOR $ALIAS_DIR/${PROJECT_NAME}.sh
fi


# Add a project that is already in existence.
[ ! -z "$INTEGRATE_PROJECT" ] && integrate_project	 


# Uninstall
[ ! -z "$UNINSTALL" ] && uninstall


# Install
[ ! -z "$INSTALL" ] && install_all 


# Make a new project 
[ ! -z $MAKE_NEW_PROJECT ] && make_new_project


# Totally remove 
[ ! -z "$REMOVE_PROJECT" ] && remove 


# Unregister 
[ ! -z "$UNREGISTER_PROJECT" ] && unregister 


# Spawn a new terminal window for a project.
if [ ! -z "$OPEN_PROJECT" ] && [ ! -z "$SPAWN" ] 
then 
	spawn

# Open a project.
elif [ ! -z "$OPEN_PROJECT" ] 
then
	open 
fi


# Get last 10 projects. 
if [ ! -z "$GET_LAST" ]; then
	if [ ! -z $LAST_LIMIT ] && (( $LAST_LIMIT == 1 )) 
	then 
		echo "Here is the last ${LAST_LIMIT} project you've handled via \`pm\`."
	else
		echo "Here are the last ${LAST_LIMIT-10} projects you've handled via \`pm\`."
	fi	
 
	LAST_TIMES=$($__SQLITE $__DB "SELECT 
project_name, 
project_dir, 
datetime(date_last_updated,'unixepoch','localtime')
FROM project_description 
WHERE who_added = '$USER_NAME' 
ORDER BY date_last_updated DESC LIMIT ${LAST_LIMIT-10};")

	# Cycle through the last times.	
	for G in ${LAST_TIMES[@]}
	do
		if [[ $(echo $G | awk -F '|' '{ print $3 }') == "" ]]
		then
			printf "$G\n\n"
			continue	
		else
			printf $G | awk -F '|' '{ print "Project: " $1 " at: " $2 "\nWas last modified on: " $3  }'
			printf "At: "
		fi
	done	
fi 

# Mass Import
if [ ! -z "$DO_MASS_IMPORT" ] 
then
	# Discard commands with hooks.
	if [ ! -z "$HOOKS" ]; then
		echo "Hooks are not supported for mass imports yet."
		echo "Please try the --mass-import flag without the --hooks option."
		exit 1
	fi

	# Load at the directory.
	if [ ! -z "$MASS_IMPORT_DIR" ] && [ -d "$MASS_IMPORT_DIR" ]
	then
		for EACH in $MASS_IMPORT_DIR/*; do
			if [ ! -h "$EACH" ] && [ -d "$EACH" ]
			then
				DIR="$EACH"
				PROJECT_NAME=$(basename "$DIR") 
				PROJECT_DIR="$DIR"
				__insert_new_record
			fi	
		done
	else
		echo "Option --mass-import must have a directory specified in order to add any new projects."
		exit 1
	fi
fi
