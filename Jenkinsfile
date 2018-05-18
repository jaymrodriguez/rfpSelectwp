node {
  def project = 'rfpselectdev'
  def appName = 'rfpselect-wp'
  def feSvcName = "${appName}-backend"
  def imageTag = "us.gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"

  checkout scm

  stage('Build image')
  sh("docker build -t ${imageTag} .")

//   stage 'Run Go tests'
//   sh("docker run ${imageTag} go test")

  stage 'Push image to registry'
  sh("gcloud docker -- push ${imageTag}")

  stage "Deploy Application"
  switch (env.BRANCH_NAME) {
    // Roll out to canary environment
    case "canary":
        // Change deployed image in canary to the one we just built
        // -i edits the fie in-place. bak will create a backup file
        sh("sed -i.bak 's#us.gcr.io/rfpselectdev/rfpselect-wp:1.0.0#${imageTag}#' ./k8s/canary/*.yaml")
        sh("kubectl --namespace=production apply -f k8s/services/")
        sh("kubectl --namespace=production apply -f k8s/canary/")
        sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out to production
    case "production":
        sh("kubectl get ns production || kubectl create ns production")
        // Change deployed image in canary to the one we just built
        sh("sed -i.bak 's#us.gcr.io/rfpselectdev/rfpselect-wp:1.0.0#${imageTag}#' ./k8s/production/*.yaml")
        sh("kubectl --namespace=production apply -f k8s/services/")
        sh("kubectl --namespace=production apply -f k8s/production/")
        sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out to dev
    case "master":
        sh("kubectl get ns development || kubectl create ns development")
        // Change deployed image in canary to the one we just built
        sh("sed -i.bak 's#us.gcr.io/rfpselectdev/rfpselect-wp:1.0.0#${imageTag}#' ./k8s/production/*.yaml")
        sh("kubectl --namespace=development apply -f k8s/services/")
        sh("kubectl --namespace=development apply -f k8s/dev/")
        sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out a dev environment
  //   default:
  //       // Create namespace if it doesn't exist
  //       sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")
  //       // Don't use public load balancing for development branches
  //       sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./k8s/services/frontend.yaml")
  //       sh("sed -i.bak 's#us.gcr.io/rfpselectdev/rfpselect-wp:1.0.0#${imageTag}#' ./k8s/dev/*.yaml")
  //       sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
  //       sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")
  //       echo 'To access your environment run `kubectl proxy`'
  //       echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/${feSvcName}:80/"
  // }
}