Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [GitLab bash API](#gitlab-bash-api)
    * [Installation](#installation)
    * [Configuration](#configuration)
    * [Global usage](#global-usage)
      * [About users](#about-users)
      * [About groups](#about-groups)
      * [About projects (repositories)](#about-projects-repositories)
      * [About branches](#about-branches)
      * [Related documentations](#related-documentations)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)


# GitLab bash API

Access [GitLab CE API](https://docs.gitlab.com/ce/api/) or [GitLab EE API](https://docs.gitlab.com/ee/api/) from bash.

Last version is available on GitHub: https://github.com/cClaude/gitlab-bash-api

Current version is base on [GitLab V3 API](https://docs.gitlab.com/ce/api/v3_to_v4.html) but tested on both V3 and V4.


## Installation

This tool require *bash*, *curl*, *jq*  and *git*.

```bash
sudo apt update
sudo apt upgrade
sudo apt install jq git

git clone https://github.com/cClaude/gitlab-bash-api.git
```


## Configuration

You can create a **my-config** folder (ignored by git) to configure/customize this application or just copy content of **custom-config-sample/**.
The **my-config** folder is taken in account by default by the API

> You can also use any custom folder for configuration, by setting **GITLAB_BASH_API_CONFIG**
> variable with the full path of your custom folder.

In you configuration files:

* You can create any custom file to declare variables (bash format), all theses files will be sourced.
* You can override default values define in **config/** folder,
* You need **at least** define values for **GITLAB_PRIVATE_TOKEN** and **GITLAB_URL_PREFIX**.

```bash
GITLAB_PRIVATE_TOKEN=__YOUR_GITLAB_TOKEN_HERE__
GITLAB_URL_PREFIX=__YOUR_GITLAB_USER_HERE__
```

Configuration algorithms :

1. source files in "${GITLAB_BASH_API_PATH}/config"
2. source files in "${GITLAB_BASH_API_PATH}/my-config" (if folder exists)
3. source files in "${GITLAB_BASH_API_CONFIG}" (if variable is define and if folder exists)

**Facultative configuration:**

You can also configure in you ~/.bashrc file

```bash
export GITLAB_BASH_API_PATH='__YOUR_PATH_TO__/gitlab-bash-api'
export GITLAB_BASH_API_CONFIG="__YOUR_PATH_TO__/your-custom-config-folder"

PATH=$PATH:${GITLAB_BASH_API_PATH}/
```


## Global usage

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
> glCreateUser.sh USER_NAME 'USER_FULLNAME' 'USER_EMAIL'

```bash
glCreateUser.sh testuser "test user" test-user@example.org
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

How to manage groups using **glGroups** command ?

* **Usage**: Get groups configuration
```bash
    glGroups.sh --config --path GROUP_PATH
    glGroups.sh --config --id GROUP_ID
    glGroups.sh --config --all
```

* **Usage**: List groups paths
```bash
    glGroups.sh --list-path --path GROUP_PATH
    glGroups.sh --list-path --id GROUP_ID
    glGroups.sh --list-path --all
```

* **Usage**: List groups ids
```bash
    glGroups.sh --list-id --path GROUP_PATH
    glGroups.sh --list-id --id GROUP_ID
    glGroups.sh --list-id --all
```

* **Usage**: Create group
```bash
    glGroups.sh --create --path GROUP_PATH
        [--name GROUP_NAME] \
        [--description GROUP_DESCRIPTION] \
        [--lfs_enabled true|false] \
        [--membership_lock true|false]
        [--request_access_enabled true|false] \
        [--share_with_group_lock true|false]]
        [--visibility  private|internal|public] \
```

* **Usage**: Edit group configuration
```bash
    glGroups.sh --edit --id GROUP_ID --name GROUP_NAME --path GROUP_PATH \
        [--description GROUP_DESCRIPTION] \
        [--visibility  private|internal|public] \
        [--lfs_enabled true|false] \
        [--request_access_enabled true|false]
```

* **Usage**: Delete a group
```bash
    glGroups.sh --delete --id GROUP_ID
```

* **Sample**: Retrieve main configuration on all groups:

```bash
glGroups.sh --config --all
```

* **Sample**: create a group

```bash
glGroups.sh --create --path my_test_group
```


### About projects (repositories)

How to manage groups using **glProjects** command ?

* **Usage**: Get projects configuration
```bash
    glProjects.sh --config [--compact] --id PROJECT_ID
    glProjects.sh --config [--compact] --group-path GROUP_PATH
    glProjects.sh --config [--compact] --all
    glProjects.sh --config [--compact] --path PROJECT_PATH
```

* **Usage**: List projects paths
```bash
    glProjects.sh --list-path --id PROJECT_ID
    glProjects.sh --list-path --group-path GROUP_PATH (could return more than one entry)
    glProjects.sh --list-path --all
    glProjects.sh --list-path --path PROJECT_PATH (could return more than one entry)
```

* **Usage**: List projects ids
```bash
    glProjects.sh --list-id --id PROJECT_ID
    glProjects.sh --list-id --group-path GROUP_PATH (could return more than one entry)
    glProjects.sh --list-id --all
    glProjects.sh --list-id --path PROJECT_PATH
```

* **Usage**: Create project
```bash
    glProjects.sh --create --group-id GROUP_ID --path PROJECT_PATH \
      [--project-name PROJECT_NAME] \
      [--project-description PROJECT_DESCRIPTION] \
      [--container-registry-enabled true|false] \
      [--issues-enabled true|false] \
      [--jobs-enabled true|false] \
      [--lfs-enabled true|false] \
      [--merge-requests-enabled true|false] \
      [--only-allow-merge-if-all-discussions-are-resolved true|false] \
      [--only-allow-merge-if-pipeline-succeed true|false] \
      [--printing-merge-request-link-enabled true|false] \
      [--public-jobs true|false] \
      [--request-access-enabled true|false] \
      [--snippets-enabled true|false] \
      [--visibility private|internal|public] \
      [--wiki-enabled true|false]
```

* **Usage**: Edit project
```bash
    glProjects.sh --edit --id PROJECT_ID --project-name PROJECT_NAME \
      [--path PROJECT_PATH] \
      [--project-description PROJECT_DESCRIPTION] \
      [--issues-enabled true|false] \
      [--merge-requests-enabled true|false] \
      [--jobs-enabled true|false] \
      [--wiki-enabled true|false] \
      [--snippets-enabled true|false] \
      [--container-registry-enabled true|false] \
      [--visibility private|internal|public] \
      [--public-jobs true|false] \
      [--only-allow-merge-if-pipeline-succeed true|false] \
      [--only-allow-merge-if-all-discussions-are-resolved true|false] \
      [--lfs-enabled true|false] \
      [--request-access-enabled true|false]
```

* **Usage**: Delete a project
```bash
    glProjects.sh --delete --group-path GROUP_PATH --path PROJECT_PATH
    glProjects.sh --delete --id PROJECT_ID
```

* **Sample**: Retrieve main configuration on all projects:

```bash
glProjects.sh --config --all
```

* **Sample**: Retrieve only path with name space:

```bash
glProjects.sh --config --all | jq -r ' .[] | .path_with_namespace'
```

* **Sample**: List of all projects id of a group

```bash
glProjects.sh --list-id --group-path GROUP_PATH
```

* **Sample**: To delete a project

```bash
glProjects.sh --delete --id PROJECT_ID
```

* To clone **all projects** you have access

Syntax:
> glCloneAllProjects.sh http|ssh

* Clone using ssh

```bash
mkdir _a_new_empty_folder
cd _a_new_empty_folder

glCloneAllProjects.sh ssh
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


### Related documentations

* How to [get your GitLab API key](how-to-get-your-gitlab-api-key.md)

