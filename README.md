GitBG 1.0
===========
It's a prompt for git repositories that works in Windows by MINGW.

![screenshot]

Features
--------
* Number of commits ahead (green) or behind (red) from remote branch
* Avoid insert password every update for ssh protocol
* Show short status of files with double enter
* Colored current branch
    - Cyan: new files
    - Red: deleted files
    - Green: modified files
    - Yellow: added file

What's new?
-----------
#### 1.1
* Double enter: print files and connection status
* New function: add_ssh_key 
* Branch name bug fixed 

#### 1.0
* Fixed number of commits behind: format and color
* Optimized some functions
* Name of repository in console title
* Removed the option "promptOneLine"

Instalation
-----------
The instalation can be performed in two ways: using git or downloading manually.

#### With git
1. Download the files to the folder `~/GitBG`.

    ```sh
    git clone git@github.com:bismarckjunior/gitBG.git ~/GitBG
    ```

2. Add `gitBG.sh` to the end of `.bashrc` file.

    ```sh
    echo "source .gitBG/gitBG.sh" >> ~/.bashrc
    ```

#### Without git
1. Create the folder `~/GitBG`.

    ```sh
    mkdir ~/GitBG
    ```

2. Download and extract the files to `~/GitBG`.

3. Add `gitBG.sh` to the end of `.bashrc` file.

    ```sh
    echo "source ~/GitBG/gitBG.sh" >> ~/.bashrc
    ```


Update
------
1. Go to GitBG folder.

    ```sh
    cd ~/GitBG
    ```

2. Update GitBG repository.

    ```sh
    git pull
    ```


Settings
--------
Resets default variables:

    git config gitBG.reset true

Auto SSH logon when start in git repository:

    git config gitBG.logon true

Auto SSH logoff:

    git config gitBG.logoff true
    git config gitBG.logoff false

SSH logon time (in seconds):

    git config gitBG.logonTime 36000

Print "git status -s" with double enter:

    git config gitBG.status true
    git config gitBG.status false

Number of lines for "git status" after prompt:

    git config gitBG.maxLineStatus 15

Path for GitBG files:

    git config gitBG.path "~/GitBG"

## Colors
The possibles colors are:

| Color          | Key                   |
| -------        | ---                   |
| Red            | $GITBG_COLOR_RED      |
| Red (bold)     | $GITBG_COLOR_RED2     |
| Green          | $GITBG_COLOR_GREEN    |
| Green (bold)   | $GITBG_COLOR_GREEN2   |
| Yellow         | $GITBG_COLOR_YELLOW   |
| Yellow (bold)  | $GITBG_COLOR_YELLOW2  |
| Blue           | $GITBG_COLOR_BLUE     |
| Blue (bold)    | $GITBG_COLOR_BLUE2    |
| Magenta        | $GITBG_COLOR_MAGENTA  |
| Magenta (bold) | $GITBG_COLOR_MAGENTA2 |
| Cyan           | $GITBG_COLOR_CYAN     |
| Cyan (bold)    | $GITBG_COLOR_CYAN2    |
| White          | $GITBG_COLOR_WHITE    |
| White (bold)   | $GITBG_COLOR_WHITE2   |

Color branch for modified file:

    git config gitBG.color.modifiedFile $GITBG_COLOR_GREEN2

Color branch for deleted file:

    git config gitBG.color.deletedFile $GITBG_COLOR_RED

 Color branch for new file:

    git config gitBG.color.newFile $GITBG_COLOR_CYAN

 Color branch for not added file:

    git config gitBG.color.notAddedFile $GITBG_COLOR_BLUE

 Color branch for added file:

    git config gitBG.color.addedFile $GITBG_COLOR_YELLOW

## Defaut variables
The default variables are:

| Variable          | Value                   |
| -------------     | -------------           |
| reset             | true                    |
| logon             | true                    |
| logoff            | false                   |
| logoTime          | 36000                   |
| status            | true                    |
| maxLineStatus     | 15                      |
| path              | "~/GitBG"               |
| modifiedFile      | $GITBG_COLOR_GREEN2     |
| deletedFile       | $GITBG_COLOR_RED        |
| newFile           | $GITBG_COLOR_CYAN       |
| notAddedFile      | $GITBG_COLOR_BLUE       |
| addedFile         | $GITBG_COLOR_YEALLOW    |

Author
------
Bismarck Gomes Souza Jr <<bismarckgomes@gmail.com>>.


License
-------
GitBG is available under the GLPv3 [license]. See the LICENSE file for more details.


[license]:http://www.gnu.org/licenses/gpl-3.0.txt
[screenshot]:https://github.com/bismarckjunior/GitBG/blob/master/images/screenshot.png


