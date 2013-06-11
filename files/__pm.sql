/************************************
 * pm.sql
 *
 * Tables for pm.
 ************************************/
CREATE TABLE tracker (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	list TEXT,
	notes TEXT
);

/* termsettings */
CREATE TABLE termsettings (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	term_choice TEXT,		/* Choose a terminal type */
	project_name TEXT		/* This is fine, because they're unique */ 	
);

/* processes */
CREATE TABLE processes (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	owner TEXT,		/* If we don't match, we can't kill... */
	pid INTEGER, 	
	pid_child TEXT  /* wrap kill and kill every window open */
);

/* hooks */
CREATE TABLE hooks (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	hook_name TEXT,
	hook_file TEXT
);

/* settings */
CREATE TABLE settings (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	user_added TEXT,
	terms INTEGER,					/* Number of terminals (or screens) */
	project_dir TEXT,				/* Default directory */
	exec_dir TEXT,					/* Where the program is installed */
	editor TEXT,					/* Default editor */
	file_mgr TEXT					/* Default file manager */
);
 
/* project_description 
 */
CREATE TABLE project_description (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	project_name TEXT,		
	text_desc TEXT,				/* Description of the project */
	project_dir TEXT,				/* Date project last updated */
	date_created INTEGER, 		/* Date project originally created */
	date_last_updated INTEGER,	/* Date project last updated */
	who_added TEXT		   	/* Username that project belongs to */
);

/* activity_tracker */
CREATE TABLE activity_tracker (
id INTEGER PRIMARY KEY AUTOINCREMENT,
project_name TEXT,
activity_id TEXT,
date_run TEXT			/* Log a date of when some action was taken? */
);

/* project_tasks 
 *
 * List of crap to do on a project. */
CREATE TABLE project_tasks (
id INTEGER PRIMARY KEY AUTOINCREMENT,
project_name TEXT,		
project_task TEXT,		
task_priority TEXT,		
task_type TEXT
);
