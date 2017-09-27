#!/bin/bash

#
# Audit filter for groups
#
GITLAB_DEFAULT_AUDIT_FOR_GROUP='
id: .id,
path: .path,
avatar_url: .avatar_url,
description: .description,
full_name: .full_name,
full_path: .full_path,
lfs_enabled: .lfs_enabled,
name: .name,
request_access_enabled: .request_access_enabled,
visibility_level: .visibility_level,
web_url: .web_url,
'

#
# Audit filter for projects
#
GITLAB_DEFAULT_AUDIT_FOR_PROJECT='
id: .id,
path: .path,
path_with_namespace: .path_with_namespace,
archived: .archived,
avatar_url: .avatar_url,
builds_enabled: .builds_enabled,
container_registry_enabled: .container_registry_enabled,
creator_id: .creator_id,
default_branch: .default_branch,
description: .description,
http_url_to_repo: .http_url_to_repo,
issues_enabled: .issues_enabled,
lfs_enabled: .lfs_enabled,
merge_requests_enabled: .merge_requests_enabled,
name: .name,
name_with_namespace: .name_with_namespace,
only_allow_merge_if_all_discussions_are_resolved: .only_allow_merge_if_all_discussions_are_resolved,
only_allow_merge_if_build_succeeds: .only_allow_merge_if_build_succeeds,
public: .public,
public_builds: .public_builds,
request_access_enabled: .request_access_enabled,
runners_token: .runners_token,
shared_runners_enabled: .shared_runners_enabled,
snippets_enabled: .snippets_enabled,
ssh_url_to_repo: .ssh_url_to_repo,
visibility_level: .visibility_level,
web_url: .web_url,
wiki_enabled: .wiki_enabled,
'

# tag_list: .tag_list[],
# namespace: .namespace[],
# shared_with_groups: .shared_with_groups[],
# permissions: .permissions[]

#created_at:                                      2017-07-11T07:35:24.223Z",
#last_activity_at:                                2017-08-20T08:55:33.186Z",

#namespace:                                          {
#  id:
#  name:
#  path:
#  kind:
#    },
#shared_with_groups:                                [],

#permissions:                                          {
#  project_access:                                          null,
#  group_access:                                          {
#    access_level:                                          40,
#    notification_level:                                          3
#      }
#    }

