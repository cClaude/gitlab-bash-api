# gitlab-bash-api tests on dockers

## Configuration

Have a look to the file **docker-config/config.sh** (at least have a look to setup initial password for root) if you need customization create a file named **docker-config/my-config.sh** then just overwrite
needed values in this file.


Then run **gitlab-setup.sh**

```bash
./gitlab-setup.sh
```

Launch docker with this configuration

```bash
./gitlab.sh --start
```

When docker is running and GitLab available, you need to do the first connection
(provide password same password used in configuration)

http://localhost/

Then get your token

```bash
./gitlab.sh --configure-token
```

## Run tests

Test are named **test-*.sh**


