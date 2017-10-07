# gitlab-bash-api tests on dockers

## Configuration

Customize file **docker-config/config.sh** if needed (at least have a look to setup initial password for root)

Then run **setup-configuration.sh**

```bash
./setup-configuration.sh
```

Launch docker with this configuration

```bash
./start-gitlab.sh
```

When docker is running

```bash
./bin/generate-private-token.sh
```

## Run tests

Test are named **test-*.sh**


