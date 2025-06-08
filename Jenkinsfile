pipeline {
  agent {
    docker {
      image 'maven:3.6.3-openjdk-17' // Specifies the Docker image for the agent
      reuseNode true // Reuses the workspace across container stages for efficiency
    }
  }

  environment {
    NEXUS_VERSION = 'nexus3'
    NEXUS_PROTOCOL = 'http'
    NEXUS_URL = '52.23.219.98:8081' // Your Nexus URL
    NEXUS_REPOSITORY = 'maven-snapshots' // Your Nexus snapshot repository
    NEXUS_CREDENTIAL_ID = 'Nexus-cred' // Your Jenkins credentials ID for Nexus
  }

  parameters {
    booleanParam(defaultValue: true, name: 'mvn_build', description: 'Run Maven build?')
    booleanParam(defaultValue: true, name: 'publish_to_nexus', description: 'Publish artifact to Nexus?')
    gitParameter(branchFilter: 'origin/(.*)', defaultValue: 'origin/master', name: 'BRANCH', type: 'PT_BRANCH', description: 'Select Git branch')
  }

  stages {
    stage('Clone Code') {
      steps {
        // Clones the specified branch from your Git repository
        git branch: "${params.BRANCH.replace('origin/', '')}",
             url: 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
      }
    }

    stage('Maven Build') {
      // Executes this stage only if 'mvn_build' parameter is true
      when { expression { params.mvn_build } }
      steps {
        echo '🔄 Running mvn clean package'
        // Runs Maven commands directly, as Maven is now in the Docker agent image
        sh 'mvn -B -Dmaven.test.failure.ignore clean package'
      }
    }

    stage('Publish to Nexus') {
      // Executes this stage only if 'publish_to_nexus' parameter is true
      when { expression { params.publish_to_nexus } }
      steps {
        script {
          def pom = readMavenPom file: 'pom.xml'
          def artifacts = findFiles(glob: "target/*.${pom.packaging}")

          if (artifacts.length == 0) {
            error "❌ No .${pom.packaging} found in target/, check pom.artifactId and packaging"
          }

          def artifactPath = artifacts[0].path
          echo "*** Found artifact at: ${artifactPath}"

          // The withCredentials block is useful if you need to use the username/password in a shell command.
          // For nexusArtifactUploader, it often just needs the credentialsId.
          // Keeping withCredentials here for demonstration, but it might not be strictly necessary
          // if only nexusArtifactUploader uses the credentials.
          withCredentials([usernamePassword(credentialsId: NEXUS_CREDENTIAL_ID, usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
            nexusArtifactUploader(
              nexusVersion: NEXUS_VERSION,
              protocol: NEXUS_PROTOCOL,
              nexusUrl: NEXUS_URL,
              groupId: pom.groupId,
              version: "${BUILD_NUMBER}", // Uses Jenkins' built-in BUILD_NUMBER for versioning
              repository: NEXUS_REPOSITORY,
              // Removed explicit username/password and rely solely on credentialsId
              credentialsId: NEXUS_CREDENTIAL_ID, // Ensure this is present
              artifacts: [
                [ artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging ],
                [ artifactId: pom.artifactId, classifier: '', file: 'pom.xml', type: 'pom' ]
              ]
            )
          }
        }
      }
    }
  }

  post {
    success { echo '✅ Pipeline completed successfully.' }
    failure { echo '❌ Pipeline failed — check logs above.' }
  }
}
