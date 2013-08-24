## pm

### Summary
pm is a really simple project management tool for Bash.  It categorizes and holds lots of info about your projects.  It can tell you when you last accessed work, when you last committed work, tell you what history was run for your project, and more.  It's so cool, you should tell your friends.

You can open new terminal windows or hijack your current ones to hold environment variables specific for your application.   You can also contain aliases and other custom functions in .rc files specifically tailored for your project.  Additionally, pm's database will keep track of where all of project's important files so you don't have to worry about losing anything.

### Commands
Command list is below.   If you've installed pm on your system, just run `man pm` to get the same thing.
- --first-run           
Run for the first time.
- --setup               
Setup globals.
- --install <dir>       
Install pm to <dir>.
- --uninstall           
Uninstalls pm according to user logged in.
- --as <user>           
Run this as a particular user. 
- -d | --editor         
Set an editor when trying to configure.
- -f | --hooks          
Edit hooks for a certain project.
- -p | --progress       
Get the progress of a project.  (May use curses)
- -m | --file-manager <prg> 
Use <prg> as a file manager for this project.
- -t | --terminals <N>  
Use <N> terminals when opening or configuring a project.
- -c | --configure <name>   
Configure project referenced by <name>.
- -l | --list           
List all projects.
- -? | --last           
List what we were last doing.
- -k | --kill <name>    
Kill all open instances of project <name>.
- -s | --spawn <int>    
Open <int> number of terminal windows.
- -n | --new <name>     
Create a new project called <name>.
- -r | --remove <name>  
Remove project referenced by <name>.
- -o | --open <name>    
Open project referenced by <name>.
- -u | --unregister <name>  
Remove project referenced by <name> from pm's database.
- -g | --register <name>    
Add some project to pm's database.
- -a | --at <dir>       
Create the project at <dir>
- -v | --verbose        
Be verbose in output.

### Copyright & Support
Contact Antonio Collins (ramar.collins@gmail.com) for more.


