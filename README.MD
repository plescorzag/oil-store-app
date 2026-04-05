# Oil Essence NetObserv Demo

## Purpose

This project demonstrates the Red Hat OpenShift Network Observability Operator with a modern demo application that generates clear traffic patterns.

The application covers these network scenarios:

- external URL with expected latency
- external URL with high latency
- missing external URL
- service in the same namespace
- service in another namespace
- service blocked by a NetworkPolicy

## Design

The UI uses Red Hat secondary colors, primarily teal and purple, with a restrained Red Hat red accent.

## Components

- `oil-essence-web` in namespace `oil-demo`
- `oil-same-ns` in namespace `oil-demo`
- `oil-other-ns` in namespace `oil-peer`
- `oil-blocked` in namespace `oil-blocked`

## Observability

The demo deploys:

- a `FlowCollector` with:
  - no Loki
  - `deploymentModel: Service`
  - RTT enabled
- a custom NetObserv dashboard named `Oil Essence Demo`
- an `AlertingRule` that fires when RTT becomes slow

## Deploy

```bash
chmod +x deploy.sh
./deploy.sh
