#!/bin/bash

#
# Audit filter for groups
#
# By default, next values are ignored (not relevant for audit):
#  projects: .projects,
#
# Theses values are define for backward compatibility
#  visibility_level: .visibility_level,
#
# shellcheck disable=SC2034
GITLAB_DEFAULT_AUDIT_FOR_GROUP='
avatar_url: .avatar_url,
description: .description,
full_name: .full_name,
full_path: .full_path,
id: .id,
ldap_access: .ldap_access,
ldap_cn: .ldap_cn,
lfs_enabled: .lfs_enabled,
name: .name,
parent_id: .parent_id,
path: .path,
request_access_enabled: .request_access_enabled,
shared_projects: .shared_projects,
shared_runners_minutes_limit: .shared_runners_minutes_limit,
visibility: .visibility,
visibility_level: .visibility_level,
web_url: .web_url,
'


#
# Audit filter for projects
#
# By default, next values are ignored (not relevant for audit):
#  created_at: .created_at,
#  forks_count: .forks_count,
#  last_activity_at: .last_activity_at,
#  star_count: .star_count
#
# Theses values are define for backward compatibility
#  builds_enabled: .builds_enabled,
#  only_allow_merge_if_build_succeeds: .only_allow_merge_if_build_succeeds,
#  public: .public,
#  public_builds: .public_builds,
#  visibility_level: .visibility_level,
#
# shellcheck disable=SC2034
GITLAB_DEFAULT_AUDIT_FOR_PROJECT='
_links: {
  events: ._links.events,
  labels: ._links.labels,
  members: ._links.members,
  merge_requests: ._links.merge_requests,
  repo_branches: ._links.repo_branches,
  self: ._links.self
  },
approvals_before_merge: .approvals_before_merge,
archived: .archived,
avatar_url: .avatar_url,
builds_enabled: .builds_enabled,
ci_config_path: .ci_config_path,
container_registry_enabled: .container_registry_enabled,
creator_id: .creator_id,
default_branch: .default_branch,
description: .description,
http_url_to_repo: .http_url_to_repo,
id: .id,
import_error: .import_error,
import_status: .import_status,
issues_enabled: .issues_enabled,
jobs_enabled: .jobs_enabled,
lfs_enabled: .lfs_enabled,
merge_requests_enabled: .merge_requests_enabled,
name: .name,
name_with_namespace: .name_with_namespace,
namespace: {
  full_path: .namespace.full_path,
  id: .namespace.id,
  kind: .namespace.kind,
  members_count_with_descendants: .namespace.members_count_with_descendants,
  name: .namespace.name,
  parent_id: .namespace.parent_id,
  path: .namespace.path,
  plan: .namespace.plan,
  shared_runners_minutes_limit: .namespace.shared_runners_minutes_limit
},
only_allow_merge_if_all_discussions_are_resolved: .only_allow_merge_if_all_discussions_are_resolved,
only_allow_merge_if_pipeline_succeeds: .only_allow_merge_if_pipeline_succeeds,
only_allow_merge_if_build_succeeds: .only_allow_merge_if_build_succeeds,
path: .path,
path_with_namespace: .path_with_namespace,
permissions: {
  group_access: {
    access_level: .permissions.group_access.access_level,
    notification_level: .permissions.group_access.notification_level
  },
  project_access: .permissions.project_access
},
printing_merge_request_link_enabled: .printing_merge_request_link_enabled,
public: .public,
public_builds: .public_builds,
public_jobs: .public_jobs,
repository_storage: .repository_storage,
request_access_enabled: .request_access_enabled,
runners_token: .runners_token,
shared_runners_enabled: .shared_runners_enabled,
shared_with_groups: .shared_with_groups,
snippets_enabled: .snippets_enabled,
ssh_url_to_repo: .ssh_url_to_repo,
tag_list: .tag_list,
visibility: .visibility,
visibility_level: .visibility_level,
web_url: .web_url,
wiki_enabled: .wiki_enabled
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

