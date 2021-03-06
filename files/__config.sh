######################################
# __config.sh
#
# DO NOT EDIT THIS FILE!
######################################
# General settings. 
PROGRAM="pm"
SQL_FILE="$BINDIR/files/__pm.sql"
DIR="$HOME/.pm"
PROJECTS_DIR="$DIR/projects"
ARCHIVES_DIR="$DIR/archive"
ALIAS_DIR="$DIR/aliases"
HOOKS_DIR="$DIR/hooks"
PRE_DIR="$DIR/hooks/pre"
POST_DIR="$DIR/hooks/post"
PROCESS_DIR="$DIR/hooks/proc"
DEFAULTS="$DIR/config"

# SQL related
__DB="$DIR/projects.db"
#LIST=( $(ls "$BINDIR/[a-z]*.sh") )		# Skip configuration files.

# Bashkit
source "$BINDIR/bashkit/include/litesec.sh"
source "$BINDIR/bashkit/include/unirand.sh"
source "$BINDIR/bashkit/include/string.sh"
source "$BINDIR/bashkit/include/sqlite3.sh"
source "$BINDIR/bashkit/include/arg.sh"
source "$BINDIR/bashkit/include/usage.sh"
