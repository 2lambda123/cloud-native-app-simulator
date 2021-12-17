#
# Copyright 2021 Ericsson AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#!/bin/bash

DEFAULT_NUM=4
if [ -z "$4" ]; then
	NUM=$DEFAULT_NUM
else
	NUM=$4
fi

if [[ -d k8s ]]; then
	echo "deleting previous manifest files"
	rm -r k8s
fi

mkdir k8s
#generate kubernetes kubernetes manifest files
echo "generating kubernetes manifest files"
go run main.go generate $1 $2 $3

#applying manifest files to respective clusters
for i in $(seq ${NUM}); do
	if [[ -d k8s/cluster${i} ]]; then
		echo "applying deployment manifests to cluster${i}"
		kubectl apply --prune -f k8s/cluster${i} -l version=cluster${i} -n edge-namespace --context cluster${i}
	else
		kubectl delete deploy -l version=cluster${i} -n edge-namespace --context cluster${i}
		kubectl delete svc -l version=cluster${i} -n edge-namespace --context cluster${i}
		kubectl delete cm -l version=cluster${i} -n edge-namespace --context cluster${i}
	fi
done