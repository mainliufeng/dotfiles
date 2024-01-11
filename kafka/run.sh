#!/bin/bash

pids=()

command="/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties"
$command &
pids+=($!)
sleep 1

command="/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties"
$command &
pids+=($!)
sleep 1

cleanup() {
  echo "Received Ctrl-C. Cleaning up..."
  for pid in "${pids[@]}"; do
    kill "$pid" &>/dev/null
  done
}
trap cleanup INT

wait
