# GitLab bash API

## Installation

This tool require *bash*, *curl* and *jq*.

**jq** installation

```bash
sudo apt install jq
```


## Configuration
This tools expect to have GITLAB_PRIVATE_TOKEN variable set with your private token.

File my-gitlab-credentials.sh is ignore by this git repository you store in this file your token.

**Customization:**

Create a file in *gitlab-configuration-with-api/my-config* or in a folder identify by  **${GITLAB_BASH_API_CONFIG}** with in:

```bash
export GITLAB_PRIVATE_TOKEN=__YOUR_GITLAB_TOCKEN_HERE__
export GITLAB_USER=__YOU_GITLAB_USER_HERE__
export GITLAB_URL_PREFIX=https://gitlab-server
```


**Facultative configuration:**

```bash
export GITLAB_BASH_API_PATH='/__YOUR_PATH_TO/gitlab-configuration-with-api'
export GITLAB_BASH_API_CONFIG="~/my-config"
```


## Usage

* How to create a group ?

```bash
${GITLAB_BASH_API_PATH}/createGroup.sh my_test_group
```

* How to create some repositories ?

```bash
${GITLAB_BASH_API_PATH}/createProject.sh my_test_group my_test_repository1
${GITLAB_BASH_API_PATH}/createProject.sh my_test_group my_test_repository2
```

* How to create a new user ?

```bash
${GITLAB_BASH_API_PATH}/createUser.sh "test user" test test@example.org
```

How to display all users ?

```bash
${GITLAB_BASH_API_PATH}/listUsers.sh 
```

How to display a specific user ?

```bash
${GITLAB_BASH_API_PATH}/listUsers.sh testuser
```
