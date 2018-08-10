**Table of Contents**

* [GitLab bash API](#gitlab-bash-api)
  * [Installation](#installation)
  * [Configuration](#configuration)
  * [Usage](#usage)
    * [Generic GET](#generic-get)
    * [Generic PUT](#generic-put)
    * [About users](#about-users)
    * [About groups](#about-groups)
    * [About projects (repositories)](#about-projects-repositories)
    * [About branches](#about-branches)
  * [Audit and backups](#audit-and-backups)
    * [Backups repositories](#backups-repositories)
    * [Audit groups and repositories](#audit-groups-and-repositories)
  * [Samples](#samples)
  * [About GitLab and gitlab\-bash\-api](#about-gitlab-and-gitlab-bash-api)
  * [Related documentations](#related-documentations)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)

GitLab bash API
===============

Access [GitLab CE API](https://docs.gitlab.com/ce/api/) or [GitLab EE API](https://docs.gitlab.com/ee/api/) from bash.

Last version is available on GitHub: https://github.com/cClaude/gitlab-bash-api

Current version is based on [GitLab V4 API](https://docs.gitlab.com/ce/api/v3_to_v4.html) but some features work on V3.
V3 is no more supported except by glGet and glPut commands.


Installation
------------

This tool require `bash`, `curl`, `jq` and `git`.

```bash
sudo apt update
sudo apt upgrade
sudo apt install jq git

git clone https://github.com/cClaude/gitlab-bash-api.git
```


Configuration
-------------

You can create a `my-config` folder (ignored by git) to configure/customize this application or just copy content of `custom-config-sample/`.
The `my-config` folder is taken in account by default by the API

> You can also use any custom folder for configuration, by setting `GITLAB_BASH_API_CONFIG`
> variable with the full path of your custom folder.

In you configuration files:

* You can create any custom file to declare variables (bash format), all theses files will be sourced.
* You can override default values define in `config/` folder,
* You need **at least** define values for `GITLAB_PRIVATE_TOKEN` and `GITLAB_URL_PREFIX`.

```bash
GITLAB_PRIVATE_TOKEN=__YOUR_GITLAB_TOKEN_HERE__
GITLAB_URL_PREFIX=__YOUR_GITLAB_USER_HERE__
```

Configuration algorithms :

1. source files in `${GITLAB_BASH_API_PATH}/config`
2. source files in `${GITLAB_BASH_API_PATH}/my-config` (if folder exists)
3. source files in `${GITLAB_BASH_API_CONFIG}` (if variable is define and if folder exists)

**Facultative configuration:**

You can also configure in you ~/.bashrc file

```bash
export GITLAB_BASH_API_PATH='__YOUR_PATH_TO__/gitlab-bash-api'
export GITLAB_BASH_API_CONFIG="__YOUR_PATH_TO__/your-custom-config-folder"

PATH=$PATH:${GITLAB_BASH_API_PATH}/
```

**Hacking**

If for any reason you need to customize how curl access to GitLab server you can add some
custom configuration in `${GITLAB_BASH_API_PATH}/my-config` or in `${GITLAB_BASH_API_CONFIG}`
folders.

A sample is available in `custom-config-sample/customize-curl.sh`.


Usage
-----

You can call comment using the full path

```bash
${GITLAB_BASH_API_PATH}/listUsers.sh --all
```

or simply (if **${GITLAB_BASH_API_PATH}** is in your path):

```bash
listUsers.sh --all
```

### Generic GET

Syntax:
> glGet.sh --uri GL_URI [--params 'PARAM1=VALUE1&PARAM2=VALUE2]

```bash
glGet.sh --uri /projects | jq .
```

### Generic PUT

Syntax:
> glPut.sh --uri GL_URI [--params 'PARAM1=VALUE1&PARAM2=VALUE2]

```bash
TODO NEED SAMPLE
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

How to manage groups using `glProjects` command ?

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
      [--default-branch DEFAULT_BRANCH] \
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
      [--default-branch DEFAULT_BRANCH] \
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

(glBranches.sh command is still in alpha version)


Audit and backups
-----------------

### Backups repositories

`glCloneAllProjects` allow you to backup all repositories (GitLab projects only)
using **gitlab-bash-api**.

It is not a backup for everything, backup of users, groups, merge-requests, snippets,
jobs, ... are not covered by `glCloneAllProjects`. But it keep full history of
your projects, this a good practice to keep a such copy before a GitLab migration.

* To clone **all projects** you have access

Syntax:
> glCloneAllProjects.sh --http|--ssh [--bare] --destination OUTPUT_FOLDER

* Complete example cloning throw ssh

```bash
mkdir -p tests-result

glCloneAllProjects.sh --ssh --bare --destination "tests-result/$(date +'%Y-%m-%d.%H-%M').clones"
```

If you need a custom key to handle this, create the key using

```bash
ssh-keygen -t rsa -C "clone-process" -b 4096 -f ~/.ssh/gitlab_root_id_rsa
```

Add this key on GitLab `root` account. `root` should be at least **developper** of
all repositories but for other action you probably need that this account is **owner**
of all repositories.

Then you can run `glCloneAllProjects` using

```bash
GIT_SSH_COMMAND="ssh -i ${HOME}/.ssh/gitlab_root_id_rsa" ./glCloneAllProjects.sh --ssh --bare --destination tests-result/$(date +'%Y-%m-%d.%H-%M').clones
```


### Audit groups and repositories

```bash
./glAudit.sh --directory tests-result/$(date +'%Y-%m-%d.%H-%M').audit
```

This will generate a folder `YYYY-MM-DD.HH-MM.audit` with these sub-folders
* `groups_by_id` : for all groups configuration (file `1.json` contain configuration of group id=1)
* `groups_by_path` : contain links (links name are based on group path)
* `projects_by_id` :for all repositories configuration (file `1.json` contain configuration of project id=1)
* `projects_by_path` : contain links (links name are based on project path name)
* `projects_by_path_with_namespace` : contain folder (based on group path) then link based on project path.


Samples
-------

Retrieve id of all projects into a group.

```bash
./glProjects.sh --config --group-path puppet | jq '[.[] | {
id: .id,
path_with_namespace: .path_with_namespace
}]'
```

Retrieve id of all projects into a group but format output

```bash
./glProjects.sh --config --group-path puppet |
  jq -r '.[] | (.id|tostring) + ":" + (.path_with_namespace)'
```

Retrieve id of all projects do something with this id

```bash
./glProjects.sh --config --group-path puppet |
  jq -r '.[] | (.id|tostring) + ":" + (.path_with_namespace)' |
  while read line; do
    echo "Handle ${line}"
    PROJECT_ID=$(echo "${line}" | cut -d ':' -f 1)

    echo "do something with ${PROJECT_ID}"

  done
```

Full sample

```bash
function enable_key_for_group {
  local group_name=$1
  local deploy_key_id=$2

  "${GITLAB_BASH_API_PATH}/glProjects.sh" --config --group-path "${group_name}" \
  | jq -r '.[] | (.id|tostring) + ":" + (.path_with_namespace)' \
  | while read line; do
      echo "Handle ${line}"
      local project_id=$(echo "${line}" | cut -d ':' -f 1)

      "${GITLAB_BASH_API_PATH}/glDeployKeys.sh" --enable --project-id "${project_id}" --key-id "${deploy_key_id}" || exit 1
  done
}

 # let say you have a deploy code id define in
 # You can use 'glDeployKeys.sh' to have this
 DEPLOY_KEY_ID=56
 GROUP_NAME=puppet

 # Then you want to enable this key on all project of a group
 # Basically it will use
 #   glDeployKeys.sh --enable --project-id PROJECT_ID --key-id DEPLOY_KEY_ID

 enable_key_for_group "${GROUP_NAME}" "${DEPLOY_KEY_ID}"
```


About GitLab and gitlab-bash-api
--------------------------------

If you really need this API you probably need to consider moving to another
git server.

> GitLab is the best SVN server ever...
> but for git needs consider to move to something else.

* [gitea](https://github.com/go-gitea/gitea) is complete, it is free and a true OpenSource solution.
* [bitbucket](https://www.atlassian.com/software/bitbucket/server) from Atlassian is proprietary software but probably the most mature solution.


Related documentations
----------------------

* How to [get your GitLab API key](how-to-get-your-gitlab-api-key.md)
