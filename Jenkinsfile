pipeline {
  agent {
    docker {
      image 'maven:3.6.3-openjdk-17'  // includes Maven 3.6.3 + Java 17
      reuseNode true                  // reuse workspace across container stages
    }
  }

  environment {
    NEXUS_VERSION       = 'nexus3'
    NEXUS_PROTOCOL      = 'http'
    NEXUS_URL           = '52.23.219.98:8081'
    NEXUS_REPOSITORY    = 'maven-snapshots'
    NEXUS_CREDENTIAL_ID = 'nexus_credentials'
  }

  parameters {
    booleanParam(defaultValue: true, name: 'mvn_build', description: 'Run Maven build?')
    booleanParam(defaultValue: true, name: 'publish_to_nexus', description: 'Publish artifact to Nexus?')
    gitParameter(branchFilter: 'origin/(.*)', defaultValue: 'origin/master', name: 'BRANCH', type: 'PT_BRANCH', description: 'Select Git branch')
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

          nexusArtifactUploader(
            nexusVersion: NEXUS_VERSION,
            protocol: NEXUS_PROTOCOL,
            nexusUrl: NEXUS_URL,
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

  post {
    success { echo '✅ Pipeline completed successfully.' }
    failure { echo '❌ Pipeline failed — check logs above.' }
  }
}
