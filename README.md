# Blue-Green demo

The idea is to showcase a local blue-green deployment.

The demo sets up a local Kubernetes cluster using Kind and configures it with Ingress-Nginx for routing. It includes an Argo Rollout to demonstrate blue-green deployment strategies. The demo features scripts like 'simulate-requests' to mimic incoming traffic and 'switch-image' to dynamically switch between blue and green versions of an application. Additionally, the 'make status' command provides a live overview of the deployment's behavior during image transitions.

### Install dependencies

While it's developed on Ubuntu 22, it's designed to work across Linux distributions and macOS environments provided the necessary dependencies are installed.

**dependencies:**
- docker
- kind
- kubectl
- kubectl-argo-rollouts
- **uuidgen** (this tool will be needed only if OS is not linux)

for ubuntu distributions `make install_deps` can be used to install dependencies.
```
$ make install_deps
Checking and installing required packages...
Docker is already installed
Kind is already installed
Argo rollouts is already installed
```

"If you're using a Linux distribution other than Ubuntu or macOS, you can refer to the official documentation to install the following tools:

- Docker: Follow the Docker installation guide for your distribution [here](https://docs.docker.com/engine/install/)
- Kind: Refer to the Kind documentation for installation instructions on different platforms [here](https://kind.sigs.k8s.io/docs/user/quick-start/).
- kubectl: Install kubectl using the instructions provided [here](https://kubernetes.io/docs/reference/kubectl/)
- kubectl-argo-rollouts: For installation, consult the Argo Rollouts GitHub repository [here](https://github.com/argoproj/argo-rollouts#installation)

### Run the demo

These steps outline how to execute the blue-green deployment demo, showcasing image switching and monitoring using simulated requests. Use terminal splitting tools like tmux or separate terminal tabs to streamline the demo process and monitor the deployment progress effectively.

#### Step 1: Prepare the demo

Run the following command to set up the demo environment, including bootstrapping the kind cluster and deploying all necessary components:
```
make prepare_demo
```

This process may take a minute or two to complete. Meanwhile, you can monitor the progress of the Argo Rollout using the following command in a separate terminal window:

```
make status
```

![Prepare demo](img/waiting.png)

#### Step 2: Simulate Requests

Once everything is ready, simulate requests by executing:
```
make requests
```

The output will display the location targeted (a UUID) and the version (indicating blue or green) to which the request is connected

#### Step 3: Switch Images and Monitor Rollout

In a different terminal window, execute the following command to switch back and forth between the blue and green versions, and monitor the status of the rollout:
```
make switch
````

This command will display the progress of the rollout and provide updates on the current image version.  You can reuse the make switch command to continuously switch images and monitor changes.

![Preview Rollout](img/preview.png)


#### Step 4: Completion

After the image is rolled out and the blue service points to the new image, the preview pod will be marked as stable. At this point, you will start seeing the updated version in the request outputs.

![Finished](img/rolled_out.png)

#### Step 5: Clean Up

Once you have completed the demo, use the following command to bring down the kind cluster and delete all associated resources:

```
make delete_cluster
```

This will clean up the environment and remove all deployed components.
