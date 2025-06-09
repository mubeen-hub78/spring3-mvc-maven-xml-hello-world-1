pipeline {
  agent {
    docker {
      image 'maven:3.6.3-openjdk-17'
      reuseNode true
    }
  }

  environment {
    NEXUS_VERSION = 'nexus3'
    NEXUS_PROTOCOL = 'http'
    NEXUS_URL = '3.84.202.51:8081' // Updated to confirmed IP
    NEXUS_REPOSITORY = 'maven-snapshots'
    NEXUS_CREDENTIAL_ID = 'Nexus-cred'
  }

  parameters {
    booleanParam(defaultValue: true, name: 'mvn_build', description: 'Run Maven build?')
    booleanParam(defaultValue: true, name: 'publish_to_nexus', description: 'Publish artifact to Nexus?')
    gitParameter(branchFilter: 'origin/(.*)', defaultValue: 'origin/master', name: 'BRANCH', type: 'PT_BRANCH', description: 'Select Git branch')
    // Parameter for Nexus URL, defaulting to the confirmed IP
    string(name: 'NEXUS_URL_PARAM', defaultValue: '3.84.202.51:8081', description: 'Base URL for Nexus Repository Manager (e.g., ip:port/)')
    string(name: 'NEXUS_REPOSITORY_PARAM', defaultValue: 'maven-snapshots', description: 'Name of the Nexus repository to deploy artifacts to (e.g., maven-releases, maven-snapshots)')
    string(name: 'NEXUS_CREDENTIAL_ID_PARAM', defaultValue: 'Nexus-cred', description: 'Jenkins Credential ID for Nexus authentication')
    string(name: 'NEXUS_VERSION_PARAM', defaultValue: 'nexus3', description: 'Nexus API version (nexus3 or nexus2)')
    string(name: 'NEXUS_PROTOCOL_PARAM', defaultValue: 'http', description: 'Protocol for Nexus URL (http or https)')
    string(name: 'GIT_REPO_URL_PARAM', defaultValue: 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git', description: 'Git repository URL')
    string(name: 'GIT_BRANCH_PARAM', defaultValue: 'main', description: 'Git branch to clone')
  }

  stages {
    stage('Clone Code') {
      steps {
        git branch: "${params.BRANCH.replace('origin/', '')}",
             url: 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
      }
    }

    stage('Maven Build') {
      when { expression { params.mvn_build } }
      steps {
        echo '🔄 Running mvn clean package'
        sh 'mvn -B -Dmaven.test.failure.ignore clean package'
      }
    }

    stage('Publish to Nexus') {
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

          withCredentials([usernamePassword(credentialsId: NEXUS_CREDENTIAL_ID, usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
            nexusArtifactUploader(
              nexusVersion: NEXUS_VERSION,
              protocol: NEXUS_PROTOCOL,
              nexusUrl: NEXUS_URL, // This uses the environment variable, which gets its value from the parameter
              groupId: pom.groupId,
              version: "${BUILD_NUMBER}",
              repository: NEXUS_REPOSITORY,
              credentialsId: NEXUS_CREDENTIAL_ID,
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
