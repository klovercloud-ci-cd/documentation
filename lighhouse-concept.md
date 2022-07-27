## Overview

Lighthouse is a tool for managing kubernetes objects. Agents listen kube events and send objects data to lighthouse command. Lighthouse query provides app's to read kubernetes objects and events.

Lighthouse comprises -
- Lighthouse command
- lighthouse query

#### Lighthouse command
Agent listens kube events, send events to lighthouse command via api service. [Learn more](https://github.com/klovercloud-ci-cd/light-house-command)

#### Lighthouse query
Lighthouse query provides api`s to fetch kube objects and events stored by lighthouse command.
[Learn more](https://github.com/klovercloud-ci-cd/light-house-query)