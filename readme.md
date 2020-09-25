# Devops Glasgow Meetup

Meetup talk for Devops Glasgow on xx Sept 2020.


# Prereq

You will need a few things installed or setup before startng;

* Anthos cluster deployed with Cloud Run enabled (`setup-install.sh`)
* If already installed run `setup-login.sh` to make sure settings are as expected
* Custom domain mapping [optional]
* `kubectl` client installed
* `gcloud` CLI installed 
* `kn` CLI (installed)[https://knative.dev/docs/install/install-kn/] 
* The container images created that will be used (see optional step to create container images)


## Cloud Run

# Demo

## Intial Container image [OPTIONAL]

```bash
pack build --publish eu.gcr.io/bigrob/glasgow:start
## Also with each image created as blue/green
```

## Push App

I already have an app, it's already containerised, and I'm ready to be deployed.

I have a few differnt options ....
* `kn` CLI
* `gcloud` CLI
* `kubectl`
* Terraform
* or UI 

### CLI

```bash
# Create a Knative service with the Knatice CLI kn
kn service create meetup-kn --image eu.gcr.io/big-rob/glasgow:initial
# kn service create helloworld-go --image gcr.io/knative-samples/helloworld-go --env TARGET="Go Sample v1"
```
Talk through the steos and how they relate to the theory - you can click on the URL and view the page. 

I spend more time using the `gcloud` CLI, mainly becuase of my day job. You can easliy define the deployment platforms when you have multiple clusters.

```bash
# Create a Cloud Run service with gcloud CLI - gcloud run deploy ... on Anthos
gcloud run deploy meetup --image eu.gcr.io/big-rob/glasgow:initial --platform gke 
# OR Fully Managed
gcloud run deploy --image eu.gcr.io/big-rob/glasgow:initial --platform managed
# OR - On-prem
gcloud run deploy --image eu.gcr.io/big-rob/glasgow:initial --platform kubernetes
```

What about manifests that we are more used to in a K8s world?

```bash
# Deploy with traditional k8s coammnds and yaml
cat knative-deploy.yaml
kubectl apply -f knative-deploy.yaml
```

This is all great but how do I see what is running?

Lets see it running

```bash
kn -h (highlight create, update, revisions)
kn service describe meetup
kn route describe meetup
kn revision list

gcloud run services list
gcloud run revisions list

kubectl get ksvc
kubectl get svc
kubectl get pods
kubectl get revisions


kubectl get route meetup 

gcloud run services describe meetup
gcloud run services describe meetup --format yaml
gcloud run services describe meetup --format export ## Look at the Cloud Run Console

```

```bash
# Service - Describes an application on Knative.
# Revision - Read-only snapshot of an application's image and other settings (created by Configuration).
# Configuration - Created by Service (from its spec.configuration field). It creates a new Revision when the revisionTemplate field changes.
# Route -Configures how the traffic coming to the Service should be split between Revisions.
kubectl get configuration,revision,route
```

As mentioned a couple of other methods exist to deploy;
* Yaml - `kubectl appy -f knative-deploy.yaml
* Terraform - `terrafrom apply`

Now lets look at this form the console ....
* YAML
* Revisions
* Metrics
* ..


<!-- ```
kubectl apply -f v1.yaml
kubectl get revisions

kubectl apply -f v2.yaml
kubectl get revisions

kubectl describe route canary
``` -->

<!-- https://cloud.google.com/cloud-build/docs/deploying-builds/deploy-cloud-run#anthos-on-google-cloud
` gcloud builds submit --tag eu.gcr.io/clijockey/glasgow` -->


## Scale up/down


```
# Split pane
watch kubectl get pods
```

```bash
# Now, use hey to send 150,000 requests (with 500 requests in parallel), each taking 1 second (leave this command running, as it will take a while to complete).
# <!-- hey -host meetup.cloud-run.gcp-demo.coffee -c 500 -n 150000 \
#   "http://meetup.cloud-run.gcp-demo.coffee?sleep=1000" -->
hey -c 500 -n 150000 "http://meetup.cloud-run.gcp-demo.coffee" 
```

Look at console metrics/graphs 

## New version (blue/green)



```bash
# Gradual Rollout (useing beta to allow for tagging revisions)
gcloud run deploy meetup --image eu.gcr.io/big-rob/glasgow:blue
# gcloud beta run deploy --image eu.gcr.io/big-rob/glasgow:blue --no-traffic --tag blue
## browse to blue---<URL>
gcloud beta run deploy meetup --image eu.gcr.io/big-rob/glasgow:green --no-traffic --tag green
# now bring into service gradually
gcloud beta run services update-traffic meetup --to-tags green=20
gcloud beta run services update-traffic meetup --to-tags green=40
gcloud beta run services update-traffic meetup --to-tags green=100
```


```bash
#Actually maybe we want to baance the traffic and see which has the best impact?
# splitting Traffic (probably exclude this one)
gcloud run services update-traffic meetup --to-revisions <LIST>
#OR
 kn service update meetup \
 --traffic <revision1>=50 \
 --traffic <revision2>=50
```

```bash
# All traffic to latest revision
gcloud run services update-traffic meetup --to-latest
```

```bash
# Rollback
gcloud run services update-traffic meetup --to-revisions <revision>=100
```

Show console and ability to change


## Via Buildpacks and autobuild pipelines

Let show how this could be integrated with CI/CD pipelines.
I would prefer to have this automatically deployed, change something and commit to watch the pipeline kick-off
Show it in a Cloud Build page and the output


## Telemetry/Log & Monitor

Cloud Run metrics tab for service

Uptime check

gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=meetup" --project big-rob --limit 10

stackdriver
alerts
https://cloud.google.com/run/docs/monitoring

## Event demo
Step 1) - https://cloud.google.com/run/docs/tutorials/pubsub

The flow of data in this tutorial follows these steps:
1) A user uploads an image to a Cloud Storage bucket.
2) Cloud Storage publishes a message about the new file to Pub/Sub.
3) Pub/Sub pushes the message to the Cloud Run service.
4) The Cloud Run service retrieves the image file referenced in the Pub/Sub message.
5) The Cloud Run service uses the Cloud Vision API to analyze the image.
6) If violent or adult content is detected, the Cloud Run service uses ImageMagick to blur the image.
7) The Cloud Run service uploads the blurred image to another Cloud Storage bucket for use.

```bash
# SHow the two buckets
gsutil cp ~/Downloads/zombie.jpg gs://br_image_pro                                                    ─╯

```