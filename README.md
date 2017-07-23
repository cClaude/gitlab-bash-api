# GitLab bash API

Access [GitLab CE API](https://docs.gitlab.com/ce/api/) or [GitLab EE API](https://docs.gitlab.com/ee/api/) from bash.

Last version is available on GitHub: https://github.com/cClaude/gitlab-bash-api

Current version is base on [GitLab V3 API](https://docs.gitlab.com/ce/api/v3_to_v4.html).


## Installation

This tool require *bash*, *curl*, *jq*  and *git*.

```bash
sudo apt update
sudo apt upgrade
sudo apt install jq git

git clone https://github.com/cClaude/gitlab-bash-api.git
```


## Configuration

You can create a **my-config** folder (ignored by git) to configure/customize this application or just copy
content of **custom-config-sample/**.

> You can use any custom folder for configuration, you just need to set **GITLAB_BASH_API_CONFIG** 
> variable with the full path of your custom folder.

In you configuration files you can override default values define in **config/** folder and you need at
least define values for **GITLAB_PRIVATE_TOKEN** and **GITLAB_URL_PREFIX**.


```bash
GITLAB_PRIVATE_TOKEN=__YOUR_GITLAB_TOCKEN_HERE__
GITLAB_URL_PREFIX=__YOUR_GITLAB_USER_HERE__
```


**Facultative configuration:**

You can also configure in you ~/.bashrc file

```bash
export GITLAB_BASH_API_PATH='__YOUR_PATH_TO__/gitlab-bash-api'
export GITLAB_BASH_API_CONFIG="__YOUR_PATH_TO__/your-custom-config-folder"

PATH=$PATH:${GITLAB_BASH_API_PATH}/
```


## Usage

You can call comment using the full path
```bash
${GITLAB_BASH_API_PATH}/listUsers.sh --all
```

or simply (if **${GITLAB_BASH_API_PATH}** is in your path):

```bash
listUsers.sh --all
```

### About users

* How to create a new user ?

Syntax:
> createUser.sh USER_NAME 'USER_FULLNAME' 'USER_EMAIL'

```bash
createUser.sh testuser "test user" test-user@example.org
```

* How to display all users ?

```bash
listUsers.sh --all
```

* How to display a specific user ?

```bash
listUsers.sh testuser
```


### About groups

* How to create a group ?

```bash
${GITLAB_BASH_API_PATH}/createGroup.sh my_test_group
```

or simply (if **${GITLAB_BASH_API_PATH}** is in your path):

```bash
createGroup.sh my_test_group
```


### About projects / repositories

* How to create some repositories ?

```bash
createProject.sh my_test_group my_test_repository1
createProject.sh my_test_group my_test_repository2
```

* Projects main information:

Syntax:
> listProjects.sh [--all | PROJECT_ID]

* Retrieve main informations on all projects:

```bash
listProjects.sh --all
```

* Retrieve only path with name space:

```bash
listProjects.sh --all | jq -r ' .[] | .path_with_namespace'
```

* List of all projects in a group

```bash
listProjectsInGroup.sh GROUP_NAME
```

* To get complete information on a project (Need GitLab EE)

```bash
statisticsProjects.sh 12
```

* To delete a project

```bash
deleteProject.sh GROUP_NAME PROJECT_NAME
```

* To clone **all projects** you have access

Syntax:
> cloneAllProjects.sh http|ssh

* Clone using ssh

```bash
mkdir _a_new_empty_folder
cd _a_new_empty_folder

cloneAllProjects.sh ssh
```

### About branches

* List remote branch

Syntax:
> listBranches.sh PROJECT_ID

* To have all information about existing branches:

```bash
listBranches.sh 82
```

* To have just branches name list of project with id=10:

```bash
listBranches.sh 10 | jq -r ' .[] | .name'
```


