// engineerbetter/iac-example-ci:07-automatically-apply
def ciImage = 'engineerbetter/iac-example-ci@sha256:fb389a09263ad4078b0c025356bc9ff541e07a5b407cbf31ccd6fe07145cd288'

pipeline {
  agent {
    kubernetes {
      yaml """
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: iac
            image: ${ciImage}
            command:
            - cat
            tty: true
        """.stripIndent()
      defaultContainer 'iac'
    }
  }

  environment {
    BOOTSTRAP_AWS_REGION = credentials 'BOOTSTRAP_AWS_REGION'
    BOOTSTRAP_BUCKET_NAME = credentials 'BOOTSTRAP_BUCKET_NAME'
    BOOTSTRAP_DYNAMO_TABLE_NAME = credentials 'BOOTSTRAP_DYNAMO_TABLE_NAME'
  }

  stages {
    stage('Terraform init') {
      environment {
        AWS_ACCESS_KEY_ID = credentials 'AWS_ACCESS_KEY_ID'
        AWS_SECRET_ACCESS_KEY = credentials 'AWS_SECRET_ACCESS_KEY'
      }

      steps {
        sh 'make terraform-init'
      }
    }

    stage('Delete sock shop') {
      environment {
        AWS_ACCESS_KEY_ID = credentials 'AWS_ACCESS_KEY_ID'
        AWS_SECRET_ACCESS_KEY = credentials 'AWS_SECRET_ACCESS_KEY'
      }

      steps {
        sh 'make fetch-cluster-config'
        sh 'make delete-sock-shop'

        // Leave time for Kubernetes to remove resources like Load Balancers.
        // Since Kubernetes creates resources that terraform doesn't know
        // about, we need to wait for these to be removed otherwise there's a
        // risk that `terraform destroy` will hang and require manual cleanup.
        sh 'sleep 180'
      }
    }

    stage('Destroy cluster') {
      environment {
        AWS_ACCESS_KEY_ID = credentials 'AWS_ACCESS_KEY_ID'
        AWS_SECRET_ACCESS_KEY = credentials 'AWS_SECRET_ACCESS_KEY'
      }

      steps {
        sh 'make destroy-cluster'
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}